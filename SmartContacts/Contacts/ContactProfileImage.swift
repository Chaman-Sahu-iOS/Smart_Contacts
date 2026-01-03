//
//  ContactProfileImage.swift
//  SmartContacts
//
//  Created by chaman-8419 on 14/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class ContactProfileImage: UIViewController {

    var contact: Contact?
    
    override func viewDidLoad() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissFullscreenImage(_:)))
        
        profileImageTapped()
    }
    
    
    func profileImageTapped() {
        
        let newImageView = UIImageView(image: contact!.contactImage!)
       // newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        
        newImageView.translatesAutoresizingMaskIntoConstraints = false

        newImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        newImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        newImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        newImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
    
        self.dismiss(animated: true, completion: nil)
    }

}
