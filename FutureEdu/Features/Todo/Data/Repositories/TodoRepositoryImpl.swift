//
//  TodoRepositoryImpl.swift
//  FutureEdu
//

import Foundation

final class TodoRepositoryImpl: TodoRepository {
    private let storageKey = "saved_todos_key"
    private let storageService: LocalStorageServiceProtocol

    init(storageService: LocalStorageServiceProtocol? = nil) {
        self.storageService = storageService ?? LocalStorageService.shared
    }

    func getTodos() -> [TodoItem] {
        return storageService.load([TodoItem].self, forKey: storageKey) ?? []
    }

    func saveTodos(_ todos: [TodoItem]) throws {
        try storageService.save(todos, forKey: storageKey)
    }
}
