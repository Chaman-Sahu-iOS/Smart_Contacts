//
//  ProfileImageIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 29/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import WatchKit

class ProfileImageIC: WKInterfaceController {

   // @IBOutlet weak var profileImageTapped: WKInterfaceImage!
    @IBOutlet weak var profileImage: WKInterfaceButton!
    
    
    var image: UIImage? {
        didSet {
            guard let image = image else {
                return
            }
            
           // profileImageTapped.setImage(image)
            profileImage.setBackgroundImage(image)
        }
    }
    
    override func awake(withContext context: Any?) {
        
        if let image = context as? UIImage {
            self.image = image
        }
    }
    
    @IBAction func profileImageButtonTapped() {
        self.pop()
    }
}
