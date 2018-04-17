//
//  SettingsViewController.swift
//  leaderboard
//
//  Created by Ivan Leider on 10/04/2018.
//  Copyright © 2018 ENTI. All rights reserved.
//

import UIKit
import UserNotifications

let k_MASTER_VOLUME = "MASTER_VOLUME"

class SettingsViewController: UIViewController {

    @IBOutlet weak var slider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        slider.value = UserDefaults.standard.float(forKey: k_MASTER_VOLUME)
    }

    
    @IBAction func sliderValueChanged(_ sender: UISlider) {

        UserDefaults.standard.set(sender.value, forKey: k_MASTER_VOLUME)
    
    }
    

    @IBAction func scheduleNotificationPressed(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Hola Mundo!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Esta es una prueba de notificación local!",
                                                                arguments: nil)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        
        content.categoryIdentifier = "TIMER_EXPIRED";
        
        // Create the request object.
        let request = UNNotificationRequest(identifier: "TestNotification", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    
}
