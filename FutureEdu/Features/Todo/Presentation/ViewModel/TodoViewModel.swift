//
//  TodoViewModel.swift
//  FutureEdu
//

import Foundation

enum TodoFilter: Int {
    case all = 0
    case active = 1
    case completed = 2
}

final class TodoViewModel {
    private let repository: TodoRepository
    private(set) var allTodos: [TodoItem] = []

    var currentFilter: TodoFilter = .all {
        didSet {
            onTodosUpdated?()
        }
    }

    var onTodosUpdated: (() -> Void)?

    var filteredTodos: [TodoItem] {
        switch currentFilter {
        case .all:
            return allTodos
        case .active:
            return allTodos.filter { !$0.isCompleted }
        case .completed:
            return allTodos.filter { $0.isCompleted }
        }
    }

    var numberOfTodos: Int {
        return filteredTodos.count
    }

    var remainingCount: Int {
        return allTodos.filter { !$0.isCompleted }.count
    }

    var completedCount: Int {
        return allTodos.filter { $0.isCompleted }.count
    }

    init(repository: TodoRepository = TodoRepositoryImpl()) {
        self.repository = repository
        loadTodos()
    }

    func loadTodos() {
        allTodos = repository.getTodos()
        onTodosUpdated?()
    }

    func addTodo(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let newTodo = TodoItem(title: trimmedTitle)
        allTodos.insert(newTodo, at: 0)
        persistTodos()
    }

    func toggleTodo(at index: Int) {
        guard index >= 0 && index < filteredTodos.count else { return }
        let targetId = filteredTodos[index].id

        if let originalIndex = allTodos.firstIndex(where: { $0.id == targetId }) {
            allTodos[originalIndex].isCompleted.toggle()
            persistTodos()
        }
    }

    func deleteTodo(at index: Int) {
        guard index >= 0 && index < filteredTodos.count else { return }
        let targetId = filteredTodos[index].id

        if let originalIndex = allTodos.firstIndex(where: { $0.id == targetId }) {
            allTodos.remove(at: originalIndex)
            persistTodos()
        }
    }

    func item(at index: Int) -> TodoItem? {
        guard index >= 0 && index < filteredTodos.count else { return nil }
        return filteredTodos[index]
    }

    private func persistTodos() {
        repository.saveTodos(allTodos)
        onTodosUpdated?()
    }
}
