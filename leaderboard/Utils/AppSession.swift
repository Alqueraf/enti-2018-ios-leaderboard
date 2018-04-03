//
//  AppSession.swift
//  leaderboard
//
//  Created by Alex Queudot on 03/04/2018.
//  Copyright © 2018 ENTI. All rights reserved.
//

import Locksmith

let k_USER_ACCOUNT_KEY = "user_account"
let k_EMAIL_KEY = "email"
let k_PASSWORD_KEY = "password"

class AppSession {
    
    fileprivate var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    // Email
    var email: String? {
        if let userAccount = defaults.object(forKey: k_USER_ACCOUNT_KEY) as? String,
            let userData = Locksmith.loadDataForUserAccount(userAccount: userAccount),
            let email = userData[k_EMAIL_KEY] as? String {
            return email
        }
        return nil
    }
    // Password
    var password: String? {
        if let userAccount = defaults.object(forKey: k_USER_ACCOUNT_KEY) as? String,
            let userData = Locksmith.loadDataForUserAccount(userAccount: userAccount),
            let password = userData[k_PASSWORD_KEY] as? String {
            return password
        }
        return nil
    }
    
    // Saves login credentials to Keychain (secure storage)
    func saveUserAccount(email: String, password: String) throws {
        try Locksmith.updateData(data: [k_EMAIL_KEY: email, k_PASSWORD_KEY: password], forUserAccount: email)
    }
    
    class var shared: AppSession {
        struct Singleton {
            static let instance = AppSession()
        }
        return Singleton.instance
    }
}
