//
//  ContentView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import SwiftUI
import SwiftData
import CoreBluetooth

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BluetoothDevice.lastSeen, order: .reverse) private var devices: [BluetoothDevice]
    
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var showingScanner = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.vertical) {
                    ForEach(devices) { device in
                        DeviceCardView(device: device)
                            .environmentObject(bluetoothManager)
                            .containerRelativeFrame(.vertical, count: 1, spacing: 1)
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.5)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                    .offset(x: phase.isIdentity ? 0 : 8)
                            }
                            .shadow(color: .blue.opacity(0.8), radius: 8, x: 5, y: 10)
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .contentMargins(.top, 35, for: .scrollContent)
                .contentMargins(.horizontal, 20.0, for: .scrollContent)
                .contentMargins(.bottom, 40, for: .scrollContent)
            }
            .navigationTitle("Bluetooth Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingScanner = true
                    }) {
                        Label("Add Device", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BluetoothScannerView()
                    .environmentObject(bluetoothManager)
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
    
    private func deleteDevices(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(devices[index])
        }
    }
}

#Preview {
    ContentView()
}
