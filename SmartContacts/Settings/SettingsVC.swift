//
//  SettingsVC.swift
//  SmartContacts
//
//  Created by chaman-pt2789 on 16/04/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import CloudKit
import MBProgressHUD

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Views
    
    lazy var settingTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
   lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let syncLabel: UILabel = {
        let label = UILabel()
        label.text = "Sync With iCloud"
        return label
    }()
    
    let syncSwitch = UISwitch()
 
    
    // MARK:- Data
    
    static let shareManager = SettingsVC()
    
    var publicDatabase = CKContainer.default().publicCloudDatabase
    var contactListArray = [Contact]()
    
    var sectionArray = [String]()
    var settingsTableData = [String]()
    
    
    // MARK:- View Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Settings"
        self.view.backgroundColor = UIColor.white
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeController))
        }
        
        sectionArray.append(" ")
        sectionArray.append(" ")
        
        settingsTableData.append("Clear Cache")
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
       
        // Remove all Seprator line under the table view
        settingTableView.tableFooterView = UIView()
        
        self.settingTableView.addSubview(containerView)
        
       
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Find in database is syncable or not if isSync is on then save in icloud otherwise not
        let isSync = AppSettings.shared.isSynchWithICloud
            if isSync == true {
                //uploadAllDataToiCloud()
                self.syncSwitch.setOn(true, animated: false)
            } else {
                self.syncSwitch.setOn(false, animated: false)
            }
    }
    
    override func viewDidLayoutSubviews() {
        settingTableView.frame = self.view.frame
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        containerView.frame = CGRect(x: 0, y: 0, width: settingTableView.frame.size.width, height: 70)
        
        containerView.addSubview(syncLabel)
        containerView.addSubview(syncSwitch)
        
        syncSwitch.translatesAutoresizingMaskIntoConstraints = false
        syncSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        syncSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10).isActive = true
        
        syncLabel.translatesAutoresizingMaskIntoConstraints = false
        syncLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        syncLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15).isActive = true
        
        syncSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
    }
    
    // MARK:- Local Methods
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        
        if sender.isOn {
            print("On")

            containerView.addSubview(syncLabel)
            containerView.addSubview(syncSwitch)
            AppSettings.shared.isSynchWithICloud    =   true
            AppSettings.shared.saveiCloudStatus()
            
            self.uploadAllDataToiCloud()
            
        } else {
            print("Off")
        
            AppSettings.shared.isSynchWithICloud = false
            AppSettings.shared.saveiCloudStatus()
            
            iCloudDeleteAlert()
        }
    }
    
    
    func uploadAllDataToiCloud() {
     
        contactListArray = ContactDataManager.sharedManager.getContactsList()
        
        if contactListArray.count > 0 {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            for contact in self.contactListArray {
                
                self.saveToiCloud(contact: contact)
            }
        }
    }
    
    func saveToiCloud(contact: Contact) {
        print("save in iCloud")
        
        let newRecord = CKRecord(recordType: "Contacts")
        newRecord.setValue(contact.firstName!, forKey: "firstName")
        newRecord.setValue(contact.lastName!, forKey: "lastName")
        newRecord.setValue(contact.mobile!, forKey: "mobile")
        newRecord.setValue(contact.companyName!, forKey: "companyName")
        newRecord.setValue(contact.email!, forKey: "email")
        newRecord.setValue(contact.contactID!, forKey: "contactID")
        
        //       the only way to save upload UIImage as a CKAsset is to:
        //
        //        1.Save the image temporarily to disk
        //        2.Create the CKAsset
        //        3.Delete the temporary file
        
        let image = contact.contactImage!
        let data = image.jpegData(compressionQuality: 0.2)// UIImage -> NSData, see also UIImageJPEGRepresentation
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        
        do {
            try data!.write(to: url!, options: [])
        } catch let e as NSError {
            print("Error! \(e)");
            return
        }
        newRecord["photo"] = CKAsset(fileURL: url!)
    
            self.publicDatabase.save(newRecord) { (records, error) in
                
                guard error == nil else {
                    self.handle(error: error!)
                    return
                }
                
                // Delete the temporary file
                do {
                    try FileManager.default.removeItem(at: url!)
                } catch let error {
                    print("Error deleting temp file: \(error)")
                }
                
                guard records != nil else { return }
                
                print("Record save successfully")
                
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
            }
    }
    
    
    func syncSwitchIsOn() {
        
        uploadAllDataToiCloud()
        AppSettings.shared.isSynchWithICloud    =   true
        AppSettings.shared.saveiCloudStatus()
        self.syncSwitch.setOn(true, animated: true)
    }
    
    func deleteWholeDatabase() {
        
        GroupDataManager.sharedManager.deleteAllData()
        ContactDataManager.sharedManager.deleteAllData()
        self.successfulAlert()
    }
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Aleart Methods
    
    func clearAlert() {
        
        let alert = UIAlertController(title: "", message: "Are you sure..?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { alert in
            return (self.deleteWholeDatabase())
        }))
        present(alert, animated: true, completion: nil)
    }


    func successfulAlert() {
        
        let alert = UIAlertController(title: "", message: "Suceesfully Cache Cleared..", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func iCloudDeleteAlert() {
        
        let alert = UIAlertController(title: "", message: "All contacts saved in iCloud will be erased, are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (result) in
            AppSettings.shared.isSynchWithICloud    =   true
            AppSettings.shared.saveiCloudStatus()
            self.syncSwitch.setOn(true, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (result) in
            
            iCloudDataManager.sharedManager.deleteAllRecordsFromiCloud()
            AppSettings.shared.isSynchWithICloud    =   false
            AppSettings.shared.saveiCloudStatus()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:- Error Handlings
    
    func handle(error: Error) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
        // self.refreshControl!.endRefreshing()
    }
    
    
    //MARK:- UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                cell.textLabel?.text = settingsTableData[indexPath.row]
            } else if indexPath.row == 1 {
                cell.contentView.addSubview(containerView)
            }
        } else {
            cell.textLabel?.text = "Version"
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
            cell.detailTextLabel?.text = appVersion
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    
    // should not highlighted when the cell tapped
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return false
        }
        
        if indexPath.section == 1{
            return false
        }
        return true
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            clearAlert()
        }
        
        self.settingTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
