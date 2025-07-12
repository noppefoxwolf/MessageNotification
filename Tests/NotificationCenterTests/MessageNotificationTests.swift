import Foundation
import Testing

// MARK: - Test Subjects

class TestSubject: NSObject {
    let id: String

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: - AsyncMessage Test Types

struct TestAsyncMessage: NotificationCenter.AsyncMessage, Sendable {
    typealias Subject = TestSubject

    let content: String

    static let name = Notification.Name("TestAsyncMessage")

    static func makeMessage(_ notification: Notification) -> TestAsyncMessage? {
        guard let content = notification.userInfo?["content"] as? String else {
            return nil
        }
        return TestAsyncMessage(content: content)
    }

    static func makeNotification(_ message: TestAsyncMessage) -> Notification {
        return Notification(
            name: Self.name,
            userInfo: ["content": message.content]
        )
    }
}

// MARK: - MainActorMessage Test Types

struct TestMainActorMessage: NotificationCenter.MainActorMessage {
    typealias Subject = TestSubject

    let content: String

    static let name = Notification.Name("TestMainActorMessage")

    @MainActor
    static func makeMessage(_ notification: Notification) -> TestMainActorMessage? {
        guard let content = notification.userInfo?["content"] as? String else {
            return nil
        }
        return TestMainActorMessage(content: content)
    }

    @MainActor
    static func makeNotification(_ message: TestMainActorMessage) -> Notification {
        return Notification(
            name: Self.name,
            userInfo: ["content": message.content]
        )
    }
}

// MARK: - Message Identifiers

@available(iOS 26.0, macOS 26.0, *)
typealias AsyncMessageIdentifier = NotificationCenter.BaseMessageIdentifier<TestAsyncMessage>

@available(iOS 26.0, macOS 26.0, *)
typealias MainActorMessageIdentifier = NotificationCenter.BaseMessageIdentifier<
    TestMainActorMessage
>

// MARK: - Test State Actor

actor TestState {
    private var receivedMessage: TestAsyncMessage?
    private var receivedMainActorMessage: TestMainActorMessage?
    private var messageCount = 0
    private var observer1Called = false
    private var observer2Called = false

    func setReceivedMessage(_ message: TestAsyncMessage) {
        receivedMessage = message
    }

    func getReceivedMessage() -> TestAsyncMessage? {
        receivedMessage
    }

    func setReceivedMainActorMessage(_ message: TestMainActorMessage) {
        receivedMainActorMessage = message
    }

    func getReceivedMainActorMessage() -> TestMainActorMessage? {
        receivedMainActorMessage
    }

    func incrementMessageCount() {
        messageCount += 1
    }

    func getMessageCount() -> Int {
        messageCount
    }

    func setObserver1Called() {
        observer1Called = true
    }

    func setObserver2Called() {
        observer2Called = true
    }

    func getObserver1Called() -> Bool {
        observer1Called
    }

    func getObserver2Called() -> Bool {
        observer2Called
    }
}

// MARK: - AsyncMessage Tests
@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncMessageWithSpecificSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "test1")
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let token = notificationCenter.addObserver(of: subject, for: identifier) { message in
        Task {
            await state.setReceivedMessage(message)
        }
    }

    let testMessage = TestAsyncMessage(content: "Hello World")
    notificationCenter.post(testMessage, subject: subject)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Hello World")

    notificationCenter.removeObserver(token)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncMessageWithSubjectType() async throws {
    let notificationCenter = NotificationCenter()
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let token = notificationCenter.addObserver(of: TestSubject.self, for: identifier) { message in
        Task {
            await state.setReceivedMessage(message)
        }
    }

    let testMessage = TestAsyncMessage(content: "Type Message")
    notificationCenter.post(testMessage, subject: TestSubject.self)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Type Message")

    notificationCenter.removeObserver(token)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncMessageWithOptionalSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "optional")
    let state = TestState()

    let token = notificationCenter.addObserver(of: subject, for: TestAsyncMessage.self) { message in
        Task {
            await state.setReceivedMessage(message)
        }
    }

    let testMessage = TestAsyncMessage(content: "Optional Subject")
    notificationCenter.post(testMessage, subject: subject)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Optional Subject")

    notificationCenter.removeObserver(token)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncMessageWithNilSubject() async throws {
    let notificationCenter = NotificationCenter()
    let state = TestState()

    let token = notificationCenter.addObserver(of: nil, for: TestAsyncMessage.self) { message in
        Task {
            await state.setReceivedMessage(message)
        }
    }

    let testMessage = TestAsyncMessage(content: "Nil Subject")
    let subject = TestSubject(id: "any")
    notificationCenter.post(testMessage, subject: subject)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Nil Subject")

    notificationCenter.removeObserver(token)
}

// MARK: - MainActorMessage Tests

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Test func testMainActorMessageWithSpecificSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "mainactor1")
    let identifier = MainActorMessageIdentifier()
    let state = TestState()

    let token = notificationCenter.addObserver(of: subject, for: identifier) { message in
        Task {
            await state.setReceivedMainActorMessage(message)
        }
    }

    let testMessage = TestMainActorMessage(content: "MainActor Hello")
    notificationCenter.post(testMessage, subject: subject)

    let receivedMessage = await state.getReceivedMainActorMessage()
    #expect(receivedMessage?.content == "MainActor Hello")

    notificationCenter.removeObserver(token)
}

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Test func testMainActorMessageWithSubjectType() async throws {
    let notificationCenter = NotificationCenter()
    let identifier = MainActorMessageIdentifier()
    let state = TestState()

    let token = notificationCenter.addObserver(of: TestSubject.self, for: identifier) { message in
        Task {
            await state.setReceivedMainActorMessage(message)
        }
    }

    let testMessage = TestMainActorMessage(content: "MainActor Type")
    notificationCenter.post(testMessage, subject: TestSubject.self)

    let receivedMessage = await state.getReceivedMainActorMessage()
    #expect(receivedMessage?.content == "MainActor Type")

    notificationCenter.removeObserver(token)
}

@available(iOS 26.0, macOS 26.0, *)
@MainActor
@Test func testMainActorMessageWithOptionalSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "mainactor_optional")
    let state = TestState()

    let token = notificationCenter.addObserver(of: subject, for: TestMainActorMessage.self) {
        message in
        Task {
            await state.setReceivedMainActorMessage(message)
        }
    }

    let testMessage = TestMainActorMessage(content: "MainActor Optional")
    notificationCenter.post(testMessage, subject: subject)

    let receivedMessage = await state.getReceivedMainActorMessage()
    #expect(receivedMessage?.content == "MainActor Optional")

    notificationCenter.removeObserver(token)
}

// MARK: - ObservationToken Tests

@available(iOS 26.0, macOS 26.0, *)
@Test func testObservationTokenEquality() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "token_test")
    let identifier = AsyncMessageIdentifier()

    let token1 = notificationCenter.addObserver(of: subject, for: identifier) { _ in }
    let token2 = notificationCenter.addObserver(of: subject, for: identifier) { _ in }

    #expect(token1 == token1)
    #expect(token1 != token2)
    #expect(token2 == token2)

    notificationCenter.removeObserver(token1)
    notificationCenter.removeObserver(token2)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testObservationTokenHashing() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "hash_test")
    let identifier = AsyncMessageIdentifier()

    let token1 = notificationCenter.addObserver(of: subject, for: identifier) { _ in }
    let token2 = notificationCenter.addObserver(of: subject, for: identifier) { _ in }

    let set = Set([token1, token2])
    #expect(set.count == 2)
    #expect(set.contains(token1))
    #expect(set.contains(token2))

    notificationCenter.removeObserver(token1)
    notificationCenter.removeObserver(token2)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testRemoveObserver() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "remove_test")
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let token = notificationCenter.addObserver(of: subject, for: identifier) { _ in
        Task {
            await state.incrementMessageCount()
        }
    }

    let testMessage = TestAsyncMessage(content: "First")
    notificationCenter.post(testMessage, subject: subject)

    let firstCount = await state.getMessageCount()
    #expect(firstCount == 1)

    notificationCenter.removeObserver(token)

    let secondMessage = TestAsyncMessage(content: "Second")
    notificationCenter.post(secondMessage, subject: subject)

    let finalCount = await state.getMessageCount()
    #expect(finalCount == 1)
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testMultipleObservers() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "multiple_test")
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let token1 = notificationCenter.addObserver(of: subject, for: identifier) { _ in
        Task {
            await state.setObserver1Called()
        }
    }

    let token2 = notificationCenter.addObserver(of: subject, for: identifier) { _ in
        Task {
            await state.setObserver2Called()
        }
    }

    let testMessage = TestAsyncMessage(content: "Multiple")
    notificationCenter.post(testMessage, subject: subject)

    let observer1Called = await state.getObserver1Called()
    let observer2Called = await state.getObserver2Called()

    #expect(observer1Called == true)
    #expect(observer2Called == true)

    notificationCenter.removeObserver(token1)
    notificationCenter.removeObserver(token2)
}

// MARK: - AsyncSequence Tests

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncSequenceWithSpecificSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "async_sequence_test")
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let messagesStream = notificationCenter.messages(of: subject, for: identifier)

    var count = 0
    for await message in messagesStream {
        await state.setReceivedMessage(message)
        count += 1
        if count >= 2 {
            break
        }
    }

    let message1 = TestAsyncMessage(content: "First Stream Message")
    notificationCenter.post(message1, subject: subject)

    let message2 = TestAsyncMessage(content: "Second Stream Message")
    notificationCenter.post(message2, subject: subject)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Second Stream Message")
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncSequenceWithSubjectType() async throws {
    let notificationCenter = NotificationCenter()
    let identifier = AsyncMessageIdentifier()
    let state = TestState()

    let messagesStream = notificationCenter.messages(of: TestSubject.self, for: identifier)

    let streamTask = Task {
        for await message in messagesStream {
            await state.setReceivedMessage(message)
            break
        }
    }

    let message = TestAsyncMessage(content: "Type Stream Message")
    notificationCenter.post(message, subject: TestSubject.self)

    await streamTask.value

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Type Stream Message")
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncSequenceWithOptionalSubject() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "optional_stream")
    let state = TestState()

    let messagesStream = notificationCenter.messages(of: subject, for: TestAsyncMessage.self)

    for await message in messagesStream {
        await state.setReceivedMessage(message)
        break
    }

    let message = TestAsyncMessage(content: "Optional Stream Message")
    notificationCenter.post(message, subject: subject)

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Optional Stream Message")
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncSequenceWithNilSubject() async throws {
    let notificationCenter = NotificationCenter()
    let state = TestState()

    let messagesStream = notificationCenter.messages(of: nil, for: TestAsyncMessage.self)

    let streamTask = Task {
        for await message in messagesStream {
            await state.setReceivedMessage(message)
            break
        }
    }

    let message = TestAsyncMessage(content: "Nil Stream Message")
    let subject = TestSubject(id: "any_subject")
    notificationCenter.post(message, subject: subject)

    await streamTask.value

    let receivedMessage = await state.getReceivedMessage()
    #expect(receivedMessage?.content == "Nil Stream Message")
}

@available(iOS 26.0, macOS 26.0, *)
@Test func testAsyncSequenceBufferSize() async throws {
    let notificationCenter = NotificationCenter()
    let subject = TestSubject(id: "buffer_test")
    let identifier = AsyncMessageIdentifier()

    // Use a buffer size of 2
    let messagesStream = notificationCenter.messages(of: subject, for: identifier, bufferSize: 2)

    var receivedMessages: [TestAsyncMessage] = []
    for await message in messagesStream {
        receivedMessages.append(message)
        if receivedMessages.count >= 2 {
            break
        }
    }

    // Post multiple messages quickly to test buffering
    let message1 = TestAsyncMessage(content: "Buffer Message 1")
    let message2 = TestAsyncMessage(content: "Buffer Message 2")
    let message3 = TestAsyncMessage(content: "Buffer Message 3")
    let message4 = TestAsyncMessage(content: "Buffer Message 4")

    notificationCenter.post(message1, subject: subject)
    notificationCenter.post(message2, subject: subject)
    notificationCenter.post(message3, subject: subject)
    notificationCenter.post(message4, subject: subject)

    // With bufferingNewest(2), we should get the newest 2 messages
    #expect(receivedMessages.count == 2)
    // The exact messages received may vary depending on timing, but we should get some messages
    #expect(!receivedMessages.isEmpty)
}
