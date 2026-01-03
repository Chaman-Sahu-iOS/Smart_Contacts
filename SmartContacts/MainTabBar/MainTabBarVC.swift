//
//  MainTabBarVC.swift
//  SmartContacts
//
//  Created by chaman-pt2789 on 16/04/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = UIColor.white
        setUpTabBar()
    }
    
    
    func setUpTabBar() {
        
        let contactController = UINavigationController(rootViewController: ContactListVC())
        contactController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        
        let favoriteController = UINavigationController(rootViewController: FavoriteVC())
        favoriteController.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let groupController = UINavigationController(rootViewController: GroupVC())
        groupController.tabBarItem = UITabBarItem(title: "Groups", image: UIImage(named: "group_filled"), selectedImage: UIImage(named: "group_filled"))
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let settingController = UINavigationController(rootViewController: SettingsVC())
            settingController.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings_filled"), selectedImage: UIImage(named: "settings_filled"))
            
              viewControllers = [contactController, favoriteController, groupController, settingController]
        } else {
             viewControllers = [contactController, favoriteController, groupController]
        }
        
      
    }

}
