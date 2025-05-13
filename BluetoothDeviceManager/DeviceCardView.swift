//
//  DeviceCardView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import SwiftUI

public struct DeviceCardView: View {
    @ObservedObject var device: BluetoothDevice
    @EnvironmentObject private var bluetoothManager: BluetoothManager
    @State var rotation: CGFloat = 0
    @State var connecting: Bool = false
    
    public var body: some View {
        FlipExpandView(
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
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.5))
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(width: geometry.size.width / 2, height: geometry.size.height * 1.2)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.green.opacity(0.75), .white.opacity(0.75)]),
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
                    let deviceConnected = device.connected ? "Connected" : "Disconnected"
                    Text(bluetoothManager.connectionStatus[device.id] as? String ?? deviceConnected)
                        .font(.body)
                    Spacer()
                    if let peripheral = bluetoothManager.discoveredDevices.first(where: { $0.identifier == device.id }) {
                        Button {
                            connecting = !device.connected
                            Task {
                                do {
                                    if !device.connected {
                                        let _ = try await bluetoothManager.connect(to: peripheral)
                                    } else {
                                        let _ = try await bluetoothManager.disconnect(from: peripheral)
                                    }
                                    Task { @MainActor in
                                        device.connected.toggle()
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } label: {
                           Image(systemName: device.connected ? "link.circle" :"link")
                               .foregroundColor(.white)
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
        ZStack(alignment: .topTrailing) {
            // Image placeholder
            Rectangle()
                .fill(Color.blue.opacity(0.5))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(20)
            
        }
    }
    
    @ViewBuilder
    var connectingAnimation: some View {
        
    }
}
