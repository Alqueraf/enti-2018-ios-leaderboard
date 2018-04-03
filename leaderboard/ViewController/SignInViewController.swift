//
//  ViewController.swift
//  leaderboard
//
//  Created by Alex Queudot on 03/04/2018.
//  Copyright © 2018 ENTI. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is where everything begins
    }

    @IBAction func didTapSignIn(_ sender: UIButton) {
        // TODO: Create User
        // https://firebase.google.com/docs/auth/ios/start#sign_up_new_users
        // If successfull, save to Local Storage TIP: Use AppSession > saveUserAccount
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let user = user {
                    try! AppSession.shared.saveUserAccount(email: email, password: password)
                    self.goToMainScreen()
                }
            }
        }
    }
    
    private func goToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
}

