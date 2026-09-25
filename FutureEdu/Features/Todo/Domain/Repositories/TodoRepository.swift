//
//  TodoRepository.swift
//  FutureEdu
//

import Foundation

protocol TodoRepository {
    func getTodos() -> [TodoItem]
    func saveTodos(_ todos: [TodoItem])
}
