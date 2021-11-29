//
//  UserDefault.swift.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/12/4.
//

import Foundation

@propertyWrapper
public struct UserDefaultsWrapper<Value> {
    let key: String
    let defaultValue: Value
    var storage: UserDefaults = .standard

    public init(key: String, defaultValue: Value, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: Value {
        get {
            let value = storage.value(forKey: key) as? Value
            return value ?? defaultValue
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
}

public extension UserDefaultsWrapper where Value: ExpressibleByNilLiteral {
    init(key: String, storage: UserDefaults = .standard) {
        self.init(key: key, defaultValue: nil, storage: storage)
    }
}
