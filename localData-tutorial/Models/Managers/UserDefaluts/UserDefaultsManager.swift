//
//  UserDefaultsManager.swift
//  localData-tutorial
//
//  Created by bobo on 2/29/24.
//

import Foundation

class UserDefaultsManager {
    
    enum Key: String, CaseIterable {
        case alreadyLaunched
        case todoList
    }
    
    static let shared: UserDefaultsManager = {
       return UserDefaultsManager()
    }()
    
    
    
    /// todo저장
    /// - Parameter updatedTodos:
    func setTodoList(updatedTodos: [Todo]) {
        
        do {
            // 1. 잘게 조각으로 만든다.
            let data = try PropertyListEncoder().encode(updatedTodos)
            // 2. 저장한다.
            UserDefaults.standard.set(data, forKey: Key.todoList.rawValue)
            
            print(#fileID, #function, #line, "- 저장완료")

        } catch{
            print(#fileID, #function, #line, "- error: \(error)")

        }
    }
    
    
    /// todo 가져오기
    /// - Parameter updatedTodos:
    func fetchTodoList() -> [Todo] {
        
        // 1. 조각상태의 저장된 녀석을 가져온다.
        
        guard let data = UserDefaults.standard.data(forKey: Key.todoList.rawValue) else {return []}
        
        do {
            // 2. 저장된 데이터를 재조립 한다.
            let fetchedTodoList = try PropertyListDecoder().decode([Todo].self, from: data)
            print(#fileID, #function, #line, "- 가져온 데이터 갯수 \(fetchedTodoList.count)")
            return fetchedTodoList
        } catch{
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    
    /// 이미 한번 실행되었다 설정
    /// - Parameter isLaunced:
    func setAlreadyLaunced(isLaunced: Bool) {
        print(#fileID, #function, #line, "- isLaunched: \(isLaunced)")

        UserDefaults.standard.set(isLaunced, forKey: Key.alreadyLaunched.rawValue)
    }
    
    func isAlreadyLaunced() -> Bool {
        print(#fileID, #function, #line, "")

        return UserDefaults.standard.bool(forKey: Key.alreadyLaunched.rawValue)
    }
    
    func clearAllTodos() {
        UserDefaults.standard.removeObject(forKey: Key.todoList.rawValue)
    }
    
    func clearAll() {
        Key.allCases.forEach{
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
    }

}
