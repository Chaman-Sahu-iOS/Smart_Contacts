//
//  SearchTableViewController.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 15/03/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class ContactSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UISearchResultsUpdating, UISearchDisplayDelegate, UISplitViewControllerDelegate{
    
    // MARK:- Properties
    
    lazy var searchTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.rowHeight =   70
        return tempTableView
    }();
    
    let transition = CustomTransition()
    
    // Used for tableData
    var contactListArray:[Contact]?
    var filterTableData: [Contact]  =   [Contact]()
    
    var searchTextString:String?
    var searchClouser: ((Contact, Int) -> Void)?
    
    // MARK:- View Life Cycle Funtions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Constraints of Search Table
        searchTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(searchTableView)
        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            searchTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            searchTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            searchTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        // Register the search table view
        searchTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK:- Local Methods
    
    func highlightedText(searchString: String, baseString: String ) -> NSAttributedString? {
        
        let attributed = NSMutableAttributedString(string: baseString)
        
        do {
            let regex = try NSRegularExpression(pattern: searchString, options:   NSRegularExpression.Options.caseInsensitive)
            
            for match in regex.matches(in: baseString, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSRange(location: 0, length: baseString.utf16.count)) {
                attributed.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: match.range)
            }
            
        } catch let err {
            print(err)
        }
        
        return attributed
    }
    
    
    func ifMobileMatched(text: String) -> Bool {
        
        let num = Int(text)
        if num != nil {
            return true
        }
        return false
    }
    
    
    func ifMailMatched(text: String, textRange: String) -> Bool {
        
        if textRange.contains(text) {
            return true
        }
        return false
    }
    
    
    @objc func closeController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- UISearchBarDelegate
    
    func updateSearchResults(for searchController: UISearchController) {
        // Fetch The data from The Contact Database
        self.contactListArray = ContactDataManager.sharedManager.getContactsList()
        contactListArray = contactListArray?.sorted(by: {$0.firstName! < $1.firstName!})
       
        if searchController.isActive {
            searchController.searchBar.isHidden = false
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            
            searchTextString = searchText
            filterTableData = (contactListArray?.filter { team in
                return team.firstName!.lowercased().contains(searchText.lowercased()) || team.lastName!.lowercased().contains(searchText.lowercased()) || team.mobile!.lowercased().contains(searchText.lowercased()) || team.email!.lowercased().contains(searchText.lowercased())
                })!
        }
        else {
            filterTableData = contactListArray!
        }
        
        // "No Results" display when search string does not with database
        if (filterTableData.count == 0) {
            
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.searchTableView.bounds.size.width, height: self.searchTableView.bounds.size.height))
            noDataLabel.text = "No Results"
            noDataLabel.font = UIFont.systemFont(ofSize: 25)
            noDataLabel.textColor = UIColor.gray
            noDataLabel.textAlignment = .center
            self.searchTableView.backgroundView = noDataLabel
            self.searchTableView.backgroundColor = UIColor.white
            self.searchTableView.separatorStyle = .none
            
        } else {
            
            self.searchTableView.separatorStyle = .singleLine
            self.searchTableView.backgroundView = nil
        }
        
        self.searchTableView.tableFooterView = UIView()
        self.searchTableView.reloadData()
    }
    
  
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        
        //  Configure the cell...
        
        let baseString = filterTableData[indexPath.row].firstName! + " " + filterTableData[indexPath.row].lastName!
        let phoneString = filterTableData[indexPath.row].mobile
        let emailString = filterTableData[indexPath.row].email
        
        if let searchText = self.searchTextString {
            
            if  ifMobileMatched(text: searchText) {
                
                cell.searchNameLabel.attributedText = highlightedText(searchString: searchText, baseString: baseString)
                cell.phoneLabel.attributedText = highlightedText(searchString: searchText, baseString: phoneString!)
                cell.nameLabel.attributedText = nil
                cell.emailLabel.attributedText = nil
                
            } else if ifMailMatched(text: searchText.lowercased(), textRange: emailString!.lowercased()) {

                cell.searchNameLabel.attributedText = highlightedText(searchString: searchText, baseString: baseString)
                cell.emailLabel.attributedText = highlightedText(searchString: searchText, baseString: emailString!)
                cell.nameLabel.attributedText = nil
                cell.phoneLabel.attributedText      = nil
            } else {
                
                cell.nameLabel.attributedText = highlightedText(searchString: searchText, baseString: baseString)
                cell.searchNameLabel.attributedText = nil
                cell.phoneLabel.attributedText      = nil
                cell.emailLabel.attributedText      = nil
            }
             cell.contactImage.image = filterTableData[indexPath.row].contactImage
        }
        
        return cell
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
            let vc = ContactDetailVC(contact: filterTableData[indexPath.row])
            let naviCon = UINavigationController(rootViewController: vc)
            naviCon.modalPresentationStyle = .fullScreen
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
            
        } else {
              // GO back to Contact List and showDetails appear for the Search Contact
              searchClouser?(filterTableData[indexPath.row], indexPath.row)
        }
        
       // tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: Custom Transition Delegate Method

extension ContactSearchVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
}
