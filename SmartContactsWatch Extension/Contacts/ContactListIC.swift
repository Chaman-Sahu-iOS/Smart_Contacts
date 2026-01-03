//
//  ContactListIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 28/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ContactListIC: WKInterfaceController {
    
    // MARK:- Properties
    @IBOutlet weak var contactListTable: WKInterfaceTable!
    @IBOutlet var noContactsLabel: WKInterfaceLabel!
    
    var contactListArray = [Contact]()
    var contactDictionary = [String: [Contact]]()
    var contactSectionTitles = [String]()
    
    var rowTypes = [String]()
    
    // MARK:- View Life Cycle Method
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
       
        self.noContactsLabel.setHidden(true)
        
       self.contactListTable.setNumberOfRows(0, withRowType: "SectionsTitlesRow")
//       self.contactListArray = ContactDataManager.sharedManager.getContactsList()
//       contactListArray     = contactListArray.sorted(by: {$0.firstName! < $1.firstName!})
//       //self.contactListTable.setNumberOfRows(self.contactSectionTitles.count, withRowType: "SectionsTitlesRow")
//       self.contactListTable.setNumberOfRows(self.contactListArray.count, withRowType: "ContactListRow")
//
        //reloadTableData()
         reloadData()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
      //  print("willActivateWatch")
       
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
       // print("didDeactivateWatch")
    }
    
    // MARK:- Local Methods
    func reloadTableData() {
        
        for index in 0..<self.contactListTable.numberOfRows {
            guard let controller = self.contactListTable.rowController(at: index) as? ContactListRowController
                else { continue }
            
            controller.contact = self.contactListArray[index]
        }
    }
    
    func reloadData() {
        
        if WCSession.isSupported() {
            
            let session = WCSession.default
            if session.isReachable {
                
                session.sendMessage(["request": "Contacts"], replyHandler: { (response) in
                                
                    var contactDictionary = [String: [Any]]()
                    contactDictionary = (response as! [String: [Any]])
                    
                    self.contactListArray = [Contact]()
                    self.contactListArray = self.populateDataFromResponse(contactDictionary: contactDictionary)
                    
                    self.populateContactSections()
                    
                   // self.rowTypes = ["SectionsTitlesRow", "ContactListRow", "ContactListRow"]
                    self.contactListTable.setRowTypes(self.rowTypes)
                    
                    var i = 0
                    var j = 0
                    for index in 0..<self.rowTypes.count {
                        
                        switch self.rowTypes[index] {
                        case "SectionsTitlesRow":
                            let row = self.contactListTable.rowController(at: index) as! SectionRowController
                            row.sectionLabel.setText(self.contactSectionTitles[j])
                              j = j + 1
                        case "ContactListRow":
                            let row3 = self.contactListTable.rowController(at: index) as! ContactListRowController
                            row3.contact = self.contactListArray[i]
                            i = i + 1
                        default:
                            print("Not a value row type: ")
                        }
                    }
                    
//                    self.contactListTable.setNumberOfRows(self.contactListArray.count, withRowType: "ContactListRow")
//
//
//                    for index in 0..<self.contactListTable.numberOfRows {
//                        guard let controller = self.contactListTable.rowController(at: index) as? ContactListRowController
//                            else { continue }
//
//                        controller.contact = self.contactListArray[index]
//                    }
                    
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
        
        var qrCodeImageArray = [Data]()
        
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
        
        for qrImage in contactDictionary["qrImage"]! {
            qrCodeImageArray.append(qrImage as! Data)
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
            
            let qrData          = qrCodeImageArray[index]
            if let qr = UIImage(data: qrData as Data) {
                contact.qrCodeImage = qr
            } else {
                contact.qrCodeImage = UIImage()
            }
            
            contact.isFavorite = favouriteArray[index]
            
            contact.lastName = ""
            contact.companyName = ""
            
            
            contactsArray.append(contact)
        }
        
        if contactsArray.count == 0 {
            noContactsLabel.setHidden(false)
        } else {
            noContactsLabel.setHidden(true)
        }
        
        return contactsArray
    }
    
    func populateContactSections() {
        
        contactSectionTitles.removeAll()
        contactDictionary.removeAll()
        
        contactListArray = contactListArray.sorted(by: {$0.firstName!.uppercased() < $1.firstName!.uppercased()})
        
        // Take Contact Name first character as ContactSetionTitles as well as ContactDictionary Key
        for contact in contactListArray {
            var contactKey = String(contact.firstName!.prefix(1))
            
            contactKey = contactKey.uppercased()
            
            if (contactKey >= "A" && contactKey <= "Z" ) {
                if var contactValue = contactDictionary[contactKey] {
                    contactValue.append(contact)
                    contactDictionary[contactKey] = contactValue
                    rowTypes.append("ContactListRow")
                } else {
                    contactDictionary[contactKey] = [contact]
                    rowTypes.append("SectionsTitlesRow")
                    rowTypes.append("ContactListRow")
                }
            } else {
                contactKey = "#"
                if var contactValue = contactDictionary[contactKey] {
                    contactValue.append(contact)
                    contactDictionary[contactKey] = contactValue
                } else {
                    contactDictionary[contactKey] = [contact]
                }
            }
        }
        
        contactSectionTitles = [String](contactDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: {$0 < $1})
        
        if contactSectionTitles.indices.contains(0) {
            if contactSectionTitles[0] == "#" {
                contactSectionTitles.remove(at: 0)
                contactSectionTitles.append("#")
            }
        }
    }
    
    //MARK:- Fource Touch Menu
    @IBAction func callMenuTapped() {
        print("calling...")
        
        pushController(withName: "DailPad", context: nil)
    }
    
    @IBAction func msgMenuTapped() {
        print("messaging.....")
        
        let messageBody = ""
        let urlSafeBody = messageBody.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        if let urlSafeBody = urlSafeBody, let url = URL(string: "sms:&body=\(urlSafeBody)") {
            WKExtension.shared().openSystemURL(url)
        }
    }
    
    //MARK:- Table Delegate

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var contact = Contact()
        
        var contactsArray = [Contact]()
        var index = 0
        
        for data in rowTypes {
            
            if data == "ContactListRow" {
                contactsArray.append(contactListArray[index])
                index = index + 1
            } else {
                contactsArray.append(contact)
            }
            
        }

        if contactListArray.count > 0 {
            contact = contactsArray[rowIndex]
        } else {
            contact.firstName = "Chaman Lal"
            contact.lastName  = "Sahu"
            contact.contactImage = UIImage(named: "default_user")
        }
        
        self.pushController(withName: "ContactDetail", context: contact)
    }
    
}

//extension ContactListIC: WCSessionDelegate {
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//
//        if let error = error {
//            print("Activation failed with error: \(error.localizedDescription)")
//            return
//        }
//        print("Watch activated with state: \(activationState.rawValue)")
//    }
//
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//
//        print(applicationContext)
//
//        DispatchQueue.main.async {
//            if let contactArray = applicationContext["requestForiOS"] as? String{
//                //self.contactListArray = (contactArray as! [Contact])
//
//                print("Recieve application:- \(contactArray)")
//            }
//        }
//    }
//}

extension ContactListIC {
    
//    private var touchLocation = CGPoint.zero
//    @IBAction func handleLongPress(_ recognizer: WKLongPressGestureRecognizer) {
//        WKInterfaceDevice.current().play(.click)
//
//        switch recognizer.state {
//        case .began:
//            touchLocation = recognizer.locationInObject()
//            print("User just touched the screen at \(touchLocation)")
//        case .changed:
//            let location = recognizer.locationInObject()
//            let distance = sqrt(pow(touchLocation.x - location.x, 2.0)
//                + pow(touchLocation.y - location.y, 2.0))
//            if distance >= 10 {
//                print("User traveled too far from \(touchLocation)")
//                // invalidate the gesture recognizer
//                recognizer.isEnabled = false
//                recognizer.isEnabled = true
//            }
//        case .ended:
//            print("User successfully completed a tap-like gesture")
//        default:
//            break
//        }
//    }
    
}
