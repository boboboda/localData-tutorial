//
//  TodosViewModel.swift
//  localData-tutorial
//
//  Created by bobo on 3/3/24.
//

import Foundation
import Combine
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI


class TodosViewModel: ObservableObject {
    
    @Published var todoList : [Todo] = []
    
    @Published var localTodoList: [Todo] = []
    
    @Published var fireStoreTodoList : [Todo] = []
    
    var ref: DatabaseReference?
    
    let db = Firestore.firestore()
    
    //
    var repository: TodoListRepository = CoreDataTodoListRespository()
    
    // userDefaluts
    //    var repository: TodoListRepository = UserDefalutsRepository()
    
    init() {
        
        if(fireStoreTodoList.isEmpty) {
            firestoreFetched()
        }
        
        
        print(#fileID, #function, #line, "- ")
        
        localTodoList = repository.fetchTodos()
        
        
        ref = Database
            .database(url: "https://ios-buyoungsil-todo-default-rtdb.asia-southeast1.firebasedatabase.app").reference().child("todos")
        
        // Listen for deleted comments in the Firebase database
        // 삭제가 일어났을 때 만 받겠다.
        ref?.observe(.childRemoved, with: {(snapshot) -> Void in
            guard let index : Int = self.todoList.firstIndex(where: {
                $0.refId == snapshot.key }) else { return }
            
            withAnimation {
                self.todoList.remove(at: index)
            }
        })
        
        // 앱이 최초실행 될 때 초기화됨
        // 데이터 추가가 일어났을때만 받겠다
        ref?.observe(.childAdded, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            let todo = value?["todo"] as? String ?? ""
            let isDone = value?["isDone"] as? Bool ?? false
            let createdAt = value?["createdAt"] as? String ?? ""
            
            let addedTodoEntity = Todo(refId: snapshot.key, isDone:isDone, createdAt: createdAt.toDate(), content: todo)
            
            
            print(#fileID, #function, #line, "- addedTodoEntity: \(addedTodoEntity)")
            
            // 1. 데이터 추가
            withAnimation{
                self.todoList.append(addedTodoEntity)
            }
            
        })
        
        // 특정 데이터가 변경 되었을 때 만 받겠다.
        
        ref?.observe(.childChanged, with: { (snapshot) -> Void in
            let value = snapshot.value as? NSDictionary
            let todo = value?["todo"] as? String ?? ""
            let isDone = value?["isDone"] as? Bool ?? false
            let createdAt = value?["createdAt"] as? String ?? ""
            let updatedAt = value?["updatedAt"] as? String ?? ""
            
            let changedTodoEntity = Todo(refId: snapshot.key,
                                         isDone: isDone,
                                         createdAt: createdAt.toDate(),
                                         updatedAt: updatedAt.toDate(),
                                         content: todo)
            
            print(#fileID, #function, #line, "- changedTodoEntity: \(changedTodoEntity)")
            
            guard let index : Int = self.todoList.firstIndex(where: {$0.refId == snapshot.key}) else
            { return }
            
            // 데이터 변경
            withAnimation{
                self.todoList[index] = changedTodoEntity
            }
            
            
        })
    }
    //realtime
    
    //MARK: 릴타임
    
    /// 아이템 삭제
    /// - Parameter indexSet: <#indexSet description#>
    func deleteTodo(indexSet: IndexSet){
        print(#fileID, #function, #line, "- \(indexSet)")
        
        guard let deletingTodo = indexSet.map({todoList[$0]}).first else { return }
        
        guard let refId = deletingTodo.refId else { return }
        
        self.ref?.child(refId).removeValue()
    }
    
    
    
    /// 데이터 추가
    /// - Parameter userInput: <#userInput description#>
    func addTodo(userInput: String) {
        print(#fileID, #function, #line, "- ")
        
        // 오토레퍼런스 아이디 생성
        // .child(uuid) -> 커스텀 가능
        self.ref?
            .childByAutoId()
            .setValue([
                "todo": userInput,
                "isDone": false,
                "createdAt": Date().toString
            ] as [String: Any])
        
    }
    
    
    func editTodo(refId:String, userInput: String) {
        
        print(#fileID, #function, #line, "- \(refId)")
        
        self.ref?.child(refId)
            .updateChildValues(["todo": userInput, "updatedAt": Date().toString], withCompletionBlock: {_,_ in })
    }
    
    func updateIsDone(refId:String) {
        guard let foundItem = todoList.first(where: {$0.refId == refId}) else { return }
        
        self.ref?.child(refId)
            .updateChildValues(["isDone": !foundItem.isDone, "updatedAt": Date().toString], withCompletionBlock: {_,_ in})
    }
    
    
    //MARK: 파이어스토어
    
    func firestoreFetched() {
        let todoRef = db.collection("todos")
        
        todoRef.getDocuments() { (querySnapshot, err) in
            if err != nil {
                print(#fileID, #function, #line, "- loadTodoData() err ")
            } else {
                let fetchedTodo = Todo.todos(from: querySnapshot!)
                
                self.fireStoreTodoList.append(contentsOf: fetchedTodo)
            }
            
        }
    }
    
    
    func storeAddTodo(userInput: String) {
        let newDocRef = db.collection("todos").document()
        
        let newTodo = Todo(refId: "\(newDocRef.documentID)", content: userInput)
        
        newDocRef.setData(newTodo.dictionary){ err in
            if let err = err {
                print(err)
            } else {
                print("success")
                
                withAnimation{
                    self.fireStoreTodoList.append(newTodo)
                }
            }
            
        }
    }
    
    //데이터 삭제
    func storeDeleteTodo(indexSet: IndexSet){
        
        
        guard let deletingTodo = indexSet.map({ fireStoreTodoList[$0] }).first,
              let refId = deletingTodo.refId else {
            return
        }
        
        let todoRef = db.collection("todos").document("\(refId)")
        todoRef.delete()
        
        withAnimation{
            self.fireStoreTodoList.remove(atOffsets: indexSet)
        }
        
    }
    
    //데이터 수정
    
    func storeEditTodo(editTodo: Todo, editUserInput: String) {
        
        
        guard let refId = editTodo.refId else { return }
        let documentReference = db.collection("todos").document(refId)
        
        //            let updateData: [String: Any] = [
        //                "content": editTodo.content,
        //                "isDone": editTodo.isDone,
        //                "updatedAt": Date().toString
        //            ]
        
        
        guard let index : Int = self.fireStoreTodoList.firstIndex(where: {$0.refId == editTodo.refId}) else
        { return }
        
        let updatedTodo = Todo(refId: editTodo.refId!,
                               isDone: editTodo.isDone,
                               createdAt: editTodo.createdAt,
                               updatedAt: Date(),
                               content: editUserInput)
        
        documentReference.setData(updatedTodo.dictionary) { error in
            if let error = error {
                
                print(#fileID, #function, #line, "- \(error)")
                
            } else {
                
                print(#fileID, #function, #line, "- editing success")
                
                withAnimation{
                    self.fireStoreTodoList[index] = updatedTodo
                }
            }
        }
    }
    
    func storeIsDoneUpdate(editTodo: Todo) {
        guard let refId = editTodo.refId else { return }
        let documentReference = db.collection("todos").document(refId)
        
        guard let index : Int = self.fireStoreTodoList.firstIndex(where: {$0.refId == editTodo.refId}) else
        { return }
        
        let updatedTodo = Todo(refId: editTodo.refId!,
                               isDone: !editTodo.isDone,
                               createdAt: editTodo.createdAt,
                               updatedAt: Date(),
                               content: editTodo.content)
        
        documentReference.setData(updatedTodo.dictionary) { error in
            if let error = error {
                
                print(#fileID, #function, #line, "- \(error)")
                
            } else {
                
                print(#fileID, #function, #line, "- editing success")
                
                withAnimation{
                    self.fireStoreTodoList[index] = updatedTodo
                }
            }
        }
    }
    
    
    
    //MARK: 로컬데이터
    func isDoneUpdate(_ isDone: Bool, todo: Todo) {
        
        // `todoList` 내의 해당 Todo 객체 찾기
        
        if let foundItem = localTodoList.first(where: { todo.uuid == $0.uuid }) {
            
            localTodoList = repository.updateTodo(foundItem, editUserInput: nil, isDone: isDone)
        }
    }
    
    
    func localDataDelete(indexSet: IndexSet) {
        
        guard let index = indexSet.first else { return }
        
        let idsToDelete = localTodoList[index].uuid
        
        localTodoList = repository.deleteTodo(uuid: idsToDelete)
    }
    
    
    func localDataClearAll() {
        repository.clearAllTodos()
        localTodoList.removeAll()
    }
    
    
    func localDataAddTodo(newTodo: Todo) {
        localTodoList = repository.addTodo(newTodo)
    }
    
    func localDataUpdateTodo(editingTodo:Todo, editUserInput: String) {
        localTodoList = repository.updateTodo(editingTodo, editUserInput: editUserInput, isDone: nil)
    }
    
}
