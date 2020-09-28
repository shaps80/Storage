import XCTest
@testable import Storage

final class CloudBoolTests: XCTestCase {

    func testNonOptional() {
        let before = true
        let after = false
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testOptional() {
        let before = Optional<Bool>.none
        let after = false
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testKVO() {
        let before = true
        let after = false
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        UserDefaults(suiteName: #file)?.set(after, forKey: type(of: self).key)
        XCTAssertEqual(store.wrappedValue, after)
    }

}

extension CloudBoolTests {
    typealias T = Bool
    private static let key = "bool"

    func storage(_ value: T) -> Storage<T> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return Storage(wrappedValue: value, type(of: self).key, store: store)
    }

    func storage(_ value: T?) -> Storage<T?> {
        let store = UserDefaults(suiteName: #file)
        store?.removePersistentDomain(forName: #file)
        return Storage(type(of: self).key, store: store)
    }
}
