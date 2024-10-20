//
//  CoreDataTodoListRespository.swift
//  localData-tutorial
//
//  Created by bobo on 3/2/24.
//

import Foundation
import CoreData

class CoreDataTodoListRespository : TodoListRepository {
    
    //컨테이너
    lazy var persistentcontainer: NSPersistentContainer = {
        //디비 이름
        let container = NSPersistentContainer(name: "Todo_DB")
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // 모든 테이블 관리자, 중재자, 이 녀석의 허락을 받아서 모두 처리된다.
    fileprivate var context : NSManagedObjectContext {
        return self.persistentcontainer.viewContext
    }
    
    init() {
        self.todoList = fetchTodos()
    }
    
    // 모든 할일 가져오기
    var todoList: [Todo] = []
    
    func fetchTodos() -> [Todo] {
        
        let request : NSFetchRequest<TodoEntity>  = TodoEntity.fetchRequest() // FetchAll 요청
        
        do {
            let fetchedAllTodoEntities = try context.fetch(request) as [TodoEntity]
            
            let todos = fetchedAllTodoEntities.map{ Todo(entity: $0)}
            
            return todos
            
        } catch {
            print(#fileID, #function, #line, "- \(error)")
            return []

        }
    }
    
    
    /// 특정할일 삭제
    /// - Parameter uuid: 삭제할 할일 UUID
    /// - Returns: 삭제되고 업데이트된 할일 목록
    func deleteTodo(uuid: UUID) -> [Todo] {
        
        guard let foundTodoEntity = findTodo(uuid: uuid) else { return [] }
        
        context.delete(foundTodoEntity)
        
        do {
           try context.save()
            return fetchTodos()
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
        
    }
    
    
    
    /// 할일 추가하기
    /// - Parameter newTodo: 추가할 할일
    /// - Returns: 업데이트된 최신 업데이트 목록
    func addTodo(_ newTodo: Todo) -> [Todo] {
                
        let newTodoEntity = TodoEntity(context: context)
        newTodoEntity.uuid = newTodo.uuid
        newTodoEntity.content = newTodo.content
        newTodoEntity.isDone = newTodo.isDone
        newTodoEntity.createdAt = Date()
        
        context.insert(newTodoEntity)
        
        do {
           try context.save()
            return fetchTodos()
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    
    /// 할일 수정
    /// - Parameters:
    ///   - updatingTodo: 수정할 할일
    ///   - editUserInput: 업데이트 내용
    ///   - isDone: 완료 여부
    /// - Returns: 변경된 최신 할일 목록
    func updateTodo(_ updatingTodo: Todo, editUserInput: String?, isDone: Bool?) -> [Todo] {
        
        guard let foundTodoEntity = findTodo(uuid: updatingTodo.uuid) else { return []}
        
        if let editUserInput = editUserInput {
            foundTodoEntity.content = editUserInput
        }
        
        if let isDone = isDone  {
            foundTodoEntity.isDone = isDone
        }
        
        foundTodoEntity.updatedAt = Date()
        
        do {
           try context.save()
            return fetchTodos()
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    func clearAllTodos() {
        
        do {
            try context.execute(TodoEntity.DeleteAllRequest())
            print("모두 삭제 성공")
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
        
        }
    }
    
    
    
    
    
}


//MARK: - 헬퍼
extension CoreDataTodoListRespository {
    
    
    /// 메모 찾기
    /// - Parameter uuid: 찾을 메모 UUID
    /// - Returns: 찾은 메모 Entity
    fileprivate func findTodo(uuid: UUID) -> TodoEntity? {
        print(#fileID, #function, #line, "- comment")
        
        // 해당하는 UUID를 가진 todoEntity를 가져와라
        let request = TodoEntity.fetchRequest()
        request.predicate = TodoEntity
            .serchByUUIDPredicate
            .withSubstitutionVariables(["uuid" : uuid])
        
        do {
            let fetchedAllTodoEntities = try context.fetch(request) as [TodoEntity]
            
            return fetchedAllTodoEntities.first
            
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")

            return nil
        }
    }
}
