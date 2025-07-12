@preconcurrency import Foundation

extension NotificationCenter {

    public protocol _MainActorMessage: _SendableMetatype, Sendable {

        associatedtype Subject

        static var name: Notification.Name { get }

        @MainActor static func makeMessage(_ notification: Notification) -> Self?

        @MainActor static func makeNotification(_ message: Self) -> Notification
    }
}

extension NotificationCenter {

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    public func addObserver<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._MainActorMessage
    >(
        of subject: Message.Subject,
        for identifier: Identifier,
        using observer: @escaping @MainActor (Message) -> Void
    ) -> NotificationCenter._ObservationToken
    where Message == Identifier.MessageType, Message.Subject: AnyObject {
        let nsObserver = addObserver(forName: Message.name, object: subject, queue: .main) {
            notification in
            Task { @MainActor in
                guard let message = Message.makeMessage(notification) else { return }
                observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    public func addObserver<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._MainActorMessage
    >(
        of subject: Message.Subject.Type,
        for identifier: Identifier,
        using observer: @escaping @MainActor (Message) -> Void
    ) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType {
        let nsObserver = addObserver(forName: Message.name, object: nil, queue: .main) {
            notification in
            Task { @MainActor in
                guard let message = Message.makeMessage(notification) else { return }
                observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    public func addObserver<Message: NotificationCenter._MainActorMessage>(
        of subject: Message.Subject? = nil,
        for messageType: Message.Type,
        using observer: @escaping @MainActor (Message) -> Void
    ) -> NotificationCenter._ObservationToken where Message.Subject: AnyObject {
        let nsObserver = addObserver(forName: Message.name, object: subject, queue: .main) {
            notification in
            Task { @MainActor in
                guard let message = Message.makeMessage(notification) else { return }
                observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @MainActor public func post<Message: NotificationCenter._MainActorMessage>(
        _ message: Message,
        subject: Message.Subject
    ) where Message.Subject: AnyObject {
        var notification = Message.makeNotification(message)
        notification = Notification(
            name: notification.name,
            object: subject,
            userInfo: notification.userInfo
        )
        post(notification)
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter API instead")
    @MainActor public func post<Message: NotificationCenter._MainActorMessage>(
        _ message: Message,
        subject: Message.Subject.Type = Message.Subject.self
    ) {
        let notification = Message.makeNotification(message)
        post(notification)
    }
}
