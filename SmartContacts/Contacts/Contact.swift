//
//  Contact.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 05/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class Contact: NSObject {
   

    var contactID: Int32?
    var firstName: String?
    var lastName: String?
    var companyName: String?
    var mobile: String?
    var email: String?
    var contactImage: UIImage?
    /// Pre-compressed JPEG data. When set, batch inserts prefer this over
    /// re-encoding `contactImage`, which avoids keeping decoded UIImages
    /// in memory during large Google Contacts imports.
    var contactImageData: Data?
    var isFavorite: Bool?
    var isSelected: Bool = false
    var qrCodeImage: UIImage = UIImage()
    
    
    override init() {
        super.init()
    }
    
    init(contactId: Int32, firstName: String, lastName: String, companyName: String, mobile: String, email:String, image: UIImage, isFavorite: Bool) {
      
        self.contactID = contactId
        self.firstName = firstName
        self.lastName = lastName
        self.companyName = companyName
        self.mobile = mobile
        self.email = email
        self.contactImage = image
        self.isFavorite = isFavorite
    }
    
}
