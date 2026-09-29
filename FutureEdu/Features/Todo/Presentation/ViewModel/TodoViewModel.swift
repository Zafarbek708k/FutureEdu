//
//  TodoViewModel.swift
//  FutureEdu
//

import Foundation
import os

enum TodoFilter: Int, CaseIterable {
    case all = 0
    case active = 1
    case completed = 2
}

private let logger = Logger(subsystem: "uz.karimov.info.FutureEdu", category: "Todo")

@MainActor
final class TodoViewModel {
    private let repository: TodoRepository

    private(set) var allTodos: [TodoItem] = []
    /// Cached result of applying `currentFilter` to `allTodos`.
    private(set) var filteredTodos: [TodoItem] = []
    /// id -> index in `allTodos`, for O(1) lookups from the table view.
    private var indexById: [UUID: Int] = [:]

    var currentFilter: TodoFilter = .all {
        didSet {
            guard oldValue != currentFilter else { return }
            rebuildCaches()
            onTodosUpdated?()
        }
    }

    var onTodosUpdated: (() -> Void)?

    var remainingCount: Int {
        allTodos.reduce(0) { $0 + ($1.isCompleted ? 0 : 1) }
    }

    var completedCount: Int {
        allTodos.count - remainingCount
    }

    /// Texts for the empty-state view, depending on the active filter.
    var emptyState: (title: String, subtitle: String) {
        let key: String
        switch currentFilter {
        case .all: key = "todo.empty.all"
        case .active: key = "todo.empty.active"
        case .completed: key = "todo.empty.completed"
        }
        return (L10n.tr("\(key).title"), L10n.tr("\(key).subtitle"))
    }

    // Default arguments are evaluated in a nonisolated context, so MainActor-isolated
    // defaults (SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor) are resolved inside the body.
    init(repository: TodoRepository? = nil) {
        self.repository = repository ?? TodoRepositoryImpl()
        loadTodos()
    }

    // MARK: - Queries

    func item(id: UUID) -> TodoItem? {
        guard let index = indexById[id] else { return nil }
        return allTodos[index]
    }

    // MARK: - Commands

    func loadTodos() {
        allTodos = repository.getTodos()
        rebuildCaches()
        onTodosUpdated?()
    }

    func addTodo(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        allTodos.insert(TodoItem(title: trimmedTitle), at: 0)
        commit()
    }

    func toggleTodo(id: UUID) {
        guard let index = indexById[id] else { return }
        allTodos[index].isCompleted.toggle()
        commit()
    }

    func deleteTodo(id: UUID) {
        guard let index = indexById[id] else { return }
        allTodos.remove(at: index)
        commit()
    }

    // MARK: - Private

    private func commit() {
        rebuildCaches()
        do {
            try repository.saveTodos(allTodos)
        } catch {
            logger.error("Failed to save todos: \(error.localizedDescription, privacy: .public)")
        }
        onTodosUpdated?()
    }

    private func rebuildCaches() {
        indexById = Dictionary(uniqueKeysWithValues: allTodos.enumerated().map { ($1.id, $0) })

        switch currentFilter {
        case .all:
            filteredTodos = allTodos
        case .active:
            filteredTodos = allTodos.filter { !$0.isCompleted }
        case .completed:
            filteredTodos = allTodos.filter { $0.isCompleted }
        }
    }
}
