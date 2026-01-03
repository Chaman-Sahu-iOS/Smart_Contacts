//
//  FavouritesListRowController.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 02/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit

class FavouritesListRowController: NSObject {

    @IBOutlet var favouriteLabel: WKInterfaceLabel!
    
    var contact: Contact?{
        
        didSet {
            
            guard let contact = contact else { return}
            
            favouriteLabel.setText(contact.firstName)
        }
    }
}
