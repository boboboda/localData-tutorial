//
//  localDataView.swift
//  localData-tutorial
//
//  Created by bobo on 3/3/24.
//

import SwiftUI

struct LocalDataView: View {
    
    @State private var filterOption: FilterOption = .all
    
    @State var showTextFeildAlert = false
    
    @State var showEditAlert = false
    
    @State var userInput = ""
    
    @State var editUserInput = ""
    
    @State private var searchText = ""
    
    @EnvironmentObject var todosViewModel : TodosViewModel
    
    @State var editingTodo = Todo()
    
    
    var filteredTodos: [Todo] {
        switch filterOption {
        case .all:
            return todosViewModel.localTodoList
        case .complete:
            return todosViewModel.localTodoList.filter { $0.isDone }
        case .incomplete:
            return todosViewModel.localTodoList.filter { !$0.isDone }
        }
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                Picker("Filter", selection: $filterOption) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }.pickerStyle(.segmented)
                
                List{
                    
                    ForEach(filteredTodos, id: \.id, content: { todo in
                        
                        TodoListRowView(aTodo: todo, onToggleChanged: { changedValue in
                           
                            todosViewModel.isDoneUpdate(changedValue, todo: todo)
                        })
                        .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                            Button("수정", action: {
                                
                                self.editUserInput = todo.content
                                
                                self.editingTodo = todo
                                
                              showEditAlert = true
                                
                            }).tint(Color.orange)
                        })
                        
                    }).onDelete(perform: { indexSet in
                        
                        todosViewModel.localDataDelete(indexSet: indexSet)
                        
                    })
                    
                }.environment(\.locale, Locale(identifier: "ko"))
            }
            .padding(.top, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        
                        todosViewModel.localDataClearAll()
                        print("삭제")
                    }) {
                        Image(systemName: "trash")
                    }
                }
                ToolbarItem(placement: .principal) {
                    TextField("검색", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showTextFeildAlert.toggle()
                        
                        print(#fileID, #function, #line, "- 쓰기 \(showTextFeildAlert)")
                        
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .alert("새로운 할일 추가", isPresented: $showTextFeildAlert) {
                TextField("할일을 입력해주세요", text: $userInput)
                Button("확인", action: {
                    let newTodo = Todo(isDone: false, content: userInput)
                    todosViewModel.localDataAddTodo(newTodo: newTodo)
                    self.userInput = ""
                    self.showTextFeildAlert = false
                })
                Button("닫기", action: {
                    self.showTextFeildAlert = false
                })
            }
            .alert("할일 수정", isPresented: $showEditAlert) {
                TextField("할일을 입력해주세요", text: $editUserInput)
                Button("확인", action: {
                    todosViewModel.localDataUpdateTodo(editingTodo: self.editingTodo, editUserInput: editUserInput)
                    self.editUserInput = ""
                    self.showEditAlert = false
                })
                Button("닫기", action: {
                    self.showEditAlert = false
                })
            }
            
        }
    }
}

#Preview {
    LocalDataView()
}
