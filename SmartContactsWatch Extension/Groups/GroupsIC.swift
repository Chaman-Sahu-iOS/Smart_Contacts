//
//  GroupsIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 02/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class GroupsIC: WKInterfaceController {
    
    @IBOutlet var groupsTable: WKInterfaceTable!
    @IBOutlet var noGroupsLabel: WKInterfaceLabel!
    
    var groupTableData =   [String]()  // For Group Name
    var groupData      =    [String:[Contact]]()  // Key is Group Name & Value is Group Contact

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        noGroupsLabel.setHidden(true)
        
        self.groupsTable.setNumberOfRows(0,	 withRowType: "GroupsRow")
        // Configure interface objects here.
        reloadData()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadData() {
        
        if WCSession.isSupported() {
            
            let session = WCSession.default
            if session.isReachable {
                
                session.sendMessage(["request": "Groups"], replyHandler: { (response) in
                    
                    var contactDictionary = [String: [String: [Any]]]()
                    contactDictionary = (response as! [String: [String: [Any]]])
                    
                    
                    if contactDictionary.count == 0 {
                        self.noGroupsLabel.setHidden(false)
                        return
                    } else {
                        
                        self.noGroupsLabel.setHidden(true)
                        
                        for (key, value) in contactDictionary {
                            self.groupTableData.append(key)
                            
                            var contactArray = [Contact]()
                            contactArray     = self.populateDataFromResponse(contactDictionary: value)
                            
                            self.groupData[key]   = contactArray
                        }
                        
                        self.groupTableData = self.groupTableData.sorted(by: {$0 < $1})
                        self.groupsTable.setNumberOfRows(self.groupTableData.count, withRowType: "GroupsRow")

                        for index in 0..<self.groupsTable.numberOfRows {
                            guard let controller = self.groupsTable.rowController(at: index) as? GroupsRowController
                                else { continue }

                            controller.groupNameLabel.setText(self.groupTableData[index])
                        }
                    }
                    
                    
                }) { (error) in
                    print("Error sending message:  \(error.localizedDescription)")
                }
            } else {
                print("Session is not reachable")
            }
        } else {
            print("Session is not supported")
        }
    }
    
    func populateDataFromResponse(contactDictionary: [String: [Any]]) -> [Contact]{
        
        var nameArray = [String]()
        var mobileArray = [String]()
        var emailArray = [String]()
        var imageArray = [Data]()
        
        for name in contactDictionary["name"]! {
            nameArray.append(name as! String)
        }
        
        for mobile in contactDictionary["mobile"]! {
            mobileArray.append(mobile as! String)
        }
        
        for email in contactDictionary["email"]! {
            emailArray.append(email as! String)
        }
        
        for image in contactDictionary["image"]! {
            imageArray.append(image as! Data)
        }
        
        var contactsArray = [Contact]()
        for index in 0..<nameArray.count {
            
            let contact = Contact()
            
            contact.firstName = nameArray[index]
            contact.mobile    = mobileArray[index]
            contact.email     = emailArray[index]
            let data          = imageArray[index]
            contact.contactImage = UIImage(data: data as Data)
            
            contactsArray.append(contact)
        }
        
        contactsArray = contactsArray.sorted(by: {$0.firstName! < $1.firstName!})
        
        
        return contactsArray
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        var contactsArray = [String: Any]()
       
        if groupTableData.count > 0 {
            let groupName = groupTableData[rowIndex]
            
            contactsArray["groupName"] = groupName
            contactsArray["groupContacts"] = groupData[groupName]!
            
            self.pushController(withName: "GroupsDetails", context: contactsArray)
        }
        
        
    }
}
