//
//  BluetoothManager.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import CoreBluetooth
import Combine

enum BluetoothManagerError: Error {
    case unknown
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var rssiValues: [UUID: Int] = [:]
    @Published var connectionStatus: [UUID: String?] = [:]
    private var continuationConnet: CheckedContinuation<CBPeripheral, Error>?
    private var continuationDisconnet: CheckedContinuation<CBPeripheral, Error>?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        discoveredDevices.removeAll()
        rssiValues.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral) async throws -> CBPeripheral {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuationConnet = continuation
            self?.centralManager.connect(peripheral, options: nil)
            Task { @MainActor in
                self?.connectionStatus[peripheral.identifier] = "Connecting..."
            }
        }
    }
    
    func disconnect(from peripheral: CBPeripheral) async throws -> CBPeripheral {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuationDisconnet = continuation
            self?.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
        rssiValues[peripheral.identifier] = RSSI.intValue
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        connectionStatus[peripheral.identifier] = "Connected to \(peripheral.name ?? "device")"
        peripheral.discoverServices(nil)
        continuationConnet?.resume(returning: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionStatus[peripheral.identifier] = "Failed to connect: \(error?.localizedDescription ?? "Unknown error")"
        if let error {
            continuationConnet?.resume(throwing: error)
        } else {
            continuationConnet?.resume(throwing: BluetoothManagerError.unknown)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error {
            continuationDisconnet?.resume(throwing: error)
        } else {
            connectionStatus[peripheral.identifier] = "Disconnected"
            continuationDisconnet?.resume(returning: peripheral)
        }
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Handle characteristics discovery if needed
    }
}
