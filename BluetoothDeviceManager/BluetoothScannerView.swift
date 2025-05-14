//
//  BluetoothScannerView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import SwiftUI
import CoreBluetooth
import SwiftData

struct BluetoothScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    
    @State private var isScanning = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { peripheral in
                        Button(action: {
                            saveDevice(peripheral: peripheral)
                            dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                Text(peripheral.name ?? "Unknown Device")
                                    .font(.headline)
                                Text(peripheral.identifier.uuidString)
                                    .font(.subheadline)
                                if let rssi = bluetoothManager.rssiValues[peripheral.identifier] {
                                    Text("Signal: \(rssi) dBm")
                                        .font(.caption)
                                }
                            }
                            .padding(15)
                        }
                        .frame(maxWidth: .infinity)
                        .background {
                            Rectangle()
                                .fill(Color.gray.opacity(0.5))
                                .cornerRadius(10)
                        }
                    }
                }
                .contentMargins(.top, 20, for: .scrollContent)
                .contentMargins(.horizontal, 20.0, for: .scrollContent)
                .contentMargins(.bottom, 20, for: .scrollContent)
            }
            .navigationTitle("Discover Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isScanning ? "Stop" : "Scan") {
                        toggleScan()
                    }
                }
            }
            .overlay {
                if bluetoothManager.discoveredDevices.isEmpty && isScanning {
                    ContentUnavailableView("Scanning for devices...", systemImage: "dot.radiowaves.left.and.right")
                } else if bluetoothManager.discoveredDevices.isEmpty {
                    ContentUnavailableView("Tap Scan to begin", systemImage: "bonjour")
                }
            }
            .refreshable {
                bluetoothManager.startScanning()
            }
            .onAppear {
                bluetoothManager.startScanning()
                isScanning = true
            }
            .onDisappear {
                bluetoothManager.stopScanning()
                isScanning = false
            }
            .frame(maxWidth: .infinity)
            .background {
                Color.white
            }
            .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
        }
    }
    
    private func toggleScan() {
        if isScanning {
            bluetoothManager.stopScanning()
        } else {
            bluetoothManager.startScanning()
        }
        isScanning.toggle()
    }
    
    private func saveDevice(peripheral: CBPeripheral) {
        let device = BluetoothDevice(
            id: peripheral.identifier,
            name: peripheral.name ?? "Unknown",
            uuid: peripheral.identifier.uuidString,
            rssi: bluetoothManager.rssiValues[peripheral.identifier] ?? 0,
            lastSeen: Date(),
            state: .disconnected
        )
        modelContext.insert(device)
    }
}
