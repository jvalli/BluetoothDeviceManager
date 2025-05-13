//
//  BluetoothDevice.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import Foundation
import SwiftData

@Model
class BluetoothDevice: ObservableObject, Identifiable {
    var id: UUID
    var name: String
    var uuid: String
    var rssi: Int
    var lastSeen: Date
    var connected: Bool
    
    init(id: UUID, name: String, uuid: String, rssi: Int, lastSeen: Date, connected: Bool) {
        self.id = id
        self.name = name
        self.uuid = uuid
        self.rssi = rssi
        self.lastSeen = lastSeen
        self.connected = connected
    }
}
