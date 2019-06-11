//
//  CoreDataService.swift
//  MessagesCache
//
//  Created by Elena Jovcevska on 5/4/19.
//  Copyright © 2019 Elena Jovcevska. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// Enum defining the ChatMessage status
enum ChatMessageStatus: String {
    case sent
    case notSent
}

/// Defines the structure for the Messages entity. Allowes easier manipulation with the data.
struct ChatMessage {
    var id: Int
    var text: String
    var timestamp: Date
    var senderId: String
    var isReceived: Bool
    var status: ChatMessageStatus
}

/// Custom util class for saving, fetching and deleting records from Core data entity
class CoreDataService {
    
    /// Maps and saves ChatMessage object as new record in Messages entity
    static func saveNewRecord(message: ChatMessage) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Messages", in: context)
        let messages = NSManagedObject(entity: entity!, insertInto: context)
        messages.setValue(message.text, forKey: "text")
        messages.setValue(message.timestamp, forKey: "timestamp")
        messages.setValue(message.senderId, forKey: "senderId")
        messages.setValue(message.id, forKey: "id")
        messages.setValue(message.isReceived, forKey: "isReceived")
        messages.setValue(message.status.rawValue, forKey: "status")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    /// Delete record from Messages entity for specific index
    static func deleteRecord(with id: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let result = readFromMessagesEntitity() {
            for data in result {
                if data.value(forKey: "id") as! Int == id {
                    appDelegate.persistentContainer.viewContext.delete(data)
                }
            }
        }
    }
    
    /// Fetches all messages saved. Cached messages. The result is mapped as [ChatMessage]
    static func fetchRecords() ->  [ChatMessage]? {
        if let result = readFromMessagesEntitity() {
            var messages = [ChatMessage]()
            for data in result {
                let message = ChatMessage.init(id: data.value(forKey: "id") as? Int ?? 0,
                                               text: data.value(forKey: "text") as? String ?? "",
                                               timestamp: data.value(forKey: "timestamp") as? Date ?? Date(),
                                               senderId: data.value(forKey: "senderId") as? String ?? "",                     isReceived: data.value(forKey: "isReceived") as? Bool ?? true,
                                               status: ChatMessageStatus.init(rawValue: data.value(forKey: "status") as? String ?? "") ?? .notSent)
                messages.append(message)
            }
            return messages
        }
        return nil
    }
    
    private static func readFromMessagesEntitity() -> [NSManagedObject]? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Messages")
        request.returnsObjectsAsFaults = false
        do {
            let result = try appDelegate.persistentContainer.viewContext.fetch(request)
            return result as? [NSManagedObject]
        } catch {
            return nil
        }
    }
}
