//
//  todoListRowView.swift
//  localData-tutorial
//
//  Created by bobo on 3/2/24.
//
import Foundation
import SwiftUI

struct TodoListRowView: View {
    
    let aTodo: Todo

    @State var isDone : Bool = false
    
    var onToggleChanged : (Bool) -> Void
    
    init(aTodo: Todo, onToggleChanged: @escaping (Bool) -> Void){
        self.aTodo = aTodo
        self.onToggleChanged = onToggleChanged
        self._isDone = State(wrappedValue: aTodo.isDone)
        print(#fileID, #function, #line, "- ")
    }
    
    
    var body: some View {
        VStack {
            HStack(content: {
                Text(aTodo.content)
                Toggle(isOn: $isDone, label: { EmptyView() })
                    .onChange(of: isDone, perform: { changedValue in
                        
                        onToggleChanged(changedValue)
                    
                    })
                
            })
            
            VStack(alignment: .trailing){
                Text("생성일: \(aTodo.createdAt?.toString ?? "")")
                Text("수정일: \(aTodo.updatedAt?.toString ?? "")")
                Divider().opacity(0)
            }
        }
        
    }
}
