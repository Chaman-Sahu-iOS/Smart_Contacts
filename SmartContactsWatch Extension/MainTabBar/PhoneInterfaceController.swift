//
//  PhoneInterfaceController.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 02/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation


class PhoneInterfaceController: WKInterfaceController {
    
    @IBOutlet var phoneTableData: WKInterfaceTable!
    
    var tabItemArray = ["Favourites", "Contacts", "Groups"]
    var tabImageArray = ["star_filled", "contact_filled", "group_filled"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        phoneTableData.setNumberOfRows(tabItemArray.count, withRowType: "PhoneRow")
        
        for index in 0..<phoneTableData.numberOfRows {
            
            guard let row = phoneTableData.rowController(at: index) as? PhoneRowController else {
                continue
            }
            
            row.tabBarItem.setText(tabItemArray[index])
            row.tabBarImage.setImage(UIImage(named: tabImageArray[index]))
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        if rowIndex == 0 {
            self.pushController(withName: "FavouritesList", context: nil)
        }
        
        if rowIndex == 1 {
            self.pushController(withName: "ContactList", context: nil)
        }
        
        if rowIndex == 2 {
            self.pushController(withName: "GroupsList", context: nil)
        }
    }

}
