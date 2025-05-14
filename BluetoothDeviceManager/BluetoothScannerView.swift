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
                    VStack {
                        ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { peripheral in
                            ScannedDeviceView(peripheral: peripheral)
                                .environmentObject(bluetoothManager)
                                .scrollTransition { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1.0 : 0.5)
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.3)
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.top, 20, for: .scrollContent)
                .contentMargins(.horizontal, 20.0, for: .scrollContent)
                .contentMargins(.bottom, 20, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
            }
            .navigationTitle("Discover Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        toggleScan()
                    }) {
                        Text(isScanning ? "Stop" : "Scan")
                            .foregroundStyle(.white)
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
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.background, for: .navigationBar)
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
