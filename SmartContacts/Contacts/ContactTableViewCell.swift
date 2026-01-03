//
//  ContactTableViewCell.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 12/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var searchNameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let meLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.lightGray
        //label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    var contactImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    
    
    var contact: Contact? {
        didSet {
            guard let contactItem = contact else {
                return
            }
            nameLabel.text = contactItem.firstName! + " " + contactItem.lastName!
            contactImage.image  = contactItem.contactImage!
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.containerView.addSubview(nameLabel)
        self.containerView.addSubview(searchNameLabel)
        self.containerView.addSubview(phoneLabel)
        self.containerView.addSubview(emailLabel)
        self.containerView.addSubview(meLabel)
        
        self.addSubview(containerView)
        self.addSubview(contactImage)
        
        contactImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        contactImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        contactImage.widthAnchor.constraint(equalToConstant: 50).isActive  = true
        contactImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
        contactImage.layer.cornerRadius = 25
        contactImage.clipsToBounds = true
        
        containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive  = true
        containerView.leadingAnchor.constraint(equalTo: self.contactImage.trailingAnchor, constant: 10).isActive  = true
        containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive  = true
        nameLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        
        meLabel.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor).isActive  = true
     //   meLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        meLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35).isActive = true
    
        // SearchName Label, phoneLabel and emailLabel are used in Only Search Functions
        
        searchNameLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16).isActive = true
        searchNameLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        searchNameLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        
        phoneLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 42).isActive = true
        phoneLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        phoneLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        
        emailLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 42).isActive = true
        emailLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
