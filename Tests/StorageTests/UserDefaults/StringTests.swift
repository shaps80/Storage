import XCTest
@testable import Storage

final class StringTests: XCTestCase {

    func testNonOptional() {
        let before = "foo"
        let after = "bar"
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testOptional() {
        let before = Optional<String>.none
        let after = "bar"
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testKVO() {
        let before = "foo"
        let after = "bar"
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        UserDefaults(suiteName: #file)?.set(after, forKey: type(of: self).key)
        XCTAssertEqual(store.wrappedValue, after)
    }

}

extension StringTests {
    typealias T = String
    private static let key = "string"

    func storage(_ value: T) -> DefaultsStorage<T> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return Storage(wrappedValue: value, type(of: self).key, store: store)
    }

    func storage(_ value: T?) -> Storage<UserDefaults, T?> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return Storage(type(of: self).key, store: store)
    }
}
