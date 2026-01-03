//
//  QRCodeImageIC.swift
//  SmartContactsWatch Extension
//
//  Created by chaman-8419 on 08/07/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import WatchKit
import Foundation


class QRCodeImageIC: WKInterfaceController {

    @IBOutlet var qrCodeImageButton: WKInterfaceButton!
    
    
    var image: UIImage? {
        didSet {
            guard let image = image else {
                return
            }
            
            qrCodeImageButton.setBackgroundImage(image)
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let image = context as? UIImage {
            self.image = image
        }
    }

    @IBAction func qrCodeImageButtonTapped() {
        pop()
    }
    
}
