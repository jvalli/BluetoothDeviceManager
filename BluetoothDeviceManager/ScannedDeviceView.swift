//
//  ScannedDeviceView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/14/25.
//

import CoreBluetooth
import SwiftUI

public struct ScannedDeviceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var peripheral: CBPeripheral
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    
    public var body: some View {
        Button(action: {
            saveDevice(peripheral: peripheral)
            dismiss()
        }) {
            VStack(alignment: .leading) {
                Text(peripheral.name ?? "Unknown Device")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                Text(peripheral.identifier.uuidString)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 1, y: 1)
                if let rssi = bluetoothManager.rssiValues[peripheral.identifier] {
                    Text("Signal: \(rssi) dBm")
                        .font(.caption)
                }
            }
            .padding(15)
        }
        .frame(maxWidth: .infinity)
        .background (
            Color(Color.background)
                .shadow(.drop(color: .black.opacity(0.1), radius: 6, y: 3))
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
