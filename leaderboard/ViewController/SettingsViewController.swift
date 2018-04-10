//
//  SettingsViewController.swift
//  leaderboard
//
//  Created by Ivan Leider on 10/04/2018.
//  Copyright © 2018 ENTI. All rights reserved.
//

import UIKit

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
    
}
