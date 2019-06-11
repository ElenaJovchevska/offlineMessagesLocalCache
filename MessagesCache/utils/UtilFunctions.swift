//
//  UtilFunctions.swift
//  MessagesCache
//
//  Created by Elena Jovcevska on 5/4/19.
//  Copyright © 2019 Elena Jovcevska. All rights reserved.
//

import Foundation
import PusherChatkit

class UtilFunctions {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
    
    static func generateUUID() -> Int {
        return UUID().hashValue
    }
    
    /// Converts PCMultipartMessage recieved from the Chatkit SDK to our mapping ChatMessage.
    /// We only support inline PCMultipartPayload in this tutorial
    static func convertToChatMessage(_ message: PCMultipartMessage,
                                     _ currentUser: PCCurrentUser) -> ChatMessage {
        let payload = message.parts[0].payload
        var content = ""
        switch payload {
        case .inline(let payload):
            content = payload.content
        default: break
        }
        return ChatMessage.init(id: message.id,
                                text: content,
                                timestamp: dateFormatter.date(from:  message.createdAt) ?? Date(),
                                senderId: message.sender.id,
                                isReceived: currentUser.id != message.sender.id,
                                status: .sent)
    }
}
