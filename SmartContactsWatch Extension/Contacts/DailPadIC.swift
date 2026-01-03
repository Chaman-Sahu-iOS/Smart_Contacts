//
//  DailPadIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 04/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation


class DailPadIC: WKInterfaceController {
    
    var phone = String()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("awakeDailPad")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActivateDailpad")
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("didDeactivateDailpad")
    }
    
    
    @IBOutlet var dialLabel: WKInterfaceLabel!
    
    @IBAction func deleteButton() {
        
        phone.remove(at: phone.index(before: phone.endIndex))
        dialLabel.setText(phone)
    }
    
    @IBAction func one() {
        phone.append("1")
        dialLabel.setText(phone)
    }
    
    @IBAction func two() {
        phone.append("2")
        dialLabel.setText(phone)
    }
    @IBAction func three() {
        phone.append("3")
        dialLabel.setText(phone)
    }
    
    @IBAction func four() {
        phone.append("4")
        dialLabel.setText(phone)
    }
    
    @IBAction func five() {
        phone.append("5")
        dialLabel.setText(phone)
    }
    
    @IBAction func six() {
        phone.append("6")
        dialLabel.setText(phone)
    }
    
    @IBAction func seven() {
        phone.append("7")
        dialLabel.setText(phone)
    }
    
    @IBAction func eight() {
        phone.append("8")
        dialLabel.setText(phone)
    }
    
    @IBAction func nine() {
        phone.append("9")
        dialLabel.setText(phone)
    }
    
    @IBAction func plus() {
        phone.append("+")
        dialLabel.setText(phone)
    }
    
    @IBAction func zero() {
        phone.append("0")
        dialLabel.setText(phone)
    }
    
    @IBAction func dial() {
        
        if let telURL = URL(string:"tel:\(phone)") {
            let wkExt=WKExtension.shared()
            wkExt.openSystemURL(telURL)
        }
        
    }
    
}
