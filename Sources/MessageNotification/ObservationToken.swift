@preconcurrency import Foundation

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