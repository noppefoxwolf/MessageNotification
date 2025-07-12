import Foundation
import Testing

struct TestAsyncMessage: NotificationCenter.AsyncMessage, Sendable {
    typealias Subject = TestSubject
    
    let text: String
    
    static let name = Notification.Name("TestAsyncMessage")
    
    static func makeMessage(_ notification: Notification) -> Self? {
        guard let text = notification.userInfo?["text"] as? String else { return nil }
        return TestAsyncMessage(text: text)
    }
    
    static func makeNotification(_ message: Self) -> Notification {
        Notification(name: name, userInfo: ["text": message.text])
    }
}

struct TestMainActorMessage: NotificationCenter.MainActorMessage {
    typealias Subject = TestSubject
    
    let value: Int
    
    static let name = Notification.Name("TestMainActorMessage")
    
    @MainActor static func makeMessage(_ notification: Notification) -> Self? {
        guard let value = notification.userInfo?["value"] as? Int else { return nil }
        return TestMainActorMessage(value: value)
    }
    
    @MainActor static func makeNotification(_ message: Self) -> Notification {
        Notification(name: name, userInfo: ["value": message.value])
    }
}

class TestSubject: NSObject, @unchecked Sendable {}

@Suite("MessageNotification Tests")
struct MessageNotificationTests {
    
    @Suite("AsyncMessage Protocol")
    struct AsyncMessageTests {
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("Observer with specific subject")
        func observerWithSubject() async {
            let notificationCenter = NotificationCenter()
            let subject = TestSubject()
            let expectedMessage = TestAsyncMessage(text: "test")
            
            let expectation = AsyncMessageExpectation()
            
            let token = notificationCenter.addObserver(
                of: subject,
                for: TestAsyncMessage.self,
                using: { message in
                    await expectation.fulfill(with: message)
                }
            )
            
            notificationCenter.post(expectedMessage, subject: subject)
            
            let receivedMessage = await expectation.value
            #expect(receivedMessage.text == expectedMessage.text)
            
            notificationCenter.removeObserver(token)
        }
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("Observer with type")
        func observerWithType() async {
            let notificationCenter = NotificationCenter()
            let expectedMessage = TestAsyncMessage(text: "type test")
            
            let expectation = AsyncMessageExpectation()
            
            let token = notificationCenter.addObserver(
                for: TestAsyncMessage.self,
                using: { message in
                    await expectation.fulfill(with: message)
                }
            )
            
            notificationCenter.post(expectedMessage)
            
            let receivedMessage = await expectation.value
            #expect(receivedMessage.text == expectedMessage.text)
            
            notificationCenter.removeObserver(token)
        }
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("AsyncStream messages")
        func asyncStreamMessages() async throws {
            let notificationCenter = NotificationCenter()
            let subject = TestSubject()
            
            let messageStream = notificationCenter.messages(
                of: subject,
                for: TestAsyncMessage.self,
                bufferSize: 5
            )
            
            let messages = [
                TestAsyncMessage(text: "first"),
                TestAsyncMessage(text: "second"),
                TestAsyncMessage(text: "third")
            ]
            
            Task { @Sendable in
                for message in messages {
                    notificationCenter.post(message, subject: subject)
                }
            }
            
            var receivedMessages: [TestAsyncMessage] = []
            var iterator = messageStream.makeAsyncIterator()
            
            for _ in 0..<messages.count {
                if let message = try await iterator.next() {
                    receivedMessages.append(message)
                }
            }
            
            #expect(receivedMessages.count == messages.count)
            for (received, expected) in zip(receivedMessages, messages) {
                #expect(received.text == expected.text)
            }
        }
    }
    
    @Suite("MainActorMessage Protocol")
    struct MainActorMessageTests {
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("Observer functionality")
        @MainActor
        func observerFunctionality() async {
            let notificationCenter = NotificationCenter()
            let subject = TestSubject()
            let expectedMessage = TestMainActorMessage(value: 42)
            
            let expectation = MainActorMessageExpectation()
            
            let token = notificationCenter.addObserver(
                of: subject,
                for: TestMainActorMessage.self,
                using: { message in
                    expectation.fulfill(with: message)
                }
            )
            
            async let receivedMessage = expectation.value
            notificationCenter.post(expectedMessage, subject: subject)
            
            await #expect(receivedMessage.value == expectedMessage.value)
            
            notificationCenter.removeObserver(token)
        }
    }
    
    @Suite("Message Infrastructure")
    struct MessageInfrastructureTests {
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("Message identifier functionality")
        func messageIdentifier() {
            let asyncIdentifier = NotificationCenter.BaseMessageIdentifier<TestAsyncMessage>()
            let mainActorIdentifier = NotificationCenter.BaseMessageIdentifier<TestMainActorMessage>()
            
            #expect(type(of: asyncIdentifier) == NotificationCenter.BaseMessageIdentifier<TestAsyncMessage>.self)
            #expect(type(of: mainActorIdentifier) == NotificationCenter.BaseMessageIdentifier<TestMainActorMessage>.self)
        }
        
        @available(iOS 26.0, macOS 26.0, *)
        @Test("Observation token equality")
        func observationTokenEquality() async {
            let notificationCenter = NotificationCenter()
            let subject = TestSubject()
            
            let token1 = notificationCenter.addObserver(
                of: subject,
                for: TestAsyncMessage.self,
                using: { _ in }
            )
            
            let token2 = notificationCenter.addObserver(
                of: subject,
                for: TestAsyncMessage.self,
                using: { _ in }
            )
            
            #expect(token1 == token1)
            #expect(token1 != token2)
            #expect(token1.hashValue == token1.hashValue)
            #expect(token1.hashValue != token2.hashValue)
            
            notificationCenter.removeObserver(token1)
            notificationCenter.removeObserver(token2)
        }
    }
}

actor AsyncMessageExpectation {
    private var continuation: CheckedContinuation<TestAsyncMessage, Never>?
    
    var value: TestAsyncMessage {
        get async {
            await withCheckedContinuation { continuation in
                self.continuation = continuation
            }
        }
    }
    
    func fulfill(with message: TestAsyncMessage) {
        continuation?.resume(returning: message)
        continuation = nil
    }
}

@MainActor
class MainActorMessageExpectation {
    private var continuation: CheckedContinuation<TestMainActorMessage, Never>?
    var cached: TestMainActorMessage? = nil
    
    var value: TestMainActorMessage {
        get async {
            if let cached {
                return cached
            } else {
                return await withCheckedContinuation { continuation in
                    self.continuation = continuation
                }
            }
        }
    }
    
    func fulfill(with message: TestMainActorMessage) {
        if continuation == nil {
            cached = message
        }
        continuation?.resume(returning: message)
        continuation = nil
    }
}
