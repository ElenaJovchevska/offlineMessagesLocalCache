//
//  ViewController.swift
//  MessagesCache
//
//  Created by Elena Jovcevska on 4/28/19.
//  Copyright © 2019 Elena Jovcevska. All rights reserved.
//

import UIKit
import PusherChatkit

/// Custom class serving as PCChatManagerDelegate, needed for ChatManager setup
class ChatManagerDelegate: PCChatManagerDelegate {}

/// Representing the chat UI and handling the setup of ChatManager and chat actions
class ChatViewController: AbstractViewController, PCRoomDelegate, ResendChatMessage {
    
    // IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // Delegates
    private var chatTableViewDelegate: ChatTableViewDelegate?
    
    // Chat vars
    var chatManager: ChatManager!
    var currentUser: PCCurrentUser?
    var chatManagerDelegate: PCChatManagerDelegate?
    var messages: [ChatMessage] = []
    var defaultFrame: CGRect!
    var userID = ""
    
    // Constants
    let chatInstanceLocator = "YOUR_INSTANCE_LOCATOR"
    let chatTokenProvider =  "YOUR_TOKEN_PROVIDER"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatManager()
        setupTableViewDelegateForChat()
    }
    
    private func setupTableViewDelegateForChat() {
        chatTableViewDelegate = ChatTableViewDelegate.init(tableView, messages, self)
        tableView.reloadData()
    }
    
    func setupChatManager() {
        chatManager = ChatManager(
            instanceLocator: chatInstanceLocator,
            tokenProvider: PCTokenProvider(url: chatTokenProvider),
            userID: userID
        )
        
        self.chatManagerDelegate = ChatManagerDelegate()
        guard let chatManagerDelegate = self.chatManagerDelegate else { return }
        chatManager.connect(delegate: chatManagerDelegate) { [unowned self] currentUser, error in
            guard error == nil else {
                self.handleTechnicalError("Error connecting")
                return
            }
            guard let currentUser = currentUser else { return }
            self.currentUser = currentUser
            guard let rooms = self.currentUser?.rooms else { return }
            if rooms.count > 0 {
                self.subscribeUser(to: rooms[0])
                
            } else {
                currentUser.getJoinableRooms(completionHandler: { (rooms, error) in
                    guard let rooms = rooms else { return }
                    self.joinUser(to: rooms[0])
                })
            }
        }
    }
    
    private func subscribeUser(to room: PCRoom) {
        currentUser?.subscribeToRoomMultipart(
            room: room,
            roomDelegate: self,
            messageLimit: 0
        ) { error in
            guard error == nil else {
                self.handleTechnicalError("Error subscribing to room")
                return
            }
            self.fetchMessages()
        }
    }
    
    private func joinUser(to room: PCRoom) {
        currentUser?.joinRoom(room,
                              completionHandler: { (room, error) in
                                guard error == nil else {
                                    self.handleTechnicalError("Error subscribing to room")
                                    return
                                }
                                self.fetchMessages()
        })
    }
    
    
    private func fetchMessages() {
        guard let currentUser = self.currentUser else {return}
        // Initialize with cached and failed to send messages
        DispatchQueue.main.async {
            var chatMesssages = CoreDataService.fetchRecords()
            if let room = currentUser.rooms.first {
                currentUser.fetchMultipartMessages(room) { (messages, error) in
                    if let messages = messages {
                        for message in messages {
                            chatMesssages?.append(UtilFunctions.convertToChatMessage(message, currentUser))
                        }
                    }
                    self.sort(messages: chatMesssages)
                }
            }
        }
    }
    
    private func sort(messages: [ChatMessage]?) {
        if let messages = messages {
            self.messages = messages.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
            DispatchQueue.main.async {
                self.chatTableViewDelegate?.update(self.messages)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: IBAction
    @IBAction func sendMessageButton(_ sender: Any) {
        guard let message = self.chatTextField.text else { return }
        sendMessage(text: message)
        self.chatTextField.text?.removeAll()
    }
    
    private func sendMessage(text: String) {
        if !Reachability.isConnectedToNetwork(){
            saveNotSentRecord(for: text)
        } else {
            guard let currentUser = self.currentUser else {return}
            let partInlineRequest = PCPartInlineRequest.init(content: text)
            let partRequest = PCPartRequest.init(PCPartRequestType.inline(partInlineRequest))
            currentUser.sendMultipartMessage(roomID: currentUser.rooms.first?.id ?? "",
                                             parts: [partRequest]) { (messageId, error) in
                                                guard error == nil else {
                                                    self.saveNotSentRecord(for: text)
                                                    return
                                                }
            }
        }
    }
    
    private func saveNotSentRecord(for text: String) {
        DispatchQueue.main.async {
            let cachedMessage = ChatMessage.init(id: UtilFunctions.generateUUID(),
                                                 text: text,
                                                 timestamp: Date(),
                                                 senderId: self.userID,
                                                 isReceived: false,
                                                 status: .notSent)
            CoreDataService.saveNewRecord(message: cachedMessage)
            
            self.messages.insert(cachedMessage, at: 0)
            self.chatTableViewDelegate?.update(self.messages)
            self.tableView.reloadData()
        }
    }
    
    //MARK: PCRoomDelegate
    func onMultipartMessage(_ message: PCMultipartMessage) {
        guard let currentUser = self.currentUser else { return }
        messages.insert(UtilFunctions.convertToChatMessage(message, currentUser), at: 0)
        DispatchQueue.main.async {
            self.chatTableViewDelegate?.update(self.messages)
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: ResendChatMessage
    func resend(message: ChatMessage,
                at index: Int) {
        if message.senderId != self.currentUser?.id {
            return
        }
        self.messages.remove(at: index)
        CoreDataService.deleteRecord(with: message.id)
        sendMessage(text: message.text)
    }
}

