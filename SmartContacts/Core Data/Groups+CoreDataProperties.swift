//
//  Groups+CoreDataProperties.swift
//  SmartContacts
//
//  Created by chaman-8419 on 08/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//
//

import Foundation
import CoreData


extension Groups {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Groups> {
        return NSFetchRequest<Groups>(entityName: "Groups")
    }

    @NSManaged public var name: String?
    @NSManaged public var contacts: NSSet

}

// MARK: Generated accessors for contacts
extension Groups {

    @objc(addContactsObject:)
    @NSManaged public func addToContacts(_ value: Contacts)

    @objc(removeContactsObject:)
    @NSManaged public func removeFromContacts(_ value: Contacts)

    @objc(addContacts:)
    @NSManaged public func addToContacts(_ values: NSSet)

    @objc(removeContacts:)
    @NSManaged public func removeFromContacts(_ values: NSSet)

}
