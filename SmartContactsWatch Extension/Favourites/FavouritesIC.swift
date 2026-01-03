//
//  FavouritesIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 02/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class FavouritesIC: WKInterfaceController {
    
    @IBOutlet var favouritesTable: WKInterfaceTable!
    @IBOutlet var noFavouritesLabel: WKInterfaceLabel!
    
    var contactListArray = [Contact]()
    var favoriteTableData: [Contact]  =   [Contact]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print("awakeFavourite")
        
        noFavouritesLabel.setHidden(true)
       
        self.favouritesTable.setNumberOfRows(self.favoriteTableData.count, withRowType: "FavouritesListRow")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActiveFavourite")
        contactListArray  = [Contact]()
        favoriteTableData =   [Contact]()
        reloadData()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("didDeactiveFavourite")
    }
    
    
    func reloadData() {
        
        if WCSession.isSupported() {
            
            let session = WCSession.default
            if session.isReachable {
                
                session.sendMessage(["request": "Contacts"], replyHandler: { (response) in
                    
                    var contactDictionary = [String: [Any]]()
                    contactDictionary = (response as! [String: [Any]])
                    
                    if contactDictionary.count == 0 {
                        self.noFavouritesLabel.setHidden(false)
                        return
                    } else {
                        
                        self.contactListArray = self.populateDataFromResponse(contactDictionary: contactDictionary)
                        self.filterFavoriteContacts()
                        
                        self.favouritesTable.setNumberOfRows(self.favoriteTableData.count, withRowType: "FavouritesListRow")
                        
                        for index in 0..<self.favouritesTable.numberOfRows {
                            guard let controller = self.favouritesTable.rowController(at: index) as? FavouritesListRowController
                                else { continue }
                            
                            controller.contact = self.favoriteTableData[index]
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
        
        var contactIdArray = [Int32]()
        var nameArray = [String]()
        var mobileArray = [String]()
        var emailArray = [String]()
        var imageArray = [Data]()
        var favouriteArray = [Bool]()
        
        for id in contactDictionary["contactId"]! {
            contactIdArray.append(id as! Int32)
        }
        
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
        
        for favourite in contactDictionary["favourite"]! {
            favouriteArray.append(favourite as! Bool)
        }
        
        var contactsArray = [Contact]()
        for index in 0..<nameArray.count {
            
            let contact = Contact()
            
            contact.contactID = contactIdArray[index]
            contact.firstName = nameArray[index]
            contact.mobile    = mobileArray[index]
            contact.email     = emailArray[index]
            let data          = imageArray[index]
            contact.contactImage = UIImage(data: data as Data)
            
            contact.isFavorite = favouriteArray[index]
            
            contact.lastName = ""
            contact.companyName = ""
            
            
            contactsArray.append(contact)
        }
        
        return contactsArray
    }
    
    func filterFavoriteContacts() {
        
        for contact in contactListArray {
            
            if  contact.isFavorite != nil  {
                
                if contact.isFavorite == true {
                    favoriteTableData.append(contact)
                }
            }
        }
        
        favoriteTableData = favoriteTableData.sorted(by: { $0.firstName! < $1.firstName! })
        
        if favoriteTableData.count == 0 {
            noFavouritesLabel.setHidden(false)
        } else {
            noFavouritesLabel.setHidden(true)
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        var contact = Contact()
        
        if favoriteTableData.count > 0 {
            contact = favoriteTableData[rowIndex]
        } else {
            contact.firstName = "Chaman Lal"
            contact.lastName  = "Sahu"
            contact.contactImage = UIImage(named: "default_user")
        }
        
        self.pushController(withName: "ContactDetail", context: contact)
    }
}
