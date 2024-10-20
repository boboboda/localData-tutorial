//
//  Todo.swift
//  localData-tutorial
//
//  Created by bobo on 3/1/24.
//

import Foundation
import FirebaseFirestore

// NSObject, NSCoding, NSSecureCoding 인코딩, 디코딩 가능하게 해줌
class Todo : NSObject, NSCoding, NSSecureCoding, Codable, Identifiable {
    
    override var description: String {
        return "Todo(id: \(uuid), refId:\(refId ?? ""), createdAt: \(String(describing: createdAt)), updatedAt:\(String(describing: updatedAt)) content: \"\(content)\", isDone: \(isDone))"
    }
    
    static var supportsSecureCoding: Bool = true
    
    var uuid: UUID = UUID()
    var refId: String?
    var content: String
    var isDone: Bool
    var createdAt: Date?
    var updatedAt: Date?
    
    
    init(
        refId: String = "",
        isDone: Bool = false,
        createdAt: Date? = Date(),
        updatedAt: Date? = Date(),
        content: String = "하하하하하") {
            self.refId = refId
            self.isDone = isDone
            self.content = content
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            
        }
    
    init(entity: TodoEntity) {
        self.uuid = entity.uuid ?? UUID()
        self.content = entity.content ?? ""
        self.isDone = entity.isDone
        self.createdAt = entity.createdAt
        self.updatedAt = entity.updatedAt
    }
    
    var dictionary: [String: Any] {
        return [
            "refId": refId ?? "",
            "todo": content,
            "isDone": isDone,
            "createdAt": Date().toString]}
    
    static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    // 인코딩 - 작게 만들기
    func encode(with coder: NSCoder) {
        coder.encode(self.content, forKey: "content")
        coder.encode(self.isDone, forKey: "isDone")
    }
    
    
    // 디코딩 - 작게 만들었던거 재조립
    required convenience init?(coder: NSCoder) {
        guard let content = coder.decodeObject(forKey: "content") as?
                String else { return nil }
        let isDone = coder.decodeBool(forKey: "isDone")
        self.init(isDone: isDone, createdAt: nil, updatedAt: nil, content: content)
    }
    
}


extension Todo {
    static func todos(from querySnapshot: QuerySnapshot) -> [Todo] {
        var todos = [Todo]()
        for document in querySnapshot.documents {
            let data = document.data()
            let todo = Todo(refId: document.documentID, // Firestore의 문서 ID 사용
                            isDone: data["isDone"] as? Bool ?? false,
                            createdAt: (data["createdAt"] as? String ?? Date().toString).toDate(),
                            updatedAt: (data["updatedAt"] as? String ?? Date().toString).toDate(),
                            content: data["todo"] as? String ?? "")
            
            todos.append(todo)
        }
        return todos
    }
}


