//
//  BluetoothDevice.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import Foundation
import SwiftData

public enum BluetoothDeviceState: Int, @unchecked Sendable, Codable, CaseIterable, Hashable {
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}

@Model
class BluetoothDevice: ObservableObject, Identifiable {
    var id: UUID
    var name: String
    var uuid: String
    var rssi: Int
    var lastSeen: Date
    var state: BluetoothDeviceState
    
    init(id: UUID, name: String, uuid: String, rssi: Int, lastSeen: Date, state: BluetoothDeviceState) {
        self.id = id
        self.name = name
        self.uuid = uuid
        self.rssi = rssi
        self.lastSeen = lastSeen
        self.state = state
    }
}
