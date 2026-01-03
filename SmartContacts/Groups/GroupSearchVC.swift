//
//  GroupSearchVC.swift
//  SmartContacts
//
//  Created by chaman-8419 on 08/05/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit

class GroupSearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,UISearchResultsUpdating, UISearchDisplayDelegate  {

    // MARK:- Properties
    
    lazy var groupTableView:UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.delegate = self
        tempTableView.dataSource = self
        tempTableView.rowHeight =   70
        return tempTableView
    }();
    
    let transition = CustomTransition()
    
    // Used for tableData
    var groupListArray  = [String]()
    var groupData       =    [String:[Contact]]()
    var filterTableData =   [String]()
    
    var searchString: String?
    
    //Only for iPad
    var searchClouser: (([Contact], String) -> Void)?
    
    // MARK:- View Life Cycle Funtions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Constraints of Search Table
        groupTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(groupTableView)
        NSLayoutConstraint.activate([
            groupTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            groupTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            groupTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            groupTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
        // Remove the gap between search result and search bar
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 20)
        self.groupTableView.contentInsetAdjustmentBehavior = .never
        
        // Register the search table view
        groupTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Fetch The data from The Contact Database
        fetchData()
    }
    
    func fetchData() {
        groupData = GroupDataManager.sharedManager.getGroupsList()
        groupListArray.removeAll()
        
        for (key, _) in groupData {
            let groupName = key
            self.groupListArray.append(groupName)
        }
        
        groupListArray = groupListArray.sorted(by: {$0 < $1})
        self.groupTableView.reloadData()
    }
    
    // MARK:- UISearchBarDelegate
    
    func updateSearchResults(for searchController: UISearchController) {
        
        fetchData()
        
        if searchController.isActive {
            searchController.searchBar.isHidden = false
        }
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            
            searchString = searchText
            filterTableData = (groupListArray.filter { team in
                return team.lowercased().contains(searchText.lowercased())
                
            })
        }
        else {
            filterTableData = groupListArray
        }
        if (filterTableData.count == 0) {
            
            // "No Results" display when search string does not with database
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.groupTableView.bounds.size.width, height: self.groupTableView.bounds.size.height))
            noDataLabel.text = "No Results"
            noDataLabel.font = UIFont.systemFont(ofSize: 25)
            noDataLabel.textColor = UIColor.gray
            noDataLabel.textAlignment = .center
            self.groupTableView.backgroundView = noDataLabel
            self.groupTableView.backgroundColor = UIColor.white
            self.groupTableView.separatorStyle = .none
            
        } else {
            
            self.groupTableView.separatorStyle = .singleLine
            self.groupTableView.backgroundView = nil
        }
        
        self.groupTableView.reloadData()
    }
    
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
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTableData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //  Configure the cell...
        
        let baseString = filterTableData[indexPath.row]
        
        if let searchText = searchString {
            cell.textLabel?.attributedText = highlightedText(searchString: searchText, baseString: baseString)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let groupName = filterTableData[indexPath.row]
        
        print(groupName)
        
        let groupDetailVC = GroupDetailsVC()
        groupDetailVC.contactArray = groupData[groupName]
        groupDetailVC.title        = groupName
        
        let naviCon = UINavigationController(rootViewController: groupDetailVC)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            naviCon.transitioningDelegate = self
            self.present(naviCon, animated: true, completion: nil)
        } else {
            
            searchClouser?(groupData[groupName]!, groupName)
        }
        
        
    }
}

extension GroupSearchVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
}

