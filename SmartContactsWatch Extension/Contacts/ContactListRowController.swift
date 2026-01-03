//
//  ContactListRowController.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 28/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit

class ContactListRowController: NSObject {
    
    @IBOutlet var nameLabel: WKInterfaceLabel!
    
    var contact: Contact?{
        
        didSet {
            
            
            guard let contact = contact else { return}
            
            nameLabel.setText(contact.firstName)
        }
    }
}
