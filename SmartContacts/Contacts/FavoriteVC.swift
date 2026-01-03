//
//  FavoriteVC.swift
//  SmartContacts
//
//  Created by chaman-pt2789 on 16/04/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class FavoriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Views
    lazy var favoriteTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
//        tempTableView.frame = self.view.frame
//        tempTableView.delegate = self
//        tempTableView.dataSource = self
        tempTableView.rowHeight =   70
        self.view.addSubview(tempTableView)
        return tempTableView
    }();
    
    //MARK:- Data
     var contactListArray:[Contact]?
     var favoriteTableData: [Contact]  =   [Contact]()
    
     let transition = CustomTransition()

    //MARK:- View Life Cycle Funcations
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Favourites"
        self.navigationItem.title = "Favourites"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.view.backgroundColor = .white
        
         favoriteTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {

        favoriteTableData.removeAll()
        contactListArray = ContactDataManager.sharedManager.getContactsList()
        filterFavoriteContacts()
        
        // Select the default favorite contact when view will appear
        if favoriteTableData.indices.contains(0) {
            let defaultContact = favoriteTableData[0]
            let contactDetailVC = ContactDetailVC(contact: defaultContact)
            contactDetailVC.contactSavedClosure = { (contact) in
                
                self.favoriteTableData.removeAll()
                self.contactListArray = ContactDataManager.sharedManager.getContactsList()
                self.filterFavoriteContacts()
                self.favoriteTableView.reloadData()
                
                let indexPath  = IndexPath(row: 0, section: 0)
                self.favoriteTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
            contactDetailVC.contactDeleteClosure = { (contact) in
                
                if self.favoriteTableData.indices.contains(0 + 1) {
                    
                    self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: self.favoriteTableData[0 + 1])), sender: self)
                }
                
                // After Delete contact and next contact appear on detail view, Update the table with viewWillAppear
                self.viewWillAppear(true)
                let indexPath = IndexPath(item: 0, section: 0)
                self.favoriteTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
            contactDetailVC.favoriteClouser = { (isFavorite) in
                if self.favoriteTableData.indices.contains(0 + 1) {
                    
                    self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: self.favoriteTableData[0 + 1])), sender: self)
                }
                
                // After Delete contact and next contact appear on detail view, Update the table with viewWillAppear
                self.viewWillAppear(true)
                
                if self.favoriteTableData.indices.contains(0) {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.favoriteTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                }
            }
            
            showDetailViewController(UINavigationController(rootViewController: contactDetailVC), sender: self)
        } else {
            
            let contactDetailVC = UIViewController()
            contactDetailVC.view.backgroundColor = UIColor.white
            showDetailViewController(UINavigationController(rootViewController: contactDetailVC), sender: self)
        }
        
        self.favoriteTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        if UIDevice.current.userInterfaceIdiom == .pad {
            if favoriteTableData.indices.contains(0) {
                let indexPath = IndexPath(row: 0, section: 0)
                favoriteTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        favoriteTableView.frame = self.view.frame
        favoriteTableView.delegate = self
        favoriteTableView.dataSource = self
    }
    
    //MARK:- Local Methods
    
    func filterFavoriteContacts() {
        
        for contact in contactListArray! {
            
            if contact.isFavorite! {
                favoriteTableData.append(contact)
            }
        }
        
        favoriteTableData = favoriteTableData.sorted(by: { $0.firstName! < $1.firstName! })
    }
    
    // MARK-: UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        
        cell.contact = favoriteTableData[indexPath.row]
        return cell
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            
//            favoriteTableData[indexPath.row].isFavorite = false
//            ContactDataManager.sharedManager.update(contact: favoriteTableData[indexPath.row])
//            favoriteTableData.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
//    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // tableView.deselectRow(at: indexPath, animated: true)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let vc = ContactDetailVC(contact: favoriteTableData[indexPath.row])
            let naviCon = UINavigationController(rootViewController: vc)
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
        } else {
            
            let vc = ContactDetailVC(contact: favoriteTableData[indexPath.row])
            vc.contactSavedClosure = { (contact) in
                
                self.favoriteTableData.removeAll()
                self.contactListArray = ContactDataManager.sharedManager.getContactsList()
                self.filterFavoriteContacts()
                self.favoriteTableView.reloadData()
                
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
            vc.contactDeleteClosure = { (contact) in
                
                self.viewWillAppear(true)
                
                if self.favoriteTableData.indices.contains(indexPath.row) {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: self.favoriteTableData[indexPath.row])), sender: self)
                }
            }
            vc.favoriteClouser = { (isFavorite) in
                
                self.viewWillAppear(true)
                
                if self.favoriteTableData.indices.contains(indexPath.row) {
                    
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                    self.showDetailViewController(UINavigationController(rootViewController: ContactDetailVC(contact: self.favoriteTableData[indexPath.row])), sender: self)
                }
            }
            
            let naviCon = UINavigationController(rootViewController: vc)
            self.showDetailViewController(naviCon, sender: self)
        }
        
     //   self.favoriteTableView.reloadRows(at: [indexPath], with: .none)
    }

}

extension FavoriteVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
    
}
