//
//  MainViewController.swift
//  leaderboard
//
//  Created by Alex Queudot on 03/04/2018.
//  Copyright © 2018 ENTI. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

// This is our database collection (table) name where we save our players' points
let k_COLLECTION_PLAYERS = "players"
let k_USE_REALTIME_DATABASE = true

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var authenticationHandle: AuthStateDidChangeListenerHandle?
    var user: User?
    var players = [Player]()
    
    var playerChangesHandle: DatabaseHandle?
    
    let k_POINTS_INCREASE = 1
    @IBOutlet weak var addPointsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // IT Begins
        getPlayers()
    }
    
    func getPlayers() {
        if k_USE_REALTIME_DATABASE {
            // Get players from Realmtime
            // https://firebase.google.com/docs/database/ios/read-and-write
            let realTimeRef = Database.database().reference()
            playerChangesHandle = realTimeRef.child(k_COLLECTION_PLAYERS).observe(DataEventType.value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.players = [Player]()
                    // Iterate through the elements and save players localy to our array
                    for entry in dictionary {
                        var player = try! Player.fromDictionary(entry.value as! [String : Any])
                        if let player = player {
                            self.players.append(player)
                            self.tableView.reloadData()
                        }
                    }
                }
            })
            
        } else {
            // Get players from Firestore
            // https://firebase.google.com/docs/firestore/query-data/get-data
            let db = Firestore.firestore()
            db.collection(k_COLLECTION_PLAYERS).getDocuments { (snapshot, error) in
                // Clear players array
                self.players = [Player]()
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    // Iterate through the documents and save players localy to our array
                    for document in snapshot!.documents {
                        let player = try! Player.fromDictionary(document.data())
                        if let player = player {
                            self.players.append(player)
                        }
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the current player to display
        let player = players[indexPath.item]
        // Get the current cell to display
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell") as! LeaderboardCell
        // Set Username
        cell.usernameLabel.text = player.username
        // Set Points
        cell.pointsLabel.text = String(format: "%d Points", player.points ?? 0)
        return cell
    }
    
    @IBAction func didTapAddPoints(_ sender: UIButton) {
        if let userId = user?.uid {
            if k_USE_REALTIME_DATABASE {
                let userRef = Database.database().reference().child(k_COLLECTION_PLAYERS).child(userId)
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get player
                    let value = snapshot.value as? NSDictionary
                    let username = value?["username"] as? String ?? (self.user?.email ?? "Alex")
                    let points = value?["points"] as? Int ?? 0
                    // Update points
                    userRef.updateChildValues(["username": username, "points": points + 1])
                }) { (error) in
                    print(error.localizedDescription)
                }
            } else {
                // Update user points on Firestore
                // Get our player document
                let db = Firestore.firestore()
                let userDocRef = db.collection(k_COLLECTION_PLAYERS).document(userId)
                userDocRef.getDocument(completion: { (document, error) in
                    if let error = error {
                        print("Error getting document: \(error)")
                    } else {
                        // Get the document's data
                        if let data = document?.data() {
                            // Convert to our Swift Player object
                            let playerMe = try! Player.fromDictionary(data)
                            if let playerMe = playerMe {
                                // We have our player, add 1 points
                                let newPoints = (playerMe.points ?? 0) + 1
                                // Save new points
                                userDocRef.updateData(["points": newPoints])
                            }
                        } else {
                            // Create new document
                            userDocRef.setData([
                                "username": userId,
                                "points": 1
                                ])
                        }
                        // Refresh
                        self.getPlayers()
                    }
                })
            }
            
        }
    }
    
    
    // MARK: Authentication State
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if logged-in user exists
        authenticationHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                // Save User
                self?.user = user
            } else {
                // Maybe we have a saved user, try to login automatically
                if let email = AppSession.shared.email, let password = AppSession.shared.password {
                    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
                        guard error == nil else {
                            // Something went wrong, go to SignIn
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                            UIApplication.shared.keyWindow?.rootViewController = viewController
                            return
                        }
                        self?.user = user
                    }
                } else {
                    // We don't have a user, go to SignIn
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let handle = authenticationHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        if let playerChangesHandle = playerChangesHandle {
            Database.database().reference().removeObserver(withHandle: playerChangesHandle)
        }
    }
    
}
