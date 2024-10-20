//
//  FireStoreView.swift
//  localData-tutorial
//
//  Created by bobo on 3/3/24.
//

import SwiftUI

struct FireStoreView: View {
    
    
    @EnvironmentObject var todosViewModel : TodosViewModel
    
    @State fileprivate var userInput: String = ""
    
    @State var isShowingEmptyInputDialog : Bool = false
    
    let emptyStringInfoMsg: String = "할일이 비어 있습니다."
    
    // 할일 수정여부
    @State fileprivate var isEditingTodo: Bool = false
    
    @State fileprivate var editingTodo: Todo? = nil
    
    @State fileprivate var editingTodoInput: String = ""
    
    
    
    
    var body: some View {
        VStack{
         inputHeaderView
         todoListView
        }.alert("안내", isPresented: $isShowingEmptyInputDialog, actions: {
            Button("닫기") {
                isShowingEmptyInputDialog = false
            }
        }, message: {
            Text("할일을 입력해주세요")
        })
        .alert("수정", isPresented: $isEditingTodo, actions: {
            
            TextField("할일을 입력해주세요", text: $editingTodoInput)
            Button("닫기") {
                isEditingTodo = false}
            Button("완료") {
                
                guard let editingTodo = self.editingTodo else { return }
                
                todosViewModel.storeEditTodo(editTodo: editingTodo, editUserInput: editingTodoInput) }
        }, message: {
            Text("할일을 입력해주세요")
        })
    }
    
    
    var inputHeaderView : some View {
        HStack{
            TextField("할일을 입력해주세요", text: $userInput)
                .textFieldStyle(.roundedBorder)
            
            Button("할일 추가", action: {
                
                if userInput.count < 1 {
                    isShowingEmptyInputDialog = true
                    return
                }
                
                todosViewModel.storeAddTodo(userInput: userInput)
                
                userInput = ""
                
            }).buttonStyle(.borderedProminent)
        }.padding(.horizontal, 10)
    }
    
    var todoListView : some View {
        List {
            if todosViewModel.fireStoreTodoList.isEmpty {
                Text("할 일이 없습니다.")
            } else {
                ForEach($todosViewModel.fireStoreTodoList, id: \.id, content: { todo in
                    
                    FirestoreTodoLowView(todo: todo.wrappedValue, onToggleChanged: {
                        
                        todosViewModel.storeIsDoneUpdate(editTodo: todo.wrappedValue)
                        
                    })
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button("수정", action: {
                            
                            editingTodo = todo.wrappedValue
                            editingTodoInput = todo.content.wrappedValue
                            
                            isEditingTodo = true
                    
                        }).tint(Color.orange)
                    }
                    
                }).onDelete(perform: { indexSet in
                    todosViewModel.storeDeleteTodo(indexSet: indexSet)
                })
                
            }
        }.environment(\.locale, Locale(identifier: "ko"))
    }
}
