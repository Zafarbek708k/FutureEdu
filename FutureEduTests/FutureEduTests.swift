//
//  FutureEduTests.swift
//  FutureEduTests
//
//  Created by macbook on 14/06/26.
//

import Foundation
import Testing
@testable import FutureEdu

// MARK: - Test doubles

@MainActor
final class InMemoryTodoRepository: TodoRepository {
    var stored: [TodoItem]
    var saveCallCount = 0
    var shouldFailOnSave = false

    init(_ items: [TodoItem] = []) {
        self.stored = items
    }

    func getTodos() -> [TodoItem] { stored }

    func saveTodos(_ todos: [TodoItem]) throws {
        saveCallCount += 1
        if shouldFailOnSave { throw CocoaError(.fileWriteUnknown) }
        stored = todos
    }
}

// MARK: - TodoViewModel

@MainActor
struct TodoViewModelTests {

    @Test func loadsTodosFromRepository() {
        let repo = InMemoryTodoRepository([TodoItem(title: "A"), TodoItem(title: "B")])
        let vm = TodoViewModel(repository: repo)

        #expect(vm.allTodos.map(\.title) == ["A", "B"])
        #expect(vm.filteredTodos.count == 2)
    }

    @Test func addTrimsTitleAndInsertsAtTop() {
        let repo = InMemoryTodoRepository([TodoItem(title: "Old")])
        let vm = TodoViewModel(repository: repo)

        vm.addTodo(title: "  Read a book \n")

        #expect(vm.allTodos.first?.title == "Read a book")
        #expect(repo.stored.map(\.title) == ["Read a book", "Old"])
    }

    @Test func addIgnoresBlankTitle() {
        let repo = InMemoryTodoRepository()
        let vm = TodoViewModel(repository: repo)

        vm.addTodo(title: "   \n ")

        #expect(vm.allTodos.isEmpty)
        #expect(repo.saveCallCount == 0)
    }

    @Test func toggleById() throws {
        let item = TodoItem(title: "Task")
        let repo = InMemoryTodoRepository([item])
        let vm = TodoViewModel(repository: repo)

        vm.toggleTodo(id: item.id)
        #expect(try #require(vm.item(id: item.id)).isCompleted)
        #expect(repo.stored.first?.isCompleted == true)

        vm.toggleTodo(id: item.id)
        #expect(try #require(vm.item(id: item.id)).isCompleted == false)
    }

    @Test func toggleUnderFilterAffectsCorrectItem() {
        let a = TodoItem(title: "A", isCompleted: true)
        let b = TodoItem(title: "B")
        let c = TodoItem(title: "C", isCompleted: true)
        let vm = TodoViewModel(repository: InMemoryTodoRepository([a, b, c]))
        vm.currentFilter = .completed
        #expect(vm.filteredTodos.map(\.id) == [a.id, c.id])

        vm.toggleTodo(id: c.id)

        #expect(vm.filteredTodos.map(\.id) == [a.id])
        #expect(vm.item(id: a.id)?.isCompleted == true)
        #expect(vm.item(id: b.id)?.isCompleted == false)
    }

    @Test func deleteById() {
        let a = TodoItem(title: "A")
        let b = TodoItem(title: "B")
        let repo = InMemoryTodoRepository([a, b])
        let vm = TodoViewModel(repository: repo)

        vm.deleteTodo(id: a.id)

        #expect(vm.allTodos.map(\.id) == [b.id])
        #expect(vm.item(id: a.id) == nil)
        #expect(vm.item(id: b.id)?.title == "B")
        #expect(repo.stored.map(\.id) == [b.id])
    }

    @Test func unknownIdIsNoOp() {
        let repo = InMemoryTodoRepository([TodoItem(title: "A")])
        let vm = TodoViewModel(repository: repo)

        vm.toggleTodo(id: UUID())
        vm.deleteTodo(id: UUID())

        #expect(vm.allTodos.count == 1)
        #expect(repo.saveCallCount == 0)
    }

    @Test func filtersAndCounts() {
        let vm = TodoViewModel(repository: InMemoryTodoRepository([
            TodoItem(title: "A", isCompleted: true),
            TodoItem(title: "B"),
            TodoItem(title: "C")
        ]))

        #expect(vm.remainingCount == 2)
        #expect(vm.completedCount == 1)

        vm.currentFilter = .active
        #expect(vm.filteredTodos.map(\.title) == ["B", "C"])

        vm.currentFilter = .completed
        #expect(vm.filteredTodos.map(\.title) == ["A"])

        vm.currentFilter = .all
        #expect(vm.filteredTodos.count == 3)
    }

    @Test func emptyStateTextDependsOnFilter() {
        let vm = TodoViewModel(repository: InMemoryTodoRepository())
        let allTitle = vm.emptyState.title

        vm.currentFilter = .active
        #expect(vm.emptyState.title != allTitle)
    }

    @Test func notifiesOnEveryChange() {
        let item = TodoItem(title: "A")
        let vm = TodoViewModel(repository: InMemoryTodoRepository([item]))
        var calls = 0
        vm.onTodosUpdated = { calls += 1 }

        vm.addTodo(title: "B")
        vm.toggleTodo(id: item.id)
        vm.currentFilter = .active
        vm.currentFilter = .active   // same value -> no extra notification
        vm.deleteTodo(id: item.id)

        #expect(calls == 4)
    }

    @Test func saveFailureKeepsInMemoryState() {
        let repo = InMemoryTodoRepository()
        repo.shouldFailOnSave = true
        let vm = TodoViewModel(repository: repo)

        vm.addTodo(title: "A")

        #expect(vm.allTodos.map(\.title) == ["A"])
        #expect(repo.stored.isEmpty)
    }
}

// MARK: - TodoRepositoryImpl + LocalStorageService

// App types are MainActor-isolated (SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor).
@MainActor
struct TodoRepositoryImplTests {

    @Test func roundTripsThroughUserDefaults() throws {
        let suite = "FutureEduTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let repo = TodoRepositoryImpl(storageService: LocalStorageService(userDefaults: defaults))
        let items = [TodoItem(title: "A", isCompleted: true), TodoItem(title: "B")]

        try repo.saveTodos(items)

        #expect(repo.getTodos() == items)
    }

    @Test func returnsEmptyWhenNothingStored() throws {
        let suite = "FutureEduTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let repo = TodoRepositoryImpl(storageService: LocalStorageService(userDefaults: defaults))

        #expect(repo.getTodos().isEmpty)
    }
}
