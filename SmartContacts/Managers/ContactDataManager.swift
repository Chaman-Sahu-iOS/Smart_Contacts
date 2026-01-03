//
//  DataManager.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 06/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

class ContactDataManager {
   
    static let sharedManager    =   ContactDataManager()
    
//    let publicDatabase  = CKContainer.default().publicCloudDatabase
//    var cloudRecords   = [CKRecord]()
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "SmartContacts")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContactList () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    // MARK:- Local Methods
    
    func isPresent(contactArray: [Contact], contact: Contact ) -> Bool {
        
        for data in contactArray {
            if data.firstName == contact.firstName && data.mobile == contact.mobile {
                return true
            }
        }
        return false
    }
    
    func add(contact:Contact) {
        
        let contactArray = getContactsList()
        
        if !isPresent(contactArray: contactArray, contact: contact) {
        
            
                let contactData      = NSEntityDescription.insertNewObject(forEntityName: "Contacts", into:   persistentContainer.viewContext) as! Contacts
                
                contactData.contactId = (contact.contactID!)
                contactData.firstName = contact.firstName
                contactData.lastName  = contact.lastName
                contactData.companyName = contact.companyName
                contactData.email       = contact.email
                contactData.mobile      = contact.mobile
                contactData.isFavorite  = contact.isFavorite!
                
                let image: UIImage = contact.contactImage!
                let imageData = image.jpegData(compressionQuality: 1.0)
                contactData.contactImage = imageData as NSData?
        }
    }
    
    
    func getContactsList() -> [Contact] {    
        
        let contactsDatabaseArray = fetchContacts()
        
        var contactArray = [Contact]()
        
        for data in contactsDatabaseArray {
            
            let contactData = Contact()
            
            contactData.contactID = data.contactId
            contactData.firstName = data.firstName
            contactData.lastName  = data.lastName
            contactData.companyName = data.companyName
            contactData.email       = data.email
            contactData.mobile      = data.mobile
            contactData.isFavorite  = data.isFavorite
            
            contactData.contactImage = UIImage(data: data.contactImage! as Data)
            
            contactArray.append(contactData)
        }
        
        return contactArray
    }
    

    func delete(contact:Contact!) {
        
        let context = persistentContainer.viewContext
        
        var contactsDatabaseArray = fetchContacts()
        
        for data in contactsDatabaseArray {
            if data.contactId == contact.contactID {
                context.delete(data)
            }
        }
        
        contactsDatabaseArray.removeAll { (sentContact) -> Bool in
                        sentContact.contactId == contact.contactID
                }
        
       // queryDatabase()
        //deleteFromiCloud(contact: contact)
        saveContactList()
    }
    
    func update(contact:Contact!) {
        
        let contactsDatabaseArray = fetchContacts()
        
        for data in contactsDatabaseArray {
            if data.contactId == contact.contactID {
                data.firstName     = contact.firstName
                data.lastName      = contact.lastName
                data.companyName   = contact.companyName
                data.email         = contact.email
                data.mobile        = contact.mobile
                data.isFavorite    = contact.isFavorite!
                
                let image: UIImage = contact.contactImage!
                let imageData = image.jpegData(compressionQuality: 0.2)
                data.contactImage = imageData as NSData?
            }
        }
        
        saveContactList()
    }

    func fetchContacts() -> [Contacts] {
        
        let context = persistentContainer.viewContext
        var contactsDatabaseArray = [Contacts]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Contacts")
        
        do {
            contactsDatabaseArray = try context.fetch(fetchRequest) as! [Contacts]
        } catch {
            print("can not get data")
        }
       
        return contactsDatabaseArray
    }
    
    
    func deleteAllData() {
        
        let context = persistentContainer.viewContext
        
        var contactsDatabaseArray = fetchContacts()
        
        for data in contactsDatabaseArray {
                context.delete(data)
        }
        
        contactsDatabaseArray.removeAll()
        
        saveContactList()
    }
    
    
    // MARK:- iCloud Data Manager
    
//    func saveCloudStatus(res: Bool) {
//
//        print("save cloud")
//
//        let context = persistentContainer.viewContext
//
//        let cloudDatabaseArray = fetchCloudStatus()
//
//        for data in cloudDatabaseArray {
//            context.delete(data)
//        }
//
//        let syncStatus      = NSEntityDescription.insertNewObject(forEntityName: "Cloud", into:   persistentContainer.viewContext) as! Cloud
//
//        syncStatus.isSync = res
//
//        saveContactList()
//    }
//
//    func fetchCloudStatus() -> [Cloud] {
//        let context = persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cloud")
//
//        var res = [Cloud]()
//
//        do {
//            res = try context.fetch(fetchRequest) as! [Cloud]
//        } catch {
//            print("can not get data")
//        }
//        return res
//    }
    
//    // Delete contact from iCloud
//    //1. fetch all records and save in cloudRecords array
//    
//    func queryDatabase() {
//        
//        let query = CKQuery(recordType: "Contacts", predicate: NSPredicate(value: true))
//        
//        publicDatabase.perform(query, inZoneWith: nil) { (records, error) in
//            
//            guard error == nil else {
//                // self.handle(error: error!)
//                print("Error to access contact from iCloud: \(String(describing: error?.localizedDescription))")
//                return
//            }
//            
//            guard let records = records else {
//                print("Record from iCloud are Nil...")
//                return
//            }
//            self.cloudRecords = records
//        }
//        
//        
//    }
//    
//    
//    // 2. With the help of recordID delete the Record From iCloud
//    func deleteFromiCloud(contact: Contact) {
//        
//        self.queryDatabase()
//        self.queryDatabase()
//        self.queryDatabase()
//        
//        var deleteObjectIds: CKRecord.ID?
//        
//        for data in cloudRecords {
//            
//            let id = data.value(forKey: "contactID") as? Int32
//            if id == contact.contactID {
//                deleteObjectIds = data.recordID
//                break
//            }
//        }
//        
//        // let recordID = cloudRecords[index].recordID
//        if let recordID = deleteObjectIds {
//            publicDatabase.delete(withRecordID: recordID) { (result, error) in
//                
//                guard error == nil else {
//                    // self.handle(error: error!)
//                    print("Error to Delete contact from iCloud: \(String(describing: error?.localizedDescription))")
//                    return
//                }
//                
//                print("Delete Contact sucessfully....")
//            }
//        }
//        
//    }
}
