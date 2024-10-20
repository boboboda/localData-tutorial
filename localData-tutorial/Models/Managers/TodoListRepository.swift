//
//  TodoListRepository.swift
//  localData-tutorial
//
//  Created by bobo on 3/2/24.
//

import Foundation

protocol TodoListRepository {
    var todoList: [Todo]  { get }
    func fetchTodos() -> [Todo]
    func deleteTodo(uuid: UUID) -> [Todo]
    func addTodo(_ newTodo: Todo) -> [Todo]
    func updateTodo(_ updatingTodo: Todo, editUserInput: String?, isDone: Bool?) ->[Todo]
    func clearAllTodos()
}
