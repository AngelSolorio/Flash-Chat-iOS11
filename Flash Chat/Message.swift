//
//  Message.swift
//  Flash Chat
//
//  This is the model class that represents the blueprint for a message

class Message {
    //TODO: Messages need a messageBody and a sender variable
    var messageBody = ""
    var sender = ""
    
    init(message: String, sender: String) {
        self.messageBody = message
        self.sender = sender
    }

    init() {}
}
