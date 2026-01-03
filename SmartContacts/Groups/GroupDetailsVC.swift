//
//  GroupDetailsVC.swift
//  SmartContacts
//
//  Created by chaman-8419 on 07/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class GroupDetailsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //MARK: Views
    
    lazy var groupTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
       // tempTableView.frame = self.view.frame
       // tempTableView.dataSource = self
       // tempTableView.delegate = self
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
    let groupTitleButton: UIButton = {
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        button.setTitleColor(UIColor.black, for: .normal)
        return button
    }()
    
    // MARK: Data
    var groupContactTableData = [Contact]()
    let transition = CustomTransition()
    
    var groupTitleClosure: ((String) -> Void)?
    
    var contactArray: [Contact]? {
        didSet {
            groupContactTableData = contactArray!
            groupContactTableData = groupContactTableData.sorted(by: {$0.firstName! < $1.firstName!})
        }
    }
    
    var oldGroupName: String?
    
    // MARK: View LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        oldGroupName = self.title
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        
        groupTitleButton.setTitle(oldGroupName, for: .normal)
        groupTitleButton.addTarget(self, action: #selector(changeGroupTitle), for: .touchUpInside)
        groupTitleButton.showsTouchWhenHighlighted = true
        container.addSubview(groupTitleButton)

        self.navigationItem.titleView = container
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let backButton = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .done, target: self, action: #selector(closeController))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactInGroup))
        
        groupTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor      =  UIColor(white: 0.95, alpha: 0.5)
        self.navigationController?.navigationBar.isTranslucent     =  true
        self.navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
    }
   
    override func viewDidLayoutSubviews() {
        groupTableView.frame = self.view.frame
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    // MARK: Local Method
    
    
    @objc func changeGroupTitle() {
        print("group")
        
        let ac = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: { (alert) in

            let newGroupName = ac.textFields![0].text! as String
            GroupDataManager.sharedManager.updateGroupName(groupName: self.oldGroupName!, newGroupName: newGroupName)
            self.groupTitleButton.setTitle(newGroupName, for: .normal)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                 self.groupTitleClosure!(newGroupName)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addTextField { (textField) in
            textField.text        = self.oldGroupName
        }
        ac.addAction(submitAction)
        
        present(ac, animated: true, completion: nil)
    }
    
    @objc func addContactInGroup() {
        
        let createGroupVC = CreateGroupVC()
        createGroupVC.refContact = groupContactTableData
        createGroupVC.title      = self.title
        createGroupVC.groupSavedClosure = { ( array: [String: [Contact]] ) in
            
            for (_, value) in array {
                            self.groupContactTableData = value
                            self.alertSuccessfullUpdate()
                            self.groupTableView.reloadData()
                        }
        }
        let naviCon = UINavigationController(rootViewController: createGroupVC)
        naviCon.modalPresentationStyle = .pageSheet
        self.present(naviCon, animated: true, completion: nil)
    }
    
    func alertSuccessfullUpdate() {
        let alert = UIAlertController(title: "", message: "Group Updated Successfully..", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func closeController() {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
             self.dismiss(animated: true, completion: nil)
        } else {
             navigationController?.popViewController(animated: true)
        }
      
    }
    
    // MARK: TableView Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return groupContactTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.contact = groupContactTableData[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            GroupDataManager.sharedManager.deleteContactFromGroup(contact: groupContactTableData[indexPath.row])
            iCloudDataManager.sharedManager.deleteContactFromGroupOniCloud(contact: groupContactTableData[indexPath.row])
            
            groupContactTableData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contactDetailVC = ContactDetailVC(contact: groupContactTableData[indexPath.row])
        let naviCon = UINavigationController(rootViewController: contactDetailVC)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
        } else {
            
            contactDetailVC.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .done, target: self, action: #selector(closeController))
            contactDetailVC.contactSavedClosure = { (contact) in
                self.groupContactTableData[indexPath.row] = contact
                self.groupTableView.reloadData()
            }
            
            self.navigationController?.pushViewController(contactDetailVC, animated: true)
          
        }
       
        
    }
}

extension GroupDetailsVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
}
