//
//  InboxViewController.swift
//
//
//  Created by Johann Kerr on 3/23/17.
//
//

import UIKit
import Firebase

class ChannelViewController: UITableViewController {
    
    
    
    var channels = [Channel]()
    var user: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let screenName = UserDefaults.standard.string(forKey: "screenName") {
            user = screenName
        }
        
        
    }
    
    func getChannels() {
        
        FirebaseManager.getChannels { (channels) in
            self.channels = channels
            self.tableView.reloadData()
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getChannels()
    }
    
    
    func checkIfUserExists() {
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? [String: Any] {
                if (userDict[self.user] != nil) {
                    
                } else {
                    FIRDatabase.database().reference().child("users").child(self.user).setValue(false)
                }
            }
            
        })
        
        
    }
    
    
    // MARK: - Table view data source
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath)
        
        cell.textLabel?.text = channels[indexPath.row].name
        cell.detailTextLabel?.text = channels[indexPath.row].lastMsg
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "msgSegue" {
          
            if let dest = segue.destination as? MessageViewController {
                if let index = self.tableView.indexPathForSelectedRow?.row {
                    let channel = self.channels[index].name
                    dest.channelId = channel
                    dest.senderId = user
                    dest.senderDisplayName = user
                }
            }
        }
    }
    
    
    func channelAlert() {
        let alertController = UIAlertController(title: "Error", message: "Channel Exists", preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Ok", style: .destructive) { (action) in
            
        }
        
        
        alertController.addAction(ok)
        
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func createBtnPressed(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Create Channel", message: "Create a new channel", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Channel Name"
        }
        
        let create = UIAlertAction(title: "Create", style: .default) { (action) in
            if let channel = alertController.textFields?[0].text {
                // check if exists if not create a new one
                
                FirebaseManager.checkForChannel(channel, completion: { (exists) in
                    if exists {
                        ///error message
                    } else {
                        FirebaseManager.createChannel(channel, completion: {
                            self.getChannels()
                        })
                    }
                    
                })
                
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alertController.addAction(create)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    
       
    
    
    
}
