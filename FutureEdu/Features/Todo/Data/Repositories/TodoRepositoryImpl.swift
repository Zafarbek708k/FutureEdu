//
//  TodoRepositoryImpl.swift
//  FutureEdu
//

import Foundation

final class TodoRepositoryImpl: TodoRepository {
    private let storageKey = "saved_todos_key"
    private let storageService: LocalStorageServiceProtocol

    init(storageService: LocalStorageServiceProtocol = LocalStorageService.shared) {
        self.storageService = storageService
    }

    func getTodos() -> [TodoItem] {
        return storageService.load([TodoItem].self, forKey: storageKey) ?? []
    }

    func saveTodos(_ todos: [TodoItem]) {
        try? storageService.save(todos, forKey: storageKey)
    }
}
