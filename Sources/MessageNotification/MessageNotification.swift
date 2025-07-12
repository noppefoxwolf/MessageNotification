@preconcurrency public import Foundation

extension NotificationCenter {

    public protocol _AsyncMessage: Sendable {

        associatedtype Subject

        static var name: Notification.Name { get }

        static func makeMessage(_ notification: Notification) -> Self?

        static func makeNotification(_ message: Self) -> Notification
    }
}

extension NotificationCenter {

    public func addObserver<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(
        of subject: Message.Subject,
        for identifier: Identifier,
        using observer: @escaping @Sendable (Message) async -> Void
    ) -> NotificationCenter._ObservationToken
    where Message == Identifier.MessageType, Message.Subject: AnyObject {
        let nsObserver = addObserver(forName: Message.name, object: subject, queue: nil) {
            notification in
            guard let message = Message.makeMessage(notification) else { return }
            Task {
                await observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    public func addObserver<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(
        of subject: Message.Subject.Type,
        for identifier: Identifier,
        using observer: @escaping @Sendable (Message) async -> Void
    ) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType {
        let nsObserver = addObserver(forName: Message.name, object: nil, queue: nil) {
            notification in
            guard let message = Message.makeMessage(notification) else { return }
            Task {
                await observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    public func addObserver<Message: NotificationCenter._AsyncMessage>(
        of subject: Message.Subject? = nil,
        for messageType: Message.Type,
        using observer: @escaping @Sendable (Message) async -> Void
    ) -> NotificationCenter._ObservationToken where Message.Subject: AnyObject {
        let nsObserver = addObserver(forName: Message.name, object: subject, queue: nil) {
            notification in
            guard let message = Message.makeMessage(notification) else { return }
            Task {
                await observer(message)
            }
        }
        return _ObservationToken(observer: nsObserver, notificationCenter: self)
    }

    public func post<Message: NotificationCenter._AsyncMessage>(
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

    public func post<Message: NotificationCenter._AsyncMessage>(
        _ message: Message,
        subject: Message.Subject.Type = Message.Subject.self
    ) {
        let notification = Message.makeNotification(message)
        post(notification)
    }
}

extension NotificationCenter {

    public protocol _MainActorMessage: _SendableMetatype, Sendable {

        associatedtype Subject

        static var name: Notification.Name { get }

        @MainActor static func makeMessage(_ notification: Notification) -> Self?

        @MainActor static func makeNotification(_ message: Self) -> Notification
    }
}

extension NotificationCenter {

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

    @MainActor public func post<Message: NotificationCenter._MainActorMessage>(
        _ message: Message,
        subject: Message.Subject.Type = Message.Subject.self
    ) {
        let notification = Message.makeNotification(message)
        post(notification)
    }
}

extension NotificationCenter {

    public protocol _MessageIdentifier {

        associatedtype MessageType
    }

    public struct _BaseMessageIdentifier<MessageType>: NotificationCenter._MessageIdentifier,
        Sendable
    {

        public init() where MessageType: NotificationCenter._MainActorMessage {
        }

        public init() where MessageType: NotificationCenter._AsyncMessage {
        }
    }
}

extension NotificationCenter {

    public struct _ObservationToken: Hashable, @unchecked Sendable {

        internal let observer: NSObjectProtocol
        internal let notificationCenter: NotificationCenter

        internal init(observer: NSObjectProtocol, notificationCenter: NotificationCenter) {
            self.observer = observer
            self.notificationCenter = notificationCenter
        }

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (
            a: NotificationCenter._ObservationToken,
            b: NotificationCenter._ObservationToken
        ) -> Bool {
            ObjectIdentifier(a.observer) == ObjectIdentifier(b.observer)
        }

        /// Hashes the essential components of this value by feeding them into the
        /// given hasher.
        ///
        /// Implement this method to conform to the `Hashable` protocol. The
        /// components used for hashing must be the same as the components compared
        /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
        /// with each of these components.
        ///
        /// - Important: In your implementation of `hash(into:)`,
        ///   don't call `finalize()` on the `hasher` instance provided,
        ///   or replace it with a different instance.
        ///   Doing so may become a compile-time error in the future.
        ///
        /// - Parameter hasher: The hasher to use when combining the components
        ///   of this instance.
        public func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(observer))
        }

        /// The hash value.
        ///
        /// Hash values are not guaranteed to be equal across different executions of
        /// your program. Do not save hash values to use during a future execution.
        ///
        /// - Important: `hashValue` is deprecated as a `Hashable` requirement. To
        ///   conform to `Hashable`, implement the `hash(into:)` requirement instead.
        ///   The compiler provides an implementation for `hashValue` for you.
        public var hashValue: Int {
            var hasher = Hasher()
            hash(into: &hasher)
            return hasher.finalize()
        }
    }

    public func removeObserver(_ token: NotificationCenter._ObservationToken) {
        token.notificationCenter.removeObserver(token.observer)
    }
}

public protocol _SendableMetatype: ~Copyable, ~Escapable {}

extension NotificationCenter {
    @available(iOS 18.0, macOS 15.0, *)
    public func messages<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(of subject: Message.Subject, for identifier: Identifier, bufferSize limit: Int = 10)
        -> some AsyncSequence<Message, Never>
    where Message == Identifier.MessageType, Message.Subject: AnyObject {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: subject, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { _ in
                self.removeObserver(observer)
            }
        }
    }

    @available(iOS 18.0, macOS 15.0, *)
    public func messages<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(of subject: Message.Subject.Type, for identifier: Identifier, bufferSize limit: Int = 10)
        -> some AsyncSequence<Message, Never> where Message == Identifier.MessageType
    {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: nil, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { _ in
                self.removeObserver(observer)
            }
        }
    }

    @available(iOS 18.0, macOS 15.0, *)
    public func messages<Message: NotificationCenter._AsyncMessage>(
        of subject: Message.Subject? = nil,
        for messageType: Message.Type,
        bufferSize limit: Int = 10
    ) -> some AsyncSequence<Message, Never> where Message.Subject: AnyObject {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: subject, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { _ in
                self.removeObserver(observer)
            }
        }
    }

}
