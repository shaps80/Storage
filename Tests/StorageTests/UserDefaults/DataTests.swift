import XCTest
@testable import Storage

final class DataTests: XCTestCase {

    func testNonOptional() {
        let before = Data([1, 2, 3])
        let after = Data([3, 2, 1])
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testOptional() {
        let before = Optional<Data>.none
        let after = Data([3, 2, 1])
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        store.wrappedValue = after
        XCTAssertEqual(store.wrappedValue, after)
    }

    func testKVO() {
        let before = Data([1, 2, 3])
        let after = Data([3, 2, 1])
        let store = storage(before)
        XCTAssertEqual(store.wrappedValue, before)
        UserDefaults(suiteName: #file)?.set(after, forKey: type(of: self).key)
        XCTAssertEqual(store.wrappedValue, after)
    }

}

private extension DataTests {
    typealias T = Data
    private static let key = "data"

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
