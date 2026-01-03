//
//  iCloudDataManager.swift
//  SmartContacts
//
//  Created by chaman-8419 on 28/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import CloudKit

class iCloudDataManager {
    
    //MARK:- Properties
    static let sharedManager    =   iCloudDataManager()
    
    let publicDatabase  = CKContainer.default().publicCloudDatabase
    var cloudRecords   = [CKRecord]()
    
    
    //MARK:- Contacts iCloud Method
    
    func saveContactsToiCloud(contact: Contact) {
        print("save in iCloud")
        
        let newRecord = CKRecord(recordType: "Contacts")
        newRecord.setValue(contact.firstName!, forKey: "firstName")
        newRecord.setValue(contact.lastName!, forKey: "lastName")
        newRecord.setValue(contact.mobile!, forKey: "mobile")
        newRecord.setValue(contact.companyName!, forKey: "companyName")
        newRecord.setValue(contact.email!, forKey: "email")
        newRecord.setValue(contact.contactID!, forKey: "contactID")
        
        //        To save or upload UIImage as a CKAsset is to:
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
        
        DispatchQueue.main.async {
            self.publicDatabase.save(newRecord) { (records, error) in
                
                guard error == nil else {
                    // self.handle(error: error!)
                    print(error!)
                    return
                }
                
                // Delete the temporary file
                do {
                    try FileManager.default.removeItem(at: url!)
                } catch let error {
                    print("Error deleting temp file: \(error)")
                }
                
                guard records != nil else { return }
                
                // self.saveInAppleContactSuccessAlert()
                print("Record save successfully")
            }
        }
    }
    
    
    func updateContactsFromiCloud(contact:Contact) {
        
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        
        for updateRecord in cloudRecords {
            if  contact.contactID  == updateRecord.value(forKey: "contactID") as? Int32 {
                updateRecord.setValue(contact.firstName!, forKey: "firstName")
                updateRecord.setValue(contact.lastName!, forKey: "lastName")
                updateRecord.setValue(contact.mobile!, forKey: "mobile")
                updateRecord.setValue(contact.companyName!, forKey: "companyName")
                updateRecord.setValue(contact.email!, forKey: "email")
                updateRecord.setValue(contact.contactID!, forKey: "contactID")
                
                //        To save or upload UIImage as a CKAsset is to:
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
                updateRecord["photo"] = CKAsset(fileURL: url!)
                
                
                DispatchQueue.main.async {
                    self.publicDatabase.save(updateRecord) { (records, error) in
                        
                        guard error == nil else {
                            // self.handle(error: error!)
                            print(error!)
                            return
                        }
                        
                        // Delete the temporary file
                        do {
                            try FileManager.default.removeItem(at: url!)
                        } catch let error {
                            print("Error deleting temp file: \(error)")
                        }
                        
                        guard records != nil else { return }
                        
                        // self.saveInAppleContactSuccessAlert()
                        print("Record updateed successfully..")
                    }
                }
            }
        }
    }
    
    // Query for fetching all data form iCloud and store in cloudRecords
    
    func queryToFetchICloudDatabase() {
        
        let query = CKQuery(recordType: "Contacts", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            guard error == nil else {
                // self.handle(error: error!)
                print("Error to access contact from iCloud: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let records = records else {
                print("Record from iCloud are Nil...")
                return
            }
            self.cloudRecords = records
        }
    }
    
    // MARK:- Delete contact from iCloud
    //1. fetch all records and save in cloudRecords array
    // 2. With the help of recordID delete the Record From iCloud
    func deleteFromiCloud(contact: Contact) {
        
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        
        var deleteObjectIds: CKRecord.ID?
        
        for data in cloudRecords {
            
            let id = data.value(forKey: "contactID") as? Int32
            if id == contact.contactID {
                deleteObjectIds = data.recordID
                break
            }
        }
        
        // let recordID = cloudRecords[index].recordID
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
    
    
    func deleteAllRecordsFromiCloud() {
        
        let query = CKQuery(recordType: "Contacts", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            if error == nil {
                
                for record in records! {
                    
                    self.publicDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                        
                        if error == nil {
                            
                            print(" contacts record deleted...")
                        }
                    })
                }
            }
        }
        
        let queryGroups = CKQuery(recordType: "Groups", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(queryGroups, inZoneWith: nil) { (records, error) in
            
            if error == nil {
                
                for record in records! {
                    
                    self.publicDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                        
                        if error == nil {
                            
                            print("groups record deleted...")
                        }
                    })
                }
            }
        }
    }
    
    
    //MARK:- Group Data Manager
    
    func addGroupOniCloud(groupDict: [String: [Contact]], groupName: String) {
        
        let groupRecords = CKRecord(recordType: "Groups")
        groupRecords["groupName"] = groupName as CKRecordValue
        
        let groupContactArray     = groupDict[groupName]
        
        publicDatabase.save(groupRecords) { (records, error) in
            
            if error != nil {
                print("Error saving groups in iCloud: \(String(describing: error?.localizedDescription))")
                return
            } else {
                print("group save in iCloud")
            }
        }
        
        queryToFetchICloudDatabase()
        
        for contact in groupContactArray! {
            
            // Fetch all contact from the database
            let contactsDatabaseArray = cloudRecords
            
            // Match Group contact to Database contact and Change the Contact Groups properties
            
            for data in contactsDatabaseArray {
                
                let key = data.value(forKey: "contactID") as? Int32
                
                if key == contact.contactID {
                    
                    let reference = CKRecord.Reference(record: groupRecords, action: .none)
                    data.setObject(reference, forKey: "owningGroups")
                    
                    // Saving data on iCloud
                    
                    publicDatabase.save(data) { (records, error) in
                        DispatchQueue.main.async {
                            if error == nil {
                                // Add in table Array and Reload
                                print("Contacts groups Updated")
                            } else {
                                
                                print("Error saving contact in groups: \(String(describing: error?.localizedDescription))")
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func deleteContactFromGroupOniCloud(contact: Contact) {
        
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        self.queryToFetchICloudDatabase()
        
        // Fetch all contact from the database
        let contactsDatabaseArray = cloudRecords
        
        // Match Group contact to Database contact and Change the Contact Groups properties
        for data in contactsDatabaseArray {
            
            let key = data.value(forKey: "contactID") as? Int32
            
            if key == contact.contactID {
                
                //let reference = CKRecord.Reference(record: groupRecords, action: .none)
                data.setObject(nil, forKey: "owningGroups")
                
                // Saving data on iCloud
                
                publicDatabase.save(data) { (records, error) in
                    DispatchQueue.main.async {
                        if error == nil {
                            // Add in table Array and Reload
                            print("Contacts Delete from groups on cloud")
                        } else {
                            
                            print("Error deleting contact in groups on cloud: \(String(describing: error?.localizedDescription))")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func deleteGroup(groupName: String) {
        
        let predeicate = NSPredicate(format: "groupName == %@", groupName)
        let query = CKQuery(recordType: "Groups", predicate: predeicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            if error == nil {
                
                if let records = records {
                    for record in records {
                        
                        self.publicDatabase.delete(withRecordID: record.recordID, completionHandler: { (recordID, error) in
                            
                            if error == nil {
                                
                                print("Group deleted on cloud...")
                            } else {
                                print("Error to deleting groupn on cloud \(String(describing: error?.localizedDescription))")
                            }
                        })
                    }
                }
                
            } else {
                print("Error to fetch group on cloud \(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    
    func deleteGroupFromiCloud(groupName: String) {
        
        //var groupArray = [String:[Contact]]()
        let predeicate = NSPredicate(format: "groupName == %@", groupName)
        let query = CKQuery(recordType: "Groups", predicate: predeicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
            
            DispatchQueue.main.async {
                if error != nil {
                    // self.handle(error: error!)
                    print(error?.localizedDescription as Any)
                } else {
                    
                    if let records = records {
                        
                        for record in records{
                            let reference = CKRecord.Reference(record: record, action: .none)
                            let pred      = NSPredicate(format: "owningGroups == %@", reference)
                            let query     = CKQuery(recordType: "Contacts", predicate: pred)
                            
                            self.publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
                                
                                if let error = error {
                                    // self.handle(error: error)
                                    print(error.localizedDescription)
                                } else {
                                    if let results = results {
                                        for data in results {
                                            let contact = Contact()
                                            contact.firstName    = data.value(forKey: "firstName") as? String
                                            
                                            contact.contactID    = data.value(forKey: "contactID") as? Int32
                                            self.deleteContactFromGroupOniCloud(contact: contact)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        deleteGroup(groupName: groupName)
    }
}
