//
//  ContactDetailsVC.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 04/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import os.log

class ContactDetailsVC: UIViewController {

    // MARK:- Properties
    
    var name: String
    var age: Int
    var address: String
    
    
    
   
    
    var contactArray: [String] = [String]()
    
    // MARK:- Initializers
    
    init(name: String, age: Int, address: String)
    {
       // super.init()
        self.name = name
        self.age = age 
        self.address = address
        
        super.init(nibName: nil, bundle: nil)
    } 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- View Life Cycle Fuctions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.title = "Contact Details"
        
      
        
        showDetail()
    }
    
    // MARK:- Local functions
    
    
    
    // Alert function for show detail of contact
    func showDetail() {
        
        
        let alert = UIAlertController(title: "Show Details", message: "Name: \(String(describing: name))\n Age: \(String(describing: age))\n Address: \(String(describing: address))", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            
            self.pressOk()
        }))
        
        present(alert, animated: true, completion: nil)
    }

    // Alert function for successful submission
    @objc func pressOk() {
        
        let alert = UIAlertController(title: "Successful Submit", message: "Congratulation", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { alert in
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        present(alert, animated: true, completion:  nil)
        
    }

}
