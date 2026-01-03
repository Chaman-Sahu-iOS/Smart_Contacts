//
//  GroupVC.swift
//  SmartContacts
//
//  Created by chaman-8419 on 07/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import  CloudKit
import WatchConnectivity

class GroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Views
    
    lazy var groupTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
    let transition = CustomTransition()
    
    //MARK:- Data
    
    var groupTableData =   [String]()  // For Group Name
    var groupData      =    [String:[Contact]]()  // Key is Group Name & Value is Group Contact
    
    let publicDatabase = CKContainer.default().publicCloudDatabase

    var resultSearchController: UISearchController!
    let groupSearchVC = GroupSearchVC()
    
    // MARK: View LifeCycles Functions
    
    override func viewDidLayoutSubviews() {
        groupTableView.frame = self.view.frame
        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Groups"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.view.backgroundColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroupButtonPressed))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importGroupsFromiCloud))
        
        groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchFunction()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateGroupTableData()
        
       // This Method only work in iPad and use for the first of Group Detail in table
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            if groupTableData.indices.contains(0) {
                
                let defaultGroupName = groupTableData[0]
                
                let groupDetailVC = GroupDetailsVC()
                groupDetailVC.contactArray = groupData[defaultGroupName]
                groupDetailVC.title        = defaultGroupName
                groupDetailVC.groupTitleClosure = { (groupName) in
                    
                    self.updateGroupTableData()
                    
                    let customIndexPath = IndexPath(item: 0, section: 0)
                    self.groupTableView.selectRow(at: customIndexPath, animated: true, scrollPosition: .bottom)
                }
                
                let naviCon = UINavigationController(rootViewController: groupDetailVC)
                self.showDetailViewController(naviCon, sender: self)
                
                
                
            } else {
                let groupDetailVC = GroupDetailsVC()
                let naviCon = UINavigationController(rootViewController: groupDetailVC)
                self.showDetailViewController(naviCon, sender: self)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        // Only use in iPad for first row selection
        if UIDevice.current.userInterfaceIdiom == .pad {
            if groupTableData.indices.contains(0) {
                let indexPath = IndexPath(row: 0, section: 0)
                groupTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
    
    // MARK: Local Method
    
    func updateGroupTableData() {
        groupData = GroupDataManager.sharedManager.getGroupsList()
        groupTableData.removeAll()
        
        for (key, _) in groupData {
            let groupName = key
            self.groupTableData.append(groupName)
        }
        
        groupTableData = groupTableData.sorted(by: {$0 < $1})
        self.groupTableView.reloadData()
    }
    
    func searchFunction() {
        
        resultSearchController = UISearchController(searchResultsController: groupSearchVC)
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        definesPresentationContext = true
        resultSearchController.searchResultsUpdater = groupSearchVC
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.resultSearchController.searchBar.isHidden = false
        self.resultSearchController.searchBar.becomeFirstResponder()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            groupSearchVC.searchClouser = { (groupDataArray, groupName) in
                let groupDetailVC = GroupDetailsVC()
                groupDetailVC.contactArray = groupDataArray
                groupDetailVC.title        = groupName
                let naviCon = UINavigationController(rootViewController: groupDetailVC)
                self.showDetailViewController(naviCon, sender: self)
            }
        }
    }
    
    
    @objc func createGroupButtonPressed() {
        
        let createGroupVC = CreateGroupVC()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            createGroupVC.groupSavedClosure = { (group) in
                self.viewWillAppear(true)
            }
        }
        
        let naviCon       = UINavigationController(rootViewController: createGroupVC)
        naviCon.modalPresentationStyle = .pageSheet
        self.present(naviCon, animated: true, completion: nil)
    }
   
    @objc func importGroupsFromiCloud() {
        
        var groupArray = [String:[Contact]]()
        
        
        let query = CKQuery(recordType: "Groups", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
           // DispatchQueue.main.async {
                if error != nil {
                     self.handle(error: error!)
                } else {
                    for record in records!{
                        
                        var contactArray = [Contact]()
                        print("Group fetched from iCloud seccessfully")
                        let groupName = record.value(forKey: "groupName") as? String
                        
                        
                        let reference = CKRecord.Reference(record: record, action: .none)
                        let pred      = NSPredicate(format: "owningGroups == %@", reference)
                        let query     = CKQuery(recordType: "Contacts", predicate: pred)
                        
                        self.publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
                            
                            if let error = error {
                                self.handle(error: error)
                            } else {
                                if let results = results {
                                    for data in results {
                                        let contact = Contact()
                                        contact.firstName    = data.value(forKey: "firstName") as? String
                                        contact.lastName     = data.value(forKey: "lastName") as? String
                                        contact.mobile       = data.value(forKey: "mobile") as? String
                                        contact.companyName  = data.value(forKey: "companyName") as? String
                                        contact.email        = data.value(forKey: "email") as? String
                                        contact.contactID    = data.value(forKey: "contactID") as? Int32
                                        
                                        guard let asset = data.value(forKey: "photo") as? CKAsset else {
                                            print("assest")
                                            return
                                        }
                                        
                                        let imageData: Data
                                        do {
                                            imageData = try Data(contentsOf: asset.fileURL!)
                                        } catch {
                                            print("image data")
                                            return
                                        }
                                        contact.contactImage = UIImage(data: imageData)
                                        
                                        self.ifContactValueNill(contact: contact)
                                        
                                        contactArray.append(contact)
                                        print("contact fetch from icloud successfully")
                                    }
                                    
                                    groupArray[groupName!] = contactArray
                                    GroupDataManager.sharedManager.addGroup(groupDict: groupArray, groupName: groupName!)
                                }
                            }
                        }
                    }
                }
            }
      //  }
        
        DispatchQueue.main.async {
        
            GroupDataManager.sharedManager.saveGroupList()
            self.groupData = GroupDataManager.sharedManager.getGroupsList()
            self.groupTableData.removeAll()
            
            for (key, _) in self.groupData {
                let groupName = key
                self.groupTableData.append(groupName)
            }
            
            self.groupTableData = self.groupTableData.sorted(by: {$0 < $1})
            self.groupTableView.reloadData()
        }
    }
    
    
    func handle(error: Error) {
        let alert = UIAlertController(title: "Error", message: String(describing: error.localizedDescription), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
        // self.refreshControl!.endRefreshing()
    }
    
    func ifContactValueNill(contact: Contact) {
        
        if contact.firstName == nil {
            contact.firstName = ""
        }
        
        if contact.lastName == nil {
            contact.lastName = ""
        }
        
        if contact.companyName == nil {
            contact.companyName = ""
        }
        
        if contact.mobile == nil {
            contact.mobile = ""
        }
        
        if contact.email == nil {
            contact.email = ""
        }
        
        contact.isFavorite = false
        
        if contact.contactImage == nil {
            contact.contactImage = UIImage(named: "default_user")
        }
    }
    
    // MARK: Table View Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = groupTableData[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let groupName = groupTableData[indexPath.row]
            groupTableData.remove(at: indexPath.row)
            GroupDataManager.sharedManager.deleteGroups(groupName: groupName)
            iCloudDataManager.sharedManager.deleteGroupFromiCloud(groupName: groupName)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.viewWillAppear(true)
            self.groupTableView.reloadData()
        }
    }
    
    //MARK:- UITable View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // tableView.deselectRow(at: indexPath, animated: true)
        
        let groupName = groupTableData[indexPath.row]
        
        let groupDetailVC = GroupDetailsVC()
       
        groupDetailVC.contactArray = groupData[groupName]
        groupDetailVC.title        = groupName
        let naviCon = UINavigationController(rootViewController: groupDetailVC)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
        } else {
            
            groupDetailVC.groupTitleClosure = { (groupName) in
                
                self.updateGroupTableData()
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
            
            //Update tableData when click on any row
            self.updateGroupTableData()
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)

            showDetailViewController(naviCon, sender: self)
        }
    }
}

extension GroupVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
}

//extension GroupVC: WCSessionDelegate {
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        
//        if let error = error {
//            print("Activation in iOS failed with error: \(error.localizedDescription)")
//            return
//        }
//        print("iOS activated with state: \(activationState.rawValue)")
//    }
//    
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("sessionDidBecomeInactive")
//    }
//    
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("sessionDidDeactive")
//    }
//    
//    
//    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        
//        guard let response = message["request"] as? String else {
//            print("Response from Phone failed..")
//            replyHandler([:])
//            return
//        }
//        
//        var groupTableData =   [String]()
//        groupData = GroupDataManager.sharedManager.getGroupsList()
//        groupTableData.removeAll()
//        
//        for (key, _) in groupData {
//            let groupName = key
//            self.groupTableData.append(groupName)
//        }
//        
//        groupTableData = groupTableData.sorted(by: {$0 < $1})
//        
//        var groupsArray = [String: [Any]]()
//        
//        groupsArray["groupsName"] = groupTableData
//        
//        switch response {
//        case "Groups":
//            replyHandler(groupsArray)
//        default:
//            replyHandler([:])
//        }
//    }
//    
//    // Change The Size of Image
//    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
//        
//        // This is the rect that we've calculated out and this is what is actually used below
//        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
//        
//        // Actually do the resizing to the rect using the ImageContext stuff
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
//        image.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
//}
//
