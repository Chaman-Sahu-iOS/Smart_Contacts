//
//  GroupDataManager.swift
//  SmartContacts
//
//  Created by chaman-8419 on 08/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

class GroupDataManager {
    
    static let sharedManager    =   GroupDataManager()
    
    var contacts: Contacts!
    
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
    
    func saveGroupList () {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                
                let nserror = error as NSError
                fatalError("Unresolved error.... \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK:- ADD New Group
    
    func addGroup(groupDict: [String: [Contact]], groupName: String) {
        
        let groupContactArray = groupDict[groupName]
        
        let groupData      = NSEntityDescription.insertNewObject(forEntityName: "Groups", into:   persistentContainer.viewContext) as! Groups
        groupData.name  = groupName
        
        if let groupContactArray = groupContactArray {
            
            for contact in groupContactArray {
                
                // Fetch all contact from the database
                let contactsDatabaseArray = fetchContacts()
                
                // Match Group contact to Database contact and Change the Contact Groups properties
                
                for data in contactsDatabaseArray {
                    if data.contactId == contact.contactID {
                        
                        data.groups        = groupData
                       // groupData.contacts.adding(data)
                        print("Group Saved")
                    }
                }
            }
        }
        
    }
    
    
    
    func getGroupsList() -> [String: [Contact]] {
        
        
        let groupsDatabaseArray = fetchGroups()
        var groupDictionary = [String: [Contact]]()

            for groups in groupsDatabaseArray {
                
                let groupName = groups.name!
                
                let contactsDatabaseArray = groups.contacts.allObjects as! [Contacts]
                
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
                groupDictionary[groupName] = contactArray
            }
        return groupDictionary
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
    
    
    func fetchGroups() -> [Groups] {
        
        let context = persistentContainer.viewContext
        var groupsDatabaseArray = [Groups]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Groups")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            groupsDatabaseArray = try context.fetch(fetchRequest) as! [Groups]
        } catch let error {
            print("can not get data: \(error.localizedDescription)")
        }
        
        return groupsDatabaseArray
    }
    
    
    func updateGroupName(groupName: String, newGroupName: String) {
        
        let groupsDatabaseArray = fetchGroups()
        
        for data in groupsDatabaseArray {
            if data.name == groupName {
                data.name = newGroupName
            }
        }
        
        saveGroupList()
    }
    
    // MARK:- Delete Method
    
    func deleteContactFromGroup(contact: Contact) {
        
        let contactsDatabaseArray = fetchContacts()
        
        for data in contactsDatabaseArray {
            if data.contactId == contact.contactID {
                
                data.groups        = nil
            }
        }
        saveGroupList()
    }
    
    func deleteGroups(groupName: String) {
        
        let context = persistentContainer.viewContext
        let groupsDatabaseArray = fetchGroups()
        var groupDictionary = getGroupsList()
        
        // Remove the groupe properties from the contact
        for contact in groupDictionary[groupName]! {
            
            let contactsDatabaseArray = fetchContacts()
            
            for data in contactsDatabaseArray {
                if data.contactId == contact.contactID {
                    data.groups        = nil
                }
            }
        }
        
        for data in groupsDatabaseArray {
            if data.name == groupName {
                context.delete(data)
            }
        }
        saveGroupList()
    }
    
    // Delete Whole Data From Database
    func deleteAllData() {
        
        let context = persistentContainer.viewContext
        
        var groupsDatabaseArray = fetchGroups()
        
        for data in groupsDatabaseArray {
            context.delete(data)
        }
        
        groupsDatabaseArray.removeAll()
        
        saveGroupList()
    }
    
    
}
