//
//  Contacts+CoreDataProperties.swift
//  SmartContacts
//
//  Created by chaman-8419 on 08/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var companyName: String?
    @NSManaged public var contactId: Int32
    @NSManaged public var contactImage: NSData?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastName: String?
    @NSManaged public var mobile: String?
    @NSManaged public var groups: Groups? 
}
