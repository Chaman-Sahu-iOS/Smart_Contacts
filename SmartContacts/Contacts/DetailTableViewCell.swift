//
//  DetailTableViewCell.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 20/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    // MARK:- Properties
    
    var detailTitle:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor =  _ColorLiteralType(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailValue:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK:- Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(detailTitle)
        self.addSubview(detailValue)
        
        detailTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        detailTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        
        detailValue.topAnchor.constraint(equalTo: self.detailTitle.bottomAnchor, constant: 10).isActive = true
        detailValue.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive  = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
