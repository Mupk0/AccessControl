//
//  ActionsController.swift
//  AccessControl
//
//  Created by Dmitry Kulagin on 29.01.2020.
//  Copyright © 2020 Dmitry Kulagin. All rights reserved.
//

import UIKit
import CoreNFC
import CoreBluetooth

class ActionsController: UIViewController, NFCNDEFReaderSessionDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    let backgroundView = UIImageView()
    let NFCButton = UIButton()
    let BLEButton = UIButton()
    let openRoomsButton = UIButton()
    
    private var identifier = ""
    let deviceName = "BLE"
    var BLStatus = false
    
    var session: NFCNDEFReaderSession?
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var writeCharacteristic: CBCharacteristic?
    
    static func createInstance(identifier: String) -> ActionsController {
        let vc = ActionsController()
        vc.identifier = identifier
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDisplayView()
        
        _ = Timer.scheduledTimer(timeInterval: 2.0,
                                 target: self,
                                 selector: #selector(checkConnection),
                                 userInfo: nil,
                                 repeats: true)
    }
    
    @objc func didTapNFCButton(sender: UIButton!) {
        beginNFCScanning()
    }
    
    @objc func didTapRoomsButton(sender: UIButton!) {
        let vc = InRoomTableController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapBLEButton(sender: UIButton!) {
        startBLEScanning()
        BLStatus = true
        centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "FFE0"), CBUUID(string: "FEE0")])
    }
    
    @objc func checkConnection(sender: UIButton!) {
        if let peripheral = peripheral {
            BLEButton.removeTarget(nil, action: nil, for: .allEvents)
            if peripheral.state == CBPeripheralState.connected {
                BLEButton.setTitle("Отключить обнаружение", for: .normal)
                BLEButton.addTarget(self, action: #selector(cancelConnection), for: .touchUpInside)
            } else {
                BLEButton.setTitle("Включить обнаружение", for: .normal)
                BLEButton.addTarget(self, action: #selector(didTapBLEButton), for: .touchUpInside)
                BLStatus = false
            }
        }
    }
    
    @objc func cancelConnection(sender: UIButton!) {
        if let peripheral = peripheral {
            BLStatus = true
            centralManager.cancelPeripheralConnection(peripheral)
            centralManager.stopScan()
        }
    }
    //NFC Methods
    func beginNFCScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Сканирование не поддерживается",
                message: "Это устройство не поддерживает сканирование тегов",
                preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK",
                                                    style: .default,
                                                    handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }

        session = NFCNDEFReaderSession(delegate: self,
                                       queue: nil,
                                       invalidateAfterFirstRead: false)
        session?.alertMessage = "Необходимо держать iPhone близко к метке, чтобы запросить доступ"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "Обнаружено больше одной метки, уберите остальные и повторите процедуру"
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }

        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.invalidate(errorMessage: "Невозможно подключиться к метке")
                return
            }
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.invalidate(errorMessage: "Метка не поддерживается")
                    return
                } else if nil != error {
                    session.invalidate(errorMessage: "Невозможно запросить статус метки")
                    return
                }
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    if nil != error || nil == message {
                        session.invalidate(errorMessage: "Невозможно считать данные метки")
                        return
                    } else {
                        if let message = message {
                            if let payload = message.records.first {
                                let(text, _) = payload.wellKnownTypeTextPayload()
                                if text == "0101" {
                                    API.requestCheckID(identifier: self.identifier, inside: {
                                        session.alertMessage = "Доступ подтвержден, добро пожаловать"
                                        session.invalidate()
                                    }, outside: {
                                        session.alertMessage = "Доступ подтвержден, до свидания"
                                        session.invalidate()
                                    }, close: {
                                        session.invalidate(errorMessage: "Доступ запрещен")
                                    }, fail: { (errorString) in
                                        session.invalidate(errorMessage: errorString)
                                    })
                                    return
                                } else {
                                    session.invalidate(errorMessage: "Считана неверная метка")
                                    return
                                }
                            }
                        }
                    }
                    session.invalidate(errorMessage: "Ошибка при считывании метки")
                })
            })
        })
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Сессия недействительна",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        self.session = nil
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {}
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NDEF Сообщение обнаружено")
    }
    //BLE Methods
    func startBLEScanning() {
        print("Started Scanning!")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        //print(peripheral)
        if peripheral.name == deviceName {
            print("Discovered \(deviceName)")
            centralManager.stopScan()
            print("Stopped Scanning")
            // Set as the peripheral to use and establish connection
            self.peripheral = peripheral
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        print("Did connect to peripheral.")
        AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком установлено")
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "FFE0"), CBUUID(string: "FEE0")])
        let state = peripheral.state == CBPeripheralState.connected ? "yes" : "no"
        print("Connected:\(state)")
        API.requestForRoom(identifier: identifier, status: "connect", inside: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком установлено")
        }, outside: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком разорвано")
        }, close: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Неверный запрос")
        }, fail: { (errorString) in
            AppDelegate.shared.sendNotification(title: "Внимание", description: errorString)
        })
    }
    
    func discoverDevices() {
        if centralManager.state == .poweredOn {
            print("discovering devices")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Checking state")
        switch central.state {
        case .poweredOff:
            print("CoreBluetooth BLE hardware is powered off")
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
            if BLStatus {
                discoverDevices()
            }
        case .resetting:
            print("CoreBluetooth BLE hardware is resetting")
        case .unauthorized:
            print("CoreBluetooth BLE state is unauthorized")
        case .unknown:
            print("CoreBluetooth BLE state is unknown")
        case .unsupported:
            print("CoreBluetooth BLE hardware is unsupported on this platform")
        default:
            print("unknown")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        if error != nil {
            print(error?.localizedDescription as Any)
        }
        print(peripheral)
        for svc in peripheral.services! {
            print("Service \(svc)\n")
            print("Discovering Characteristics for Service : \(svc)")
            peripheral.discoverCharacteristics([CBUUID(string: "FFE0"), CBUUID(string: "FEE0")], for: svc)
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print(peripheral)
        print("CONNECTION WAS DISCONNECTED")
        AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком разорвано")
        API.requestForRoom(identifier: identifier, status: "disconnect", inside: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком установлено")
        }, outside: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Соединение с BLE маяком разорвано")
        }, close: {
            AppDelegate.shared.sendNotification(title: "Внимание", description: "Неверный запрос")
        }, fail: { (errorString) in
            AppDelegate.shared.sendNotification(title: "Внимание", description: errorString)
        })
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to peripheral.")
    }
    //Controller Design
    func setDisplayView() {
        view.backgroundColor = .white
        navigationItem.title = "Функции Пользователя"
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Выйти",
                                                                                          style: .done,
                                                                                          target: self,
                                                                                          action: #selector(exitController))
        view.addSubview(backgroundView)
        backgroundView.image = #imageLiteral(resourceName: "wing-black-and-white-architecture-window-building-skyscraper-46913-pxhere.com")
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        NFCButton.frame = CGRect(x: view.center.x - 110, y: view.center.y - 50, width: 220, height: 50)
        NFCButton.layer.cornerRadius = 5
        NFCButton.backgroundColor = .link
        NFCButton.setTitle("Запросить доступ", for: .normal)
        NFCButton.titleLabel?.font =  UIFont(name: "Helvetica", size: 16)
        NFCButton.addTarget(self, action: #selector(didTapNFCButton), for: .touchUpInside)
        view.addSubview(NFCButton)
        
        BLEButton.layer.cornerRadius = 5
        BLEButton.backgroundColor = .link
        BLEButton.setTitle("Включить обнаружение", for: .normal)
        BLEButton.titleLabel?.font =  UIFont(name: "Helvetica", size: 16)
        BLEButton.addTarget(self, action: #selector(didTapBLEButton), for: .touchUpInside)
        view.addSubview(BLEButton)
        
        BLEButton.translatesAutoresizingMaskIntoConstraints = false
        BLEButton.topAnchor.constraint(equalTo: NFCButton.bottomAnchor, constant: 30).isActive = true
        BLEButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        BLEButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        BLEButton.centerXAnchor.constraint(equalTo: NFCButton.centerXAnchor).isActive = true
        
        openRoomsButton.layer.cornerRadius = 5
        openRoomsButton.backgroundColor = .link
        openRoomsButton.setTitle("Сотрудники в комнатах", for: .normal)
        openRoomsButton.titleLabel?.font =  UIFont(name: "Helvetica", size: 16)
        openRoomsButton.addTarget(self, action: #selector(didTapRoomsButton), for: .touchUpInside)
        view.addSubview(openRoomsButton)
        
        openRoomsButton.translatesAutoresizingMaskIntoConstraints = false
        openRoomsButton.topAnchor.constraint(equalTo: BLEButton.bottomAnchor, constant: 30).isActive = true
        openRoomsButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        openRoomsButton.widthAnchor.constraint(equalToConstant: 220).isActive = true
        openRoomsButton.centerXAnchor.constraint(equalTo: NFCButton.centerXAnchor).isActive = true
    }
}
