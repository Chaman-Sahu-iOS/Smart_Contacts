//
//  GroupsDetailsIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 02/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation


class GroupsDetailsIC: WKInterfaceController {

    @IBOutlet var groupsDetailsTable: WKInterfaceTable!
    
    var groupsListArray = [Contact]()
    var groupName       = String()
    
    var groupsArray: [Contact]? {
        didSet {
            
            guard let groupArray = groupsArray else {
                return
            }
            
            groupsListArray = groupArray
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let contactArray = context as? [String: Any]
        {
            groupName = contactArray["groupName"] as! String
            self.groupsArray = contactArray["groupContacts"] as? [Contact]
        }
        
        self.setTitle(groupName)
        
        reloadTableData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadTableData() {
        
        self.groupsDetailsTable.setNumberOfRows(groupsListArray.count, withRowType: "GroupsDetailsRow")
        
        for index in 0..<groupsDetailsTable.numberOfRows {
            let controller = groupsDetailsTable.rowController(at: index) as! GroupDetailsRowController
            controller.groupsDetailsLabel.setText(groupsListArray[index].firstName)
        }
        
    }
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        var contact = Contact()
        
        if groupsListArray.count > 0 {
            contact = groupsListArray[rowIndex]
        } else {
            contact.firstName = "Chaman Lal"
            contact.lastName  = "Sahu"
            contact.contactImage = UIImage(named: "default_user")
        }
        
        self.pushController(withName: "ContactDetail", context: contact)
    }

}
