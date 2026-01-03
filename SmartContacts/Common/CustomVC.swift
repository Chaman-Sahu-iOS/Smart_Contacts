//
//  CustomVC.swift
//  SmartContacts
//
//  Created by chaman-8419 on 10/06/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class CustomVC: UIViewController {

    var viewController: UISplitViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setEmbeddedViewController(splitViewController: UISplitViewController!) {
        
        if splitViewController != nil {
            viewController = splitViewController
            self.addChild(viewController)
            self.view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
        self.setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.regular), forChild: viewController)
    }

}
