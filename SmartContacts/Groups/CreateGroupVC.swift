//
//  CreateGroupVC.swift
//  SmartContacts
//
//  Created by chaman-8419 on 07/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class CreateGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: Properties
    
    lazy var groupTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.frame = self.view.frame
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
    
    var contactTableData =   [Contact]() // For fetching the Contacts from Database
    
    var groupArray = [String:[Contact]]() // Key is Group Name & Value is Group Contacts
    
    var groupSavedClosure: (([String:[Contact]]) -> Void)?  // Used for transfer group array in GroupVC
    
    var groupName: String?

    var refContact:[Contact]?

    
    // MARK: View LifeCycles Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeVC))
        
        groupTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let oldContact = refContact {
            print(oldContact)
            print("-------------")
            
             self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateGroup))
            
            self.contactTableData = ContactDataManager.sharedManager.getContactsList()
            
            for contact in oldContact {
                    contactTableData.removeAll { (setContact) -> Bool in
                        setContact.contactID == contact.contactID
                    }
            }
            
            contactTableData = contactTableData.sorted(by: {$0.firstName! < $1.firstName!})
            self.groupTableView.reloadData()
            
        } else {
            
            self.title = "Select Contacts"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(alertForGroupName))
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            
            self.contactTableData = ContactDataManager.sharedManager.getContactsList()
            contactTableData = contactTableData.sorted(by: {$0.firstName! < $1.firstName!})
            
            if contactTableData.count == 0 {
                
                // "No Results" display when search string does not with database
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.groupTableView.bounds.size.width, height: self.groupTableView.bounds.size.height))
                noDataLabel.text = "No Contact Available"
                noDataLabel.font = UIFont.systemFont(ofSize: 25)
                noDataLabel.textColor = UIColor.gray
                noDataLabel.textAlignment = .center
                self.groupTableView.backgroundView = noDataLabel
                self.groupTableView.backgroundColor = UIColor.white
                self.groupTableView.separatorStyle = .none
            }
            
            self.groupTableView.reloadData()
        }
    }
    
   
    
    
    // MARK: Local Method
    func createGroup() {
        var contactArray = [Contact]() // For collect all Contacts
        
        for contact in contactTableData {
            if contact.isSelected {
                contactArray.append(contact)
            }
        }
        groupArray[groupName!] = contactArray
        
        GroupDataManager.sharedManager.addGroup(groupDict: groupArray, groupName: groupName!)
        GroupDataManager.sharedManager.saveGroupList()
        iCloudDataManager.sharedManager.addGroupOniCloud(groupDict: groupArray, groupName: groupName!)
        
        self.dismiss(animated: true) {
            self.groupSavedClosure?(self.groupArray)
        }
    }
    
    @objc func updateGroup() {
        
        
        var contactArray = refContact! // For collect all Contacts
        
        for contact in contactTableData {
            if contact.isSelected {
                print(contact.firstName!)
                contactArray.append(contact)
            }
        }
        
        let groupName = self.title
        groupArray[groupName!] = contactArray
        
        GroupDataManager.sharedManager.addGroup(groupDict: groupArray, groupName: groupName!)
        GroupDataManager.sharedManager.saveGroupList()
        iCloudDataManager.sharedManager.addGroupOniCloud(groupDict: groupArray, groupName: groupName!)
        
        self.dismiss(animated: true) {
            self.groupSavedClosure?(self.groupArray)
        }
    }
    
    
    @objc func alertForGroupName() {
        
        let ac = UIAlertController(title: "Enter Group Name", message: nil, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (alert) in
            self.groupName = ac.textFields![0].text! as String
            self.createGroup()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Group name"
        }
        ac.addAction(submitAction)
        
        present(ac, animated: true, completion: nil)
    }
    
    
    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Table View Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        
        cell.contact = contactTableData[indexPath.row]

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.allowsMultipleSelection = true
        let cell = tableView.cellForRow(at: indexPath)
        
        if  cell!.accessoryType == UITableViewCell.AccessoryType.checkmark {
            cell!.accessoryType = UITableViewCell.AccessoryType.none
            contactTableData[indexPath.row].isSelected = false
            
        } else {
            cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
            contactTableData[indexPath.row].isSelected = true
            
        }
        
        var f = 0
        for contact in contactTableData {
            if contact.isSelected {
               f = 1
            }
        }
        
        if f == 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
}
