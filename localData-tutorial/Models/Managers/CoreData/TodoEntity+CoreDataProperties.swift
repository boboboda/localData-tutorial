//
//  TodoEntity+CoreDataProperties.swift
//  localData-tutorial
//
//  Created by bobo on 3/2/24.
//
//

import Foundation
import CoreData


extension TodoEntity {

    // fetchAll
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }
    
    @nonobjc public class func DeleteAllRequest() -> NSBatchDeleteRequest {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoEntity")
        return NSBatchDeleteRequest(fetchRequest: request)
    }
    
    

    // 데이터들
    @NSManaged public var uuid: UUID?
    @NSManaged public var isDone: Bool
    @NSManaged public var content: String?
    
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?

}

extension TodoEntity : Identifiable {

}

//MARK: Predicate 관련
extension TodoEntity {
    
    // UUID 검색 필터링
    static var serchByUUIDPredicate: NSPredicate {
        NSPredicate(format: "%K == $uuid" , #keyPath(uuid))
    }
}
