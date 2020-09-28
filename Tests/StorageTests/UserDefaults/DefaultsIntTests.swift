import XCTest
@testable import Storage

final class DefaultsIntTests: XCTestCase {

    func testNonOptional() {
        let before = 1
        let after = 2
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testOptional() {
        let before = Optional<Int>.none
        let after = 1
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testKVO() {
        let before = 1
        let after = 2
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        UserDefaults(suiteName: #file)?.set(after, forKey: type(of: self).key)
        XCTAssertEqual(store.wrappedValue, after)
    }

}

private extension DefaultsIntTests {
    typealias T = Int
    private static let key = "int"

    func storage(_ value: T) -> DefaultsStorage<T> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return DefaultsStorage(wrappedValue: value, type(of: self).key, store: store)
    }

    func storage(_ value: T?) -> DefaultsStorage<T?> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return DefaultsStorage(type(of: self).key, store: store)
    }
}
