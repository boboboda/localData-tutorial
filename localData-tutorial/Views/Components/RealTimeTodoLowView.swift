//
//  RealTimeTodoLowView.swift
//  localData-tutorial
//
//  Created by bobo on 3/5/24.
//

import SwiftUI

struct RealTimeTodoLowView: View {
    
    @EnvironmentObject var todosViewModel : TodosViewModel
    
    let todo: Todo
    
    @State var isDone : Bool = false
    
    var onToggleChanged : () -> Void
    
    init(todo: Todo, onToggleChanged: @escaping () -> Void) {
        self.todo = todo
        self.onToggleChanged = onToggleChanged
        self._isDone = State(wrappedValue: todo.isDone)
        
    }
    
    var body: some View {
        
        VStack{
            
            HStack {
                Text(todo.content)
                Toggle("", isOn: $isDone)
                    .onChange(of: isDone ) {
                        
                        onToggleChanged()
                        
//                        guard let refId = todo.refId else { return }
//                        
//                        todosViewModel.updateIsDone(refId: refId)
                    }
            }
            
            VStack(alignment: .trailing){
                Text("생성일: \(todo.createdAt?.toString ?? "")")
                Text("수정일: \(todo.updatedAt?.toString ?? "")")
                Divider().opacity(0)
            }
        }
        
        
    }
}
