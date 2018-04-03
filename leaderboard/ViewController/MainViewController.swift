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

// This is our database collection (table) name where we save our players' points
let k_COLLECTION_PLAYERS = "players"

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var authenticationHandle: AuthStateDidChangeListenerHandle?
    var user: User?
    var players = [Player]()
    
    let k_POINTS_INCREASE = 1
    @IBOutlet weak var addPointsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // IT Begins
        getPlayers()
    }
    
    func getPlayers() {
        // TODO: Get players from Firestore
        // https://firebase.google.com/docs/firestore/query-data/get-data
        // TIP: You can use the helper methods fromDictionary() and asDictionary() on any Player object to get it in the format accepted by Firestore
        // players = ?
        // Refresh tableview after we got our players
        tableView.reloadData()
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
        cell.usernameLabel.text = "Username" // TODO
        // Set Points
        cell.pointsLabel.text = String(format: "%d Points", 5) // TODO
        return cell
    }
    
    @IBAction func didTapAddPoints(_ sender: UIButton) {
        // TODO: Update user points on Firestore
        // https://firebase.google.com/docs/firestore/manage-data/add-data
        // TODO: Refresh data
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
    }
    
}
