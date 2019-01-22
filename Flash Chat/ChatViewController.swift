//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    // Declare instance variables here
    var messageArray = [Message]()
    
    // MARK: - IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!

    // MARK: - ViewController Livecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the correspnding delegates of the messageTableView
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        // Set the delegate of the text field
        messageTextfield.delegate = self
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        // Register the MessageCell.xib file
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")

        configureTableView()
        retrieveMessages()

        messageTableView.separatorStyle = .none
    }

    
    // MARK: - TableView DataSource Methods
    
    // Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")

        if let currentUser = Auth.auth().currentUser?.email, cell.senderUsername.text == currentUser {
            cell.avatarImageView.backgroundColor = UIColor.flatMint
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon
            cell.messageBackground.backgroundColor = UIColor.flatForestGreen
        }

        return cell
    }
    
    // Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    // TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    // Configures the custom height of the rows
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }

    
    // MARK:- TextField Delegate Methods

    // TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        }
    }

    // TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Send & Recieve from Firebase

    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        // TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false

        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email, "MessageBody": messageTextfield.text!]
        messageDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            if error != nil  {
                print(error!)
            } else {
                print("Message saved successfully!")
            }
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextfield.text = ""
        }
    }
    
    // TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let message = Message(message: text, sender: sender)
            self.messageArray.append(message)

            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }

    @IBAction func logOutPressed(_ sender: AnyObject) {
        // TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }

        guard (navigationController?.popToRootViewController(animated: true)) != nil else { return }
    }
}
