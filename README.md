# MessageNotification

A Swift package that provides type-safe message passing extensions for NotificationCenter with async/await support.

## Features

- Type-safe message protocol for NotificationCenter
- Async/await observer pattern
- Automatic observation token management
- Cross-platform support (iOS 17+, macOS 14+)

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/noppefoxwolf/MessageNotification", from: "1.0.0")
]
```

## Usage

### Define a Message Type

```swift
struct MyMessage: NotificationCenter._AsyncMessage {
    typealias Subject = MyViewController
    
    static let name = Notification.Name("MyMessage")
    let data: String
    
    static func makeMessage(_ notification: Notification) -> Self? {
        guard let data = notification.userInfo?["data"] as? String else { return nil }
        return MyMessage(data: data)
    }
    
    static func makeNotification(_ message: Self) -> Notification {
        return Notification(name: name, userInfo: ["data": message.data])
    }
}
```

### Observe Messages

```swift
let token = NotificationCenter.default.addObserver(
    of: viewController,
    for: MyMessage.self
) { message in
    print("Received: \(message.data)")
}
```

### Post Messages

```swift
let message = MyMessage(data: "Hello World")
NotificationCenter.default.post(message, subject: viewController)
```

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.1+

## License

This project is available under the MIT license.