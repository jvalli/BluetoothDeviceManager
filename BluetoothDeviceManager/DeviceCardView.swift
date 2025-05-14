//
//  DeviceCardView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import SwiftUI

public struct DeviceCardView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var device: BluetoothDevice
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @State var rotation: CGFloat = 0
    @State var connecting: Bool = false
    
    public var body: some View {
        FlipCardView(
            front: {
                front
            },
            back: {
                back
            }
        )
    }
    
    @ViewBuilder
    var front: some View {
        ZStack {
            backgroundView
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text(device.name)
                    .font(.title)
                Text("UUID: \(device.uuid)")
                    .font(.body)
                HStack {
                    Text("RSSI: \(device.rssi)")
                        .font(.footnote)
                    Spacer()
                    Text("Last seen: \(device.lastSeen.formatted())")
                        .font(.footnote)
                }
                HStack {
                    let deviceConnected = device.state == .connected ? "Connected" : "Disconnected"
                    Text(bluetoothManager.connectionStatus[device.id] as? String ?? deviceConnected)
                        .font(.body)
                    Spacer()
                    if let peripheral = bluetoothManager.discoveredDevices.first(where: { $0.identifier == device.id }) {
                        Button {
                            let lastState = device.state
                            guard lastState != .connecting, lastState != .disconnecting else { return }
                            device.state = lastState == .connected ? .disconnecting : .connecting
                            connecting = true
                            Task {
                                do {
                                    if device.state == .connecting {
                                        let _ = try await bluetoothManager.connect(to: peripheral)
                                    } else {
                                        let _ = try await bluetoothManager.disconnect(from: peripheral)
                                    }
                                    Task { @MainActor in
                                        let previousState = device.state
                                        device.state = previousState == .connecting ? .connected : .disconnected
                                        connecting = device.state == .connected
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                            Image(systemName: device.state == .connected ? "link.circle" : "link")
                               .foregroundColor(.yellow)
                               .font(.system(size: 28))
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Spacer()
            }
            .padding(20)
        }
        .cornerRadius(10)
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
    
    @ViewBuilder
    var back: some View {
        ZStack {
            // Image placeholder
            Rectangle()
                .fill(Color.background.opacity(0.6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
            VStack(spacing: 30) {
                Text("Do you want to delete the device '\(device.name)'?")
                    .font(.title2)
                Button {
                    Task {
                        deleteDevice()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 44))
                }
            }
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .foregroundColor(.background.opacity(0.6))
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .frame(width: geometry.size.width / 2, height: geometry.size.height * 1.2)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.white.opacity(0.6), .white.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom)
                    )
                    .padding(.vertical, -(geometry.size.height / 4))
                    .rotationEffect(.degrees(rotation))
                    .mask {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(lineWidth: 5)
                            .frame(width: geometry.size.width - 4, height: geometry.size.height - 4)
                    }
                    .opacity(connecting ? 1 : 0)
            }
        }
    }
    
    private func deleteDevice() {
        modelContext.delete(device)
    }
}
