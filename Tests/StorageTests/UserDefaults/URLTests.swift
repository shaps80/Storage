import XCTest
@testable import Storage

final class UrlTests: XCTestCase {

    func testNonOptional() {
        let before = URL(string: "foo")!
        let after = URL(string: "bar")!
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testOptional() {
        let before = Optional<URL>.none
        let after = URL(string: "bar")
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testKVO() {
        let before = URL(string: "foo")!
        let after = URL(string: "bar")!
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        UserDefaults(suiteName: #file)?.set(after.absoluteString, forKey: type(of: self).key)
        XCTAssertEqual(store.wrappedValue, after)
    }

}

private extension UrlTests {
    typealias T = URL
    private static let key = "url"

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
