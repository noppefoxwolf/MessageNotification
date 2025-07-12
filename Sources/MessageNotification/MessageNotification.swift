public import Foundation

extension NotificationCenter {

    public protocol _AsyncMessage : Sendable {

        associatedtype Subject

        static var name: Notification.Name { get }

        static func makeMessage(_ notification: Notification) -> Self?

        static func makeNotification(_ message: Self) -> Notification
    }
}

extension NotificationCenter {

    public func addObserver<Identifier: NotificationCenter._MessageIdentifier, Message: NotificationCenter._AsyncMessage>(of subject: Message.Subject, for identifier: Identifier, using observer: @escaping @Sendable (Message) async -> Void) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType, Message.Subject : AnyObject {
        // TODO:
        fatalError()
    }

    public func addObserver<Identifier : NotificationCenter._MessageIdentifier, Message : NotificationCenter._AsyncMessage>(of subject: Message.Subject.Type, for identifier: Identifier, using observer: @escaping @Sendable (Message) async -> Void) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType {
        // TODO:
        fatalError()
    }

    public func addObserver<Message : NotificationCenter._AsyncMessage>(of subject: Message.Subject? = nil, for messageType: Message.Type, using observer: @escaping @Sendable (Message) async -> Void) -> NotificationCenter._ObservationToken where Message.Subject : AnyObject {
        // TODO:
        fatalError()
    }

    public func post<Message : NotificationCenter._AsyncMessage>(_ message: Message, subject: Message.Subject) where Message.Subject : AnyObject {
        // TODO:
    }

    public func post<Message : NotificationCenter._AsyncMessage>(_ message: Message, subject: Message.Subject.Type = Message.Subject.self) {
        // TODO:
    }
}

extension NotificationCenter {

    public protocol _MainActorMessage : _SendableMetatype {

        associatedtype Subject

        static var name: Notification.Name { get }

        @MainActor static func makeMessage(_ notification: Notification) -> Self?

        @MainActor static func makeNotification(_ message: Self) -> Notification
    }
}

extension NotificationCenter {
    
    public func addObserver<Identifier : NotificationCenter._MessageIdentifier, Message : NotificationCenter._MainActorMessage>(of subject: Message.Subject, for identifier: Identifier, using observer: @escaping @MainActor (Message) -> Void) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType, Message.Subject : AnyObject {
        // TODO:
        fatalError()
    }
    
    public func addObserver<Identifier : NotificationCenter._MessageIdentifier, Message : NotificationCenter._MainActorMessage>(of subject: Message.Subject.Type, for identifier: Identifier, using observer: @escaping @MainActor (Message) -> Void) -> NotificationCenter._ObservationToken where Message == Identifier.MessageType {
        // TODO:
        fatalError()
    }

    public func addObserver<Message : NotificationCenter._MainActorMessage>(of subject: Message.Subject? = nil, for messageType: Message.Type, using observer: @escaping @MainActor (Message) -> Void) -> NotificationCenter._ObservationToken where Message.Subject : AnyObject {
        // TODO:
        fatalError()
    }

    @MainActor public func post<Message : NotificationCenter._MainActorMessage>(_ message: Message, subject: Message.Subject) where Message.Subject : AnyObject {
        // TODO:
    }

    @MainActor public func post<Message : NotificationCenter._MainActorMessage>(_ message: Message, subject: Message.Subject.Type = Message.Subject.self) {
        // TODO:
    }
}

extension NotificationCenter {

    public protocol _MessageIdentifier {

        associatedtype MessageType
    }
    
    public struct _BaseMessageIdentifier<MessageType> : NotificationCenter._MessageIdentifier, Sendable {

        public init() where MessageType : NotificationCenter._MainActorMessage {
            // TODO:
        }

        public init() where MessageType : NotificationCenter._AsyncMessage {
            // TODO:
        }
    }
}

extension NotificationCenter {

    public struct _ObservationToken : Hashable, Sendable {

        /// Returns a Boolean value indicating whether two values are equal.
        ///
        /// Equality is the inverse of inequality. For any values `a` and `b`,
        /// `a == b` implies that `a != b` is `false`.
        ///
        /// - Parameters:
        ///   - lhs: A value to compare.
        ///   - rhs: Another value to compare.
        public static func == (a: NotificationCenter._ObservationToken, b: NotificationCenter._ObservationToken) -> Bool {
            // TODO:
            false
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
            // TODO:
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
            // TODO:
            0
        }
    }

    public func removeObserver(_ token: NotificationCenter._ObservationToken) {
        // TODO:
    }
}

public protocol _SendableMetatype: ~Copyable, ~Escapable {}
