//
//  AppSettings.swift
//  SmartContacts
//
//  Created by chaman-8419 on 28/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import Foundation

class AppSettings:NSObject {
    
    // MARK:- Properties
    static let shared:AppSettings       =   AppSettings()
    
    public var isSynchWithICloud:Bool   =   false
    
    let defaults = UserDefaults.standard
    
    //MARK:- Initializer
    private override init() {
        super.init()
        isSynchWithICloud   = getiCloudStatus()
    }
    
    
    //MARK:- Sync Switch Methods
    public func saveiCloudStatus() {
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: isSynchWithICloud, requiringSecureCoding: false)
            defaults.set(data, forKey: "isSyncWithICloud")
        } catch {
            print("Couldn't save the status")
        }
        defaults.synchronize()
    }
    
    private func getiCloudStatus() -> Bool {
        
        if let data: Data = defaults.data(forKey: "isSyncWithICloud") {
            do {
                if let status = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Bool {
                    return status
                }
            } catch let error {
                print(error)
            }
        }
        return false
    }
}
