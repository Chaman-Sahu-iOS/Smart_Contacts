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

                if let image = contact.contactImage {
                    contactData.contactImage = image.jpegData(compressionQuality: 0.5) as NSData?
                }
        }
    }

    /// Batch-inserts many contacts in a single background transaction.
    /// Avoids the O(N²) duplicate-check + UIImage-decode blow-up that crashes
    /// the app when importing hundreds of Google contacts at once.
    func addContactsBatch(_ contacts: [Contact], completion: @escaping () -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.undoManager = nil

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Contacts")
            fetchRequest.propertiesToFetch = ["firstName", "mobile"]
            fetchRequest.resultType = .dictionaryResultType

            var seen = Set<String>()
            if let rows = try? context.fetch(fetchRequest) as? [[String: Any]] {
                for row in rows {
                    let fn = row["firstName"] as? String ?? ""
                    let mb = row["mobile"] as? String ?? ""
                    seen.insert("\(fn)|\(mb)")
                }
            }

            let chunkSize = 50
            var sinceLastSave = 0

            for contact in contacts {
                autoreleasepool {
                    let fn = contact.firstName ?? ""
                    let mb = contact.mobile ?? ""
                    let key = "\(fn)|\(mb)"
                    if seen.contains(key) { return }
                    seen.insert(key)

                    let entity = NSEntityDescription.insertNewObject(forEntityName: "Contacts", into: context) as! Contacts
                    entity.contactId = contact.contactID ?? Int32.random(in: 0...Int32.max)
                    entity.firstName = contact.firstName
                    entity.lastName = contact.lastName
                    entity.companyName = contact.companyName
                    entity.email = contact.email
                    entity.mobile = contact.mobile
                    entity.isFavorite = contact.isFavorite ?? false

                    if let data = contact.contactImageData {
                        entity.contactImage = data as NSData
                    } else if let image = contact.contactImage {
                        entity.contactImage = image.jpegData(compressionQuality: 0.5) as NSData?
                    }
                    // Release any references the caller held to help ARC free them.
                    contact.contactImageData = nil
                    contact.contactImage = nil

                    sinceLastSave += 1
                }

                if sinceLastSave >= chunkSize {
                    do {
                        try context.save()
                        context.reset()
                        // Re-seed `seen` is not needed: we already track in-memory.
                    } catch {
                        print("Batch save error (chunk): \(error)")
                    }
                    sinceLastSave = 0
                }
            }

            do {
                if context.hasChanges { try context.save() }
            } catch {
                print("Batch save error (final): \(error)")
            }

            DispatchQueue.main.async { completion() }
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
