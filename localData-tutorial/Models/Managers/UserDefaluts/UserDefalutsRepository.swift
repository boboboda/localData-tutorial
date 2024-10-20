//
//  UserDefalutsRepository.swift
//  localData-tutorial
//
//  Created by bobo on 3/2/24.
//

import Foundation

class UserDefalutsRepository: TodoListRepository {
    
    var todoList: [Todo] = []
    
    init() {
        print(#fileID, #function, #line, "- ")
        todoList = fetchTodos()
        
    }
    
    func fetchTodos() -> [Todo] {
        return UserDefaultsManager.shared.fetchTodoList()
    }
    
    func deleteTodo(uuid: UUID) ->[Todo] {
        todoList.removeAll(where: {$0.uuid == uuid})
        
        UserDefaultsManager.shared.setTodoList(updatedTodos: todoList)
        
        return todoList
    }
    
    func addTodo(_ newTodo: Todo) -> [Todo] {
        
        todoList.insert(newTodo, at:0)
        
        UserDefaultsManager.shared.setTodoList(updatedTodos: todoList)
        
        return todoList
    }
    
    func updateTodo(_ updatingTodo: Todo, editUserInput: String? = nil, isDone: Bool? = nil) ->[Todo] {
        if let index = todoList.firstIndex(where: { updatingTodo.uuid == $0.uuid}) {
            
            // 내용 수정
            if let editUserInput = editUserInput {
                todoList[index].content = editUserInput
            }
            
            // 완료여부
            if let isDone = isDone {
                todoList[index].isDone = isDone
            }
            
            
            UserDefaultsManager.shared.setTodoList(updatedTodos: todoList)
            
            return todoList
        } else {
            return []
        }
    }
    
    func clearAllTodos() {
        UserDefaultsManager.shared.clearAllTodos()
    }
}
