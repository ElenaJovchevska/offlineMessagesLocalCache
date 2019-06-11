//
//  ChatTableViewDelegate.swift
//  buytickets
//
//  Created by Elena Jovcevska on 2/16/19.
//

import UIKit
import PusherChatkit

protocol ResendChatMessage: NSObjectProtocol {
    func resend(message: ChatMessage,
                at index: Int)
}

// Custom class that implements the support chat feature TableView's methods
class ChatTableViewDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    private weak var tableView: UITableView?
    private weak var delegate: ResendChatMessage?
    private var messages: [ChatMessage] = []
    
    init(_ tableView: UITableView,
         _ messages: [ChatMessage],
         _ delegate: ResendChatMessage) {
        self.tableView = tableView
        self.messages = messages
        self.delegate = delegate
        super.init()
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView?.rowHeight = UITableView.automaticDimension
        self.tableView?.estimatedRowHeight = 50
    }
    
    func update(_ messages: [ChatMessage]) {
        self.messages = messages
    }
    
    //MARK: TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCellIdentifier",
                                                 for: indexPath)
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        let messageInfo = self.messages[indexPath.row]
        if messageInfo.isReceived {
            cell.isUserInteractionEnabled = false
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.text = "\(messageInfo.senderId): \(messageInfo.text)"
        } else {
            cell.isUserInteractionEnabled = true
            if messageInfo.status == .notSent {
                cell.accessoryType = .detailButton
            } else {
                cell.accessoryType = .none
            }
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.text = "\("You:") \(messageInfo.text)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messageInfo = self.messages[indexPath.row]
        if messageInfo.status == .notSent {
            self.delegate?.resend(message: messageInfo, at: indexPath.row)
        }
    }
}
