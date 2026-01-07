//
//  ContactTableViewController.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 04/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import Contacts
import GoogleSignIn
import MBProgressHUD
import CloudKit
import WatchConnectivity

class ContactListVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK:- Properties
    
    lazy var listTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
    // Used in tableData
    var contactListArray:[Contact]?
    var contactDictionary = [String: [Contact]]()
    var contactSectionTitles = [String]()
    
    // Used in Search Controller
    var resultSearchController: UISearchController!
    let contactSearchVC = ContactSearchVC()
    
    // Used in custom transition like push view controller
    let transition = CustomTransition()
    
    // Used in iCloud Database
    let publicDatabase  = CKContainer.default().publicCloudDatabase
    var cloudRecords   = [CKRecord]()
    
    // These property only for Owner Contact
    var ownContact:Contact!
    let nameLabel = UILabel()
    let ownerImageView = UIImageView()
    
    
    // MARK:- ViewController Life Cycle Method
    
    //Call after's the Controller view loaded in memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Bar Title
        self.navigationItem.title = "Contacts"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Bar Button
        let addButton       =   UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addNewContact))
        let importButton    =   UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showImportActionSheet))
        self.navigationItem.rightBarButtonItems = [addButton, importButton]
        
        // Setting Navigation Bar Button only show in iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings_filled"), style: .plain, target: self, action: #selector(settingsMethod))
        }
        
        // Register tableView with indentifier and Custom Cell
        listTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchFunction()
        
//        if WCSession.isSupported() {
//
//            WCSession.default.delegate = self
//            WCSession.default.activate()
//        }
    }
    
    //Use when the device are rotated landscape to portrait or viece-versa to update the frame of tableView
    override func viewDidLayoutSubviews() {
        listTableView.frame = self.view.frame
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    
    // Called before the view is loaded in view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        
      //  self.updateAppContext()
        
        self.myContactHeaderView()
        
        self.refreshContactTableList()
        
        // Check if cloud status is on then sync the data
        let isSync = AppSettings.shared.isSynchWithICloud
        if isSync == true {
            let refreshControl = UIRefreshControl()
            //     refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
            listTableView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(queryToFetchICloudDatabase), for: .valueChanged)
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.selectFirstRowIniPad()
        }
    }
    
    //Called every time you land on the screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (contactListArray?.indices.contains(0))! {
                let indexPath = IndexPath(row: 0, section: 0)
                listTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
    
    // MARK:- Local Functions
    
    func refreshContactTableList() {
        self.contactListArray    =   ContactDataManager.sharedManager.getContactsList() //Fetch the All Contacts From The Database
        self.populateContactSections()   //Extract Contact by section wise in tableView
        
        if let count = contactListArray?.count {
            contactCounts(count: count) // Show the count of contact bottom of Table
        }
        
        self.listTableView.reloadData()
    }
    
    func myContactHeaderView() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: listTableView.frame.size.width, height: 100))
        
        let ownerImage = UIImage(named: "default_user")
        
        let contactArray = ContactDataManager.sharedManager.getContactsList()
        
        for contact in contactArray {
            if contact.contactID == 800611764 {
                ownContact = contact
            }
        }
        
        if ownContact == nil {
            
            ownContact = Contact()
            
            ownContact.contactImage = ownerImage
            ownContact.firstName    = "John"
            ownContact.lastName     = ""
            ownContact.contactID    = 800611764
            ownContact.companyName  = ""
            ownContact.mobile       = ""
            ownContact.email        = ""
            ownContact.isFavorite   = false
            
            ContactDataManager.sharedManager.add(contact: ownContact)
            ContactDataManager.sharedManager.saveContactList()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(_:)))
        headerView.addGestureRecognizer(tap)
        
        headerView.addSubview(ownerImageView)
        ownerImageView.image = ownContact.contactImage
        ownerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        ownerImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        ownerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        ownerImageView.widthAnchor.constraint(equalToConstant: 70).isActive  = true
        ownerImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        ownerImageView.layer.cornerRadius = 35
        ownerImageView.clipsToBounds = true
        
        nameLabel.text = ownContact.firstName! + " " + ownContact.lastName!
        nameLabel.font = UIFont.systemFont(ofSize: 24)
        
        headerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 25).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 100).isActive = true
        
        let myCardLabel = UILabel()
        myCardLabel.text = "My Card"
        myCardLabel.font = UIFont.systemFont(ofSize: 16)
        myCardLabel.textColor = UIColor.lightGray
        
        headerView.addSubview(myCardLabel)
        myCardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        myCardLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60).isActive = true
        myCardLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 100).isActive = true
        
        listTableView.tableHeaderView = headerView
    }
    
    @objc func headerViewTapped(_ sender: UITapGestureRecognizer)  {
        
        self.listTableView.reloadData()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let vc = ContactDetailVC(contact: ownContact)
            let naviCon = UINavigationController(rootViewController: vc)
            naviCon.modalPresentationStyle = .fullScreen
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
        } else {
            let vc = ContactDetailVC(contact: ownContact)
            vc.contactSavedClosure = { (contact) in
                
                self.refreshContactTableList()
                
                self.ownContact = contact
                self.nameLabel.text = contact.firstName! + " " + contact.lastName!
                self.ownerImageView.image = contact.contactImage
            }
            vc.contactDeleteClosure = { (contact) in
                
                self.ownContact = nil
                self.nameLabel.text = "John"
                self.ownerImageView.image = UIImage(named: "default_user")
                self.viewWillAppear(true)
            }
            
            let naviCon = UINavigationController(rootViewController: vc)
            self.showDetailViewController(naviCon, sender: self)
        }
    }
    
    
    func populateContactSections() {
        
        contactSectionTitles.removeAll()
        contactDictionary.removeAll()
        
        contactListArray = contactListArray?.sorted(by: {$0.firstName! < $1.firstName!})
        
        // Take Contact Name first character as ContactSetionTitles as well as ContactDictionary Key
        for contact in contactListArray! {
            var contactKey = String(contact.firstName!.prefix(1))
            
            contactKey = contactKey.uppercased()
            
            if (contactKey >= "A" && contactKey <= "Z" ) {
                if var contactValue = contactDictionary[contactKey] {
                    contactValue.append(contact)
                    contactDictionary[contactKey] = contactValue
                } else {
                    contactDictionary[contactKey] = [contact]
                }
            } else {
                contactKey = "#"
                if var contactValue = contactDictionary[contactKey] {
                    contactValue.append(contact)
                    contactDictionary[contactKey] = contactValue
                } else {
                    contactDictionary[contactKey] = [contact]
                }
            }
        }
        
        contactSectionTitles = [String](contactDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: {$0 < $1})
        
        if contactSectionTitles.indices.contains(0) {
            if contactSectionTitles[0] == "#" {
                contactSectionTitles.remove(at: 0)
                contactSectionTitles.append("#")
            }
        }
    }
    
    func searchFunction() {
        resultSearchController = UISearchController(searchResultsController: contactSearchVC)
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        definesPresentationContext = true
        resultSearchController.searchResultsUpdater = contactSearchVC
        navigationItem.searchController = resultSearchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.resultSearchController.searchBar.isHidden = false
        self.resultSearchController.searchBar.becomeFirstResponder()
        
        // This is used in iPad when search bar tapped it's work on delegate and closure
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            contactSearchVC.searchClouser = { (contact, index)  in
                
                let vc = ContactDetailVC(contact: contact)
                vc.contactSavedClosure = { (updatedContact) in
                    self.refreshContactTableList()
                    
                    self.contactSearchVC.filterTableData[index] = updatedContact
                    self.contactSearchVC.searchTableView.reloadData()
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    self.contactSearchVC.searchTableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
                }
                vc.contactDeleteClosure = { (contact) in
                   self.refreshContactTableList()
                    
                    if self.contactSearchVC.filterTableData.indices.contains(index + 1) {
                        self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: self.contactSearchVC.filterTableData[index + 1])), sender: self)
                    }
                    
                    self.contactSearchVC.filterTableData.remove(at: index)
                    self.contactSearchVC.searchTableView.reloadData()
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    self.contactSearchVC.searchTableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
                }
                
                let naviCon = UINavigationController(rootViewController: vc)
                self.showDetailViewController(naviCon, sender: self)
            }
        }
    }
    
    func contactCounts(count: Int) {
        
        let contactCountContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
        
        let containerUpperLine = UIView()
        containerUpperLine.backgroundColor = UIColor.lightGray
        contactCountContainer.addSubview(containerUpperLine)
        containerUpperLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            containerUpperLine.topAnchor.constraint(equalTo: contactCountContainer.topAnchor),
            containerUpperLine.trailingAnchor.constraint(equalTo: contactCountContainer.trailingAnchor),
            containerUpperLine.leadingAnchor.constraint(equalTo: contactCountContainer.leadingAnchor),
            containerUpperLine.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        let countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        countLabel.textAlignment = .center
        countLabel.textColor     = UIColor.gray
        countLabel.font          = UIFont.systemFont(ofSize: 20)
        countLabel.text = "\(count) Contacts"
        
        contactCountContainer.addSubview(countLabel)
        
        if count != 0 {
            self.listTableView.tableFooterView = contactCountContainer
        } else {
            self.listTableView.tableFooterView = nil
        }
    }
    
    // When Contact List Appear Default Value for Contact Detail
    func selectFirstRowIniPad() {
        
        if contactSectionTitles.indices.contains(0) {
            let contactKey = self.contactSectionTitles[0]
            if let contactValue = self.contactDictionary[contactKey] {
                
                let defaultContact = contactValue[0]
                let contactDetailVC = ContactDetailVC(contact: defaultContact)
                contactDetailVC.contactSavedClosure = { (contact) in
                    self.refreshContactTableList()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.listTableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
                }
                contactDetailVC.contactDeleteClosure = { (contact) in
                    
                    self.refreshContactTableList()
                    
                    let contactKey = self.contactSectionTitles[0]
                    if let contactValue = self.contactDictionary[contactKey] {
                        self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: contactValue[0])), sender: self)
                           self.viewWillAppear(true)
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.listTableView.selectRow(at: indexPath, animated: false, scrollPosition: .bottom)
                    }
                 
                }
                showDetailViewController(UINavigationController(rootViewController: contactDetailVC), sender: self)
            }
            
        } else {
            let contactDetailVC = ContactDetailVC()
            showDetailViewController(UINavigationController(rootViewController: contactDetailVC), sender: self)
        }
    }
    
    
    @objc private func addNewContact() {
        
        let addViewController = AddContactVC(contact: nil)
        
        addViewController.contactSavedClosure = { (contact: Contact) in
           self.showAddContactSuccessAlert()
           self.refreshContactTableList()
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(UINavigationController(rootViewController: addViewController), animated: true, completion: nil)
        } else {
            
            let navCon = UINavigationController(rootViewController: addViewController)
            navCon.modalPresentationStyle = .pageSheet
            self.present(navCon, animated: true, completion: nil)
        }
        
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
    
    @objc func settingsMethod() {
        
        let settingsVC = SettingsVC()
        let naviCon = UINavigationController(rootViewController: settingsVC)
        naviCon.modalPresentationStyle = .formSheet
        self.present(naviCon, animated: true, completion: nil)
    }
    
    // MARK:- Save to iCloud
    
    @objc func queryToFetchICloudDatabase() {
        
        let query = CKQuery(recordType: "Contacts", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            guard error == nil else {
                self.handle(error: error!)
                print("Error to access contact from iCloud: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let records = records else {
                print("Record from iCloud are Nil...")
                return
            }
            self.cloudRecords = records
        }
        
        for data in self.cloudRecords {
            
            let contact = Contact()
            
            contact.firstName    = data.value(forKey: "firstName") as? String
            contact.lastName     = data.value(forKey: "lastName") as? String
            contact.mobile       = data.value(forKey: "mobile") as? String
            contact.companyName  = data.value(forKey: "companyName") as? String
            contact.email        = data.value(forKey: "email") as? String
            contact.contactID    = data.value(forKey: "contactID") as? Int32
            
            guard let asset = data.value(forKey: "photo") as? CKAsset else {
                return
            }
            
            let imageData: Data
            do {
                imageData = try Data(contentsOf: asset.fileURL!)
            } catch {
                return
            }
            contact.contactImage = UIImage(data: imageData)
            
            ifContactValueNill(contact: contact)
            
            
            var flag = 0
            if contactListArray!.count > 0 {
                for data in contactListArray! {
                    if data.contactID == contact.contactID {
                        flag = 1
                        ContactDataManager.sharedManager.update(contact: contact)
                    }
                }
            }
            if flag == 0 {
                  ContactDataManager.sharedManager.add(contact: contact)
            }
            
        }
        
        DispatchQueue.main.async {
            
            ContactDataManager.sharedManager.saveContactList()
            self.refreshContactTableList()
            self.listTableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func deleteFromiCloud(contact: Contact) {
        
        self.contactListArray = ContactDataManager.sharedManager.getContactsList()
        var deleteObjectIds: CKRecord.ID?
        
        for data in cloudRecords {
            
            let id = data.value(forKey: "contactID") as? Int32
            if id == contact.contactID {
                deleteObjectIds = data.recordID
                break
            }
        }
        
        if let recordID = deleteObjectIds {
            publicDatabase.delete(withRecordID: recordID) { (result, error) in
                
                guard error == nil else {
                    // self.handle(error: error!)
                    print("Error to Delete contact from iCloud: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                print("Delete Contact from iCloud sucessfully....")
            }
        }
    }
    
    func handle(error: Error) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK:- Import Apple iPhone Contacts
    func importAppleContacts() {
        
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let err = error {
                print("Failed to request access: ", err)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactOrganizationNameKey, CNContactImageDataKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (iphoneContact, stopPointerIfYouWantToStopEnumerating ) in
                        
                        let contact  = Contact()
                        
                        contact.contactID         = Int32(Int.random(in: 0...1000000000))
                        contact.firstName         = iphoneContact.givenName
                        contact.lastName          = iphoneContact.familyName
                        contact.companyName       = iphoneContact.organizationName
                        contact.mobile            = iphoneContact.phoneNumbers.first?.value.stringValue ?? ""
                        contact.email             = iphoneContact.emailAddresses.first?.value as String? ?? "" as String
                        contact.isFavorite        = false
                        
                        if let data = iphoneContact.imageData {
                            let image = UIImage(data: data)
                            contact.contactImage = image
                        }
                        
                        self.ifContactValueNill(contact: contact)
                        
                        // If First Name is empty then not add in Contact List
                        
                        if contact.firstName != "" {
                            ContactDataManager.sharedManager.add(contact: contact)
                            
                            let isSync = AppSettings.shared.isSynchWithICloud
                            
                            
                            if isSync == true {
                                SettingsVC.shareManager.saveToiCloud(contact: contact)
                            }
                        }
                    })
                } catch let err{
                    print("Failed to enumerate contact", err)
                    return
                }
                
            } else {
                print("Access not granted")
            }
            
            DispatchQueue.main.async {
                
                ContactDataManager.sharedManager.saveContactList()
                self.refreshContactTableList()
            }
        }
    }
    
    
    // MARK:- Import Google Contact
    
    @objc func signInWithGoogle() {
        // Configure OAuth client ID for Google Sign-In v9+
        let clientID = "1009501789746-su8sdu78hc29bs2eotfih4nsqmimuluh.apps.googleusercontent.com"
        let configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.configuration = configuration
        GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: nil, additionalScopes: ["https://www.googleapis.com/auth/contacts"]) { result, error in
            if let error = error {
                print("Google sign-in failed: \(error.localizedDescription)")
                return
            }
            guard result?.user != nil else {
                print("Google sign-in cancelled or no user returned")
                return
            }
            MBProgressHUD.showAdded(to: self.view, animated: true)
            self.getGmailContacts()
        }
    }
    
    @objc func signoutFromGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
    
    func getGmailContacts() {
        
        guard let accessToken = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString else {
            print("Missing access token; ensure sign-in succeeded and scope granted.")
            MBProgressHUD.hide(for: self.view, animated: true)
            return
        }
        let contactsAPIURL = ("https://www.google.com/m8/feeds/contacts/default/full?access_token=\(accessToken)&max-results=\(999)&alt=json&v=3.0")
        
        guard let url = URL(string: contactsAPIURL) else { return }
        
        URLSession.shared.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if(error != nil){
                print("Error with fetching Google Contacts ", error?.localizedDescription as Any)
            }else{
                do {
                    let resultsDictionary   =   try JSONSerialization.jsonObject(with: data!, options: []) as!  Dictionary<String, AnyObject>
                    let feedContacts        =   resultsDictionary["feed"] as! [String:AnyObject]
                    let entryContacts       =   feedContacts["entry"] as! NSArray
                    
                    for aContact in entryContacts{
                        
                        DispatchQueue.main.async {
                            
                            let tempContact = aContact as! [String:Any]
                            let contact = Contact()
                            
                            contact.contactID = Int32(Int.random(in: 0...1000000000))
                            
                            if let nameArray = tempContact["gd$name"] as? [String:Any]{
                                
                                if let firstNameArray = nameArray["gd$givenName"] as? [String:Any] {
                                    contact.firstName  = (firstNameArray["$t"] as? String) ?? ""
                                }
                                if let lastNameArray  = nameArray["gd$familyName"] as? [String: Any] {
                                    contact.lastName   = (lastNameArray["$t"] as? String) ?? ""
                                }
                            }
                            
                            if let companyArray = tempContact["gd$organization"] as? [[String:Any]]{
                                let orgArray = companyArray[0]["gd$orgName"] as! [String:Any]
                                contact.companyName = (orgArray["$t"] as? String) ?? ""
                            }
                            
                            if let numberArray = tempContact["gd$phoneNumber"] as? [[String:Any]]{
                                contact.mobile = (numberArray[0]["$t"] as? String) ?? ""
                            }
                            
                            
                            if let emailArray = tempContact["gd$email"] as? [[String:Any]]{
                                contact.email = emailArray[0]["address"] as? String ?? ""
                            }
                            
                            if let imageArray = tempContact["link"] as? [[String:Any]] {
                                let imageURL = imageArray[0]["href"] as! String
                                
                                let urlWithAccessToken = "\(imageURL)&access_token=\(accessToken)"
                                let url = URL(string: urlWithAccessToken)
                                
                                let data = try? Data(contentsOf: url!)
                                if let imageData = data {
                                    contact.contactImage = UIImage(data: imageData)
                                }
                            }
                            
                            // If Any field is NULL the initialize with ""
                            self.ifContactValueNill(contact: contact)
                            
                            // save a single contact in ContactDatabase
                            if contact.firstName != "" {
                                ContactDataManager.sharedManager.add(contact: contact)
                                
                                // If iCloud is on Then save on Cloud
                                let isSync = AppSettings.shared.isSynchWithICloud
                                if isSync == true {
                                    SettingsVC.shareManager.saveToiCloud(contact: contact)
                                }
                            }
                        }
                    }
                    
                    // Save all details in Contact Database
                    DispatchQueue.main.async{
                        ContactDataManager.sharedManager.saveContactList()
                        
                        self.refreshContactTableList()
                        
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.signoutFromGoogle()
                    };
                }
                catch let err{
                    print("Error Messsage: \(err.localizedDescription)")
                }
            }
        }).resume()
    }
    
    
    // GoogleSignIn v9+ handles callbacks in the completion block of signIn.
    
    
    // MARK:- Alert or actionSheet function
    
    @objc private func showAddContactSuccessAlert() {
        
        let  alert = UIAlertController(title: "", message: "Successfully Saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion:  nil)
    }
    
    @objc func showImportActionSheet(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Import Google Contacts", style: .default, handler: { alert in
            self.signInWithGoogle()
        }))
        alert.addAction(UIAlertAction(title: "Import iPhone Contacts", style: .default, handler: { alert in
            self.importAppleContacts()
        }))
        alert.addAction(UIAlertAction(title: "Import iCloud Contacts", style: .default, handler: { alert in
            
            let status = AppSettings.shared.isSynchWithICloud
            if status == true {
                self.queryToFetchICloudDatabase()
            } else {
                self.syncSwitchAlert()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // On iPad, action sheets must be presented from a popover.
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc private func syncSwitchAlert() {
        
        let  alert = UIAlertController(title: "", message: "Please Sync On with iCLoud from the Settings", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion:  nil)
    }
    
    
    // MARK: - UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let contactKey = contactSectionTitles[section]
        if let contactValue = contactDictionary[contactKey] {
            return contactValue.count
        }
        return 1
    } 
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        
        // Configure the cell..
        
        let contactKey          =  contactSectionTitles[indexPath.section]
        if let contactValue     =   contactDictionary[contactKey] {
            cell.contact        =   contactValue[indexPath.row]
            
            // Use to show "me" label on my own contact
            if contactValue[indexPath.row].contactID == 800611764 {
                cell.meLabel.text = "me"
            } else {
                cell.meLabel.text = ""
            }
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // tableView.sectionIndexBackgroundColor = UIColor.blue
        //        tableView.sectionIndexTrackingBackgroundColor = UIColor.yellow
        //        tableView.sectionIndexColor = UIColor.red
        //    tableView.minimumZoomScale = CGFloat(integerLiteral: 100)
        //        tableView.sectionIndexMinimumDisplayRowCount = 10
        return contactSectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSectionTitles
    }
    
    
    
    //    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }
    
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            
    //            let contactKey = contactSectionTitles[indexPath.section]
    //            if let contactValue = contactDictionary[contactKey] {
    //                
    //                self.deleteFromiCloud(contact: contactValue[indexPath.row])
    //                ContactDataManager.sharedManager.delete(contact: contactValue[indexPath.row])
    //            }
    //            
    //            // DispatchQueue.main.async {
    //            
    //            self.contactListArray    =   ContactDataManager.sharedManager.getContactsList()
    //            self.populateContactSections()
    //            
    //            if let count = self.contactListArray?.count {
    //                self.contactCounts(count: count)
    //            }
    //            
    //            self.listTableView.beginUpdates()
    //            if contactSectionTitles.contains(contactKey) {
    //                tableView.deleteRows(at: [indexPath], with: .automatic)
    //                print("delete row")
    //            } else {
    //                
    //                let indexSet = IndexSet(integer: indexPath.section)
    //                // indexSet.add(indexPath.section - 1)
    //                tableView.deleteSections(indexSet, with: .automatic)
    //                print("delete section")
    //            }
    //            self.listTableView.endUpdates()
    //            
    //            self.listTableView.reloadData()
    //            // }
    //            
    //        }
    //    }
    
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  tableView.deselectRow(at: indexPath, animated: true)
        
        let contactKey = contactSectionTitles[indexPath.section]
        if let contactValue = contactDictionary[contactKey] {
            
            // this use to store the records before navigate to edit contact
            iCloudDataManager.sharedManager.queryToFetchICloudDatabase()
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                let vc = ContactDetailVC(contact: contactValue[indexPath.row])
                let naviCon = UINavigationController(rootViewController: vc)
                naviCon.modalPresentationStyle = .fullScreen
                naviCon.transitioningDelegate = self
                self.present(naviCon, animated: true, completion: nil)
            } else {
                let vc = ContactDetailVC(contact: contactValue[indexPath.row])
                vc.contactSavedClosure = { (contact) in
                    self.refreshContactTableList()
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                }
                vc.contactDeleteClosure = { (contact) in
                   
                    self.refreshContactTableList()
                    
                    if contactValue.indices.contains(indexPath.row + 1) {
                        
                        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                        self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: contactValue[indexPath.row + 1])), sender: self)
                    } else {
                        
                        if contactValue.count == 1 {
                            
                            let contactKey = self.contactSectionTitles[indexPath.section]
                            if let contactValue = self.contactDictionary[contactKey] {
                                
                                let customIndePath = IndexPath(item: 0, section: indexPath.section)
                                tableView.selectRow(at: customIndePath, animated: true, scrollPosition: .bottom)
                                
                                self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: contactValue[0])), sender: self)
                            }
                        } else {
                            let contactKey = self.contactSectionTitles[indexPath.section + 1]
                            if let contactValue = self.contactDictionary[contactKey] {
                                
                                let customIndePath = IndexPath(item: 0, section: indexPath.section + 1)
                                tableView.selectRow(at: customIndePath, animated: true, scrollPosition: .bottom)
                                self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: contactValue[0])), sender: self)
                            }
                        }
                    }
                }
                
                let naviCon = UINavigationController(rootViewController: vc)
                self.showDetailViewController(naviCon, sender: self)
            }
            
        } else {
            print("Error to display")
        }
        //  self.listTableView.reloadRows(at: [indexPath], with: .none)
    }
}


// MARK:- Custom Transition Delegate Method

extension ContactListVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
}

//extension ContactListVC: WCSessionDelegate {
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
////    // Only for watch OS
////     func updateAppContext() {
////        guard WCSession.isSupported() else {
////            return
////        }
////
////        do {
////            try WCSession.default.updateApplicationContext(["requestForiOS": "Hello world"])
////        } catch {
////            print("Error on application context:-- \(error.localizedDescription)")
////        }
////    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//
//        guard let response = message["request"] as? String else {
//            print("Response from Phone failed..")
//            replyHandler([:])
//            return
//        }
//
//        var contactListArray = ContactDataManager.sharedManager.getContactsList()
//        contactListArray = contactListArray.sorted(by: {$0.firstName! < $1.firstName!})
//
//        var contactArray = [String: [Any]]()
//
//        var nameArray = [String]()
//        var mobileArray = [String]()
//        var emailArray = [String]()
//        var imageArray = [Data]()
//        var favouriteArray = [Bool]()
//
//        for contact in contactListArray {
//
//            let name = "\(contact.firstName ?? "")  \(contact.lastName ?? "")"
//            nameArray.append(name)
//            mobileArray.append(contact.mobile ?? "")
//            emailArray.append(contact.email ?? "")
//            favouriteArray.append(contact.isFavorite!)
//
//
//            if let image: UIImage = contact.contactImage {
//
//                let compressedImage = ResizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
//
//                let imageData = compressedImage.jpegData(compressionQuality: 0.05)
//                imageArray.append((imageData as Data?)!)
//            }
//        }
//
//        contactArray["name"]   = nameArray
//        contactArray["mobile"] = mobileArray
//        contactArray["email"]  = emailArray
//        contactArray["image"]  = imageArray
//        contactArray["favourite"] = favouriteArray
//
//        switch response {
//        case "test":
//            replyHandler(contactArray)
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
