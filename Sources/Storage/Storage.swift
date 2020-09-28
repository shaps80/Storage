import Foundation
import SwiftUI

/*
 Inspiration was drawn from Xavier Lowmiller's post here: https://xavierlowmiller.github.io/blog/2020/09/04/iOS-13-AppStorage
 I decided not to contribute as I wanted to provide a more complete implemenatation that also included additional storage options, i.e. Ubiquitous storage
 */

@frozen @propertyWrapper
public struct Storage<Value>: DynamicProperty {

    @ObservedObject
    private var _value: RefStorage<Value>

    private let commitHandler: (Value) -> Void

    public var wrappedValue: Value {
        get { _value.value }
        nonmutating set {
            commitHandler(newValue)
            _value.value = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }

    private init(value: Value, store: UserDefaults, key: String, get: @escaping (Any?) -> Value?, set: @escaping (Value) -> Void) {
        self._value = RefStorage(value: value, store: store, key: key, transform: get)
        self.commitHandler = set
    }

}

public extension Storage {

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Bool {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Int {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Double {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == String {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == URL {
        let store = store ?? .standard
        let value = store.url(forKey: key) ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { ($0 as? String).flatMap(URL.init) },
                  set: { store.set($0, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value == Data {
        let store = store ?? .standard
        let value = store.data(forKey: key) ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

}

public extension Storage where Value: ExpressibleByNilLiteral {

    init(_ key: String, store: UserDefaults? = nil) where Value == Bool? {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? .none
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(_ key: String, store: UserDefaults? = nil) where Value == Int? {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? .none
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(_ key: String, store: UserDefaults? = nil) where Value == Double? {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? .none
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(_ key: String, store: UserDefaults? = nil) where Value == String? {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? .none
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

    init(_ key: String, store: UserDefaults? = nil) where Value == URL? {
        let store = store ?? .standard
        let value = store.url(forKey: key) ?? .none
        self.init(value: value, store: store, key: key,
                  get: { ($0 as? String).flatMap(URL.init) },
                  set: { store.set($0?.absoluteString, forKey: key) })
    }

    init(_ key: String, store: UserDefaults? = nil) where Value == Data? {
        let store = store ?? .standard
        let value = store.value(forKey: key) as? Value ?? .none
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.set($0, forKey: key) })
    }

}

public extension Storage where Value: RawRepresentable {

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value.RawValue == String {
        let store = store ?? .standard
        let rawValue = store.value(forKey: key) as? Value.RawValue
        let value = rawValue.flatMap(Value.init) ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.setValue($0.rawValue, forKey: key) })
    }

    init(wrappedValue: Value, _ key: String, store: UserDefaults? = nil) where Value.RawValue == Int {
        let store = store ?? .standard
        let rawValue = store.value(forKey: key) as? Value.RawValue
        let value = rawValue.flatMap(Value.init) ?? wrappedValue
        self.init(value: value, store: store, key: key,
                  get: { $0 as? Value },
                  set: { store.setValue($0.rawValue, forKey: key) })
    }

}

private final class RefStorage<Value>: NSObject, ObservableObject {

    @Published
    fileprivate var value: Value

    private let defaultValue: Value
    private let store: UserDefaults
    private let key: String
    private let transform: (Any?) -> Value?

    deinit {
        store.removeObserver(self, forKeyPath: key)
    }

    init(value: Value, store: UserDefaults, key: String, transform: @escaping (Any?) -> Value?) {
        self.value = value
        self.defaultValue = value
        self.store = store
        self.key = key
        self.transform = transform

        super.init()
        store.addObserver(self, forKeyPath: key, options: .new, context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        value = change?[.newKey].flatMap(transform) ?? defaultValue
    }

}

public protocol KeyValueStore {
    func value(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStore { }
extension NSUbiquitousKeyValueStore: KeyValueStore { }
