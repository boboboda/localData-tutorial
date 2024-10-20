//
//  ContentView.swift
//  localData-tutorial
//
//  Created by bobo on 2/29/24.
//
import Foundation
import SwiftUI

enum FilterOption: String, CaseIterable {
    case all = "전체"
    case complete = "완료"
    case incomplete = "미완료"
}

enum TabIndex{
    case local
    case realtime
    case fireStore
}



struct ContentView: View {
    
    @StateObject var todoViewModel : TodosViewModel = TodosViewModel()
    
    @State var tabIndex : TabIndex = .local
    
    
    
    let alreayLaunced : Bool = UserDefaultsManager.shared.isAlreadyLaunced()
    
    @State var homealert = false
    
    var body: some View {
        
        GeometryReader { proxy in
            
            TabView{
                
                LocalDataView()
                    .tabItem {
                        Image(systemName: "1.circle")
                        Text("로컬")
                    }
                    .environmentObject(todoViewModel)
                    .alert(isPresented: $homealert) {
                        Alert(
                            title: Text("안내"),
                            message: Text("앱이 처음이시군요!"),
                            primaryButton: .default(
                                Text("확인"),
                                action: {
                                    UserDefaultsManager.shared.setAlreadyLaunced(isLaunced: true)
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("닫기"),
                                action: {
                                    //                            UserDefaultsManager.shared.setAlreadyLaunced(isLaunced: true)
                                }
                            )
                        )
                    }
                
                RealTiemView()
                    .environmentObject(todoViewModel)
                    .tabItem {
                        Image(systemName: "2.circle")
                        Text("릴타임")
                    }
                
                FireStoreView()
                    .environmentObject(todoViewModel)
                    .tabItem {
                        Image(systemName: "3.circle")
                        Text("파이어스토어")
                    }
                
            }
        }
    }
}


#Preview {
    ContentView()
}
