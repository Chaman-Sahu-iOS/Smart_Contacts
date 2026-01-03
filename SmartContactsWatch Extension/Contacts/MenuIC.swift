//
//  MenuIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 04/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation


class MenuIC: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func addMenu() {
        print("addd")
    }
    
    
    @IBAction func callMenu() {
        print("call")
    }
}
