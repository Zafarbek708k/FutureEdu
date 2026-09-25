//
//  LocalStorageService.swift
//  FutureEdu
//

import Foundation

protocol LocalStorageServiceProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T?
    func remove(forKey key: String)
}

final class LocalStorageService: LocalStorageServiceProtocol {
    static let shared = LocalStorageService()
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func save<T: Encodable>(_ object: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        userDefaults.set(data, forKey: key)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }

    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
