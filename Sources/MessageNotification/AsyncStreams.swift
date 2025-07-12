@preconcurrency import Foundation

extension NotificationCenter {
    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    public func messages<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(of subject: Message.Subject, for identifier: Identifier, bufferSize limit: Int = 10)
        -> AsyncStream<Message>
    where Message == Identifier.MessageType, Message.Subject: AnyObject {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: subject, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { @Sendable _ in
                self.removeObserver(observer)
            }
        }
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    public func messages<
        Identifier: NotificationCenter._MessageIdentifier,
        Message: NotificationCenter._AsyncMessage
    >(of subject: Message.Subject.Type, for identifier: Identifier, bufferSize limit: Int = 10)
        -> AsyncStream<Message> where Message == Identifier.MessageType
    {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: nil, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { @Sendable _ in
                self.removeObserver(observer)
            }
        }
    }

    @_disfavoredOverload
    @available(iOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    @available(macOS, deprecated: 26.0, message: "Use the standard NotificationCenter.notifications API instead")
    public func messages<Message: NotificationCenter._AsyncMessage>(
        of subject: Message.Subject? = nil,
        for messageType: Message.Type,
        bufferSize limit: Int = 10
    ) -> AsyncStream<Message> where Message.Subject: AnyObject {
        AsyncStream(Message.self, bufferingPolicy: .bufferingNewest(limit)) { continuation in
            let observer = addObserver(forName: Message.name, object: subject, queue: nil) {
                notification in
                guard let message = Message.makeMessage(notification) else { return }
                continuation.yield(message)
            }

            continuation.onTermination = { @Sendable _ in
                self.removeObserver(observer)
            }
        }
    }
}