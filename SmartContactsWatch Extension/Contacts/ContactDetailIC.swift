//
//  ContactDetailIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 28/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation
import Contacts
import UIKit

class ContactDetailIC: WKInterfaceController {
    
    
    @IBOutlet var contactName: WKInterfaceLabel!
    @IBOutlet var contactImage: WKInterfaceImage!
    @IBOutlet weak var contactImageButton: WKInterfaceButton!
    
    @IBOutlet var contactPhoneButton: WKInterfaceButton!
    @IBOutlet var contactMsgButton: WKInterfaceButton!
    @IBOutlet var contactMailButton: WKInterfaceButton!
    
    @IBOutlet var qrCodeButton: WKInterfaceButton!
    
    var mobile = String()
    var email = String()
    
    var contactDetail: Contact? {
        didSet {
            
            guard let contact = contactDetail else { return }
            
            contactName.setText("\(contact.firstName!)")
            contactImageButton.setBackgroundImage(contact.contactImage)
            mobile = contact.mobile ?? ""
            email = contact.email ?? ""
        }
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let contact = context as? Contact {
            self.contactDetail = contact
            
            if contactDetail?.mobile == "" {
                contactPhoneButton.setEnabled(false)
                contactMsgButton.setEnabled(false)
            } else {
                contactPhoneButton.setEnabled(true)
                contactMsgButton.setEnabled(true)
            }
            
            if contactDetail?.email == "" {
                contactMailButton.setEnabled(false)
            } else {
                contactMailButton.setEnabled(true)
            }
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
    
    @IBAction func phoneButtonTapped() {
        print("phoneButtonTapped")
        
        let phone = mobile.replacingOccurrences(of: " ", with: "")
        
        if let telURL = URL(string:"tel:\(phone)") {
            let wkExt=WKExtension.shared()
            wkExt.openSystemURL(telURL)
        }
    }
    
    @IBAction func msgButtonTapped() {
        print("msgButtonTapped")
        
        let phone = mobile.replacingOccurrences(of: " ", with: "")
        
        //let messageBody = "Hello World!"
       // let urlSafeBody = messageBody.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        if let url = URL(string: "sms:\(phone)") {
            WKExtension.shared().openSystemURL(url)
        }
    }
    
    @IBAction func mailButtonTapped() {
        print("mailButtonTapped")
        
//        let email = "chaman.s@zohocorp.com"
//       // let email = "foo@example.com?cc=bar@example.com&subject=Greetings%20from%20Cupertino!&body=Wish%20you%20were%20here!"
//        let messageBody = "Hello World!"
//        // let urlSafeBody = messageBody.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
//        let urlSafeBody = messageBody.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
//        if let url = URL(string: "mailto:\(email)") {
//
//            WKExtension.shared().openSystemURL(url)
//        }
        
    }
    
    
    @IBAction func qrCodeButtonTapped() {
        
        let vc = contactDetail?.qrCodeImage
        self.pushController(withName: "QRCodeImage", context: vc)
        
    }
    
    
    @IBAction func contactImageButtonTapped() {
        
        print("profile image tapped")
        let vc = contactDetail?.contactImage
        self.pushController(withName: "ProfileImage", context: vc)
    }
    
}

