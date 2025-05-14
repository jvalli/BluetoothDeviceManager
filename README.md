# Overview
Bluetooth Device Manager is a SwiftUI application that allows users to:

- Discover nearby Bluetooth Low Energy (BLE) devices
- Save discovered devices to persistent storage
- Manage a list of saved Bluetooth devices
- Connect to and interact with saved devices

The app leverages CoreBluetooth for device discovery and connection, and SwiftData for persistent storage of device information.

# Features

## 1. Device Discovery

- Scan for nearby BLE devices in real-time
- View device names, UUIDs, and signal strength (RSSI)
- Pull-to-refresh functionality for manual scanning

## 2. Device Management

- Save discovered devices to persistent storage
- View saved devices with detailed information (name, UUID, signal strength, last seen)
- Tap the cards to turn 180 and delete device
- Sort devices by last seen timestamp

## 3. Device Connection

- One-tap connection to saved devices
- Visual connection status indicator
- Manual disconnect option
- Automatic service discovery after connection

## 4. User Interface
- Clean, intuitive SwiftUI interface
- Status bar showing current connection state
- Visual feedback for all operations
- Empty state views when no devices are available

# Technical Implementation

## Architecture

- MVVM Pattern: Using ObservableObject for Bluetooth management
- SwiftData: For persistent storage of device information
- CoreBluetooth: For all Bluetooth operations

## Key Components

- BluetoothDevice Model: Stores device information
  - UUID, name, RSSI, last seen timestamp
- BluetoothManager: Handles all Bluetooth operations
  - Scanning, connecting, disconnecting
  - Service and characteristic discovery
- ContentView: Main device list view
- BluetoothScannerView: Device discovery view

# Requirements

- iOS 17.0+ (for SwiftData support)
- Xcode 15+
- Physical iOS device (Bluetooth doesn't work on simulator)
- Bluetooth permission in Info.plist

# Installation

- Clone the repository
- Open the project in Xcode 15+
- Build and run on a physical iOS device

# Usage Instructions

## Discovering Devices

- Tap the "+" button in the main view
- The app will automatically start scanning
- View discovered devices in the list
- Tap any device to save it to your collection

## Managing Devices

- Save a device: Tap any device in the scanner view
- Delete a device: Tap the cards to turn 180 and delete device from main list
- Refresh the list: Pull down on the device list

## Connecting to Devices

- Tap the connection icon (link) next to any device
- View connection status in the status bar at the top
- Tap "Disconnect" to terminate the connection

## Permissions

The app requires the following permissions which are automatically configured:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to discover nearby devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth access to discover nearby devices</string>
```

# Known Limitations

- Bluetooth on Simulator: The iOS simulator doesn't support Bluetooth, so testing requires a physical device
- Background Operation: The app doesn't currently support background Bluetooth operations
- Service Interaction: While the app discovers services and characteristics, it doesn't yet include specific service interaction

# Future Enhancements

- Add ability to interact with specific services/characteristics
- Implement background Bluetooth operations
- Add device grouping/categorization
- Include more detailed connection statistics
- Add support for Bluetooth device configuration

# Dependencies

- SwiftUI
- CoreBluetooth framework
- SwiftData (iOS 17+)

# Support
For issues or feature requests, please open an issue in the GitHub repository.

# License
MIT License - Free for use and modification with attribution.