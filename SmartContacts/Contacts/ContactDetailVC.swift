//
//  RaagDetailViewController.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 25/02/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import MapKit
import CoreLocation
import MobileCoreServices
import CloudKit



class ContactDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate {
    
    // MARK:- Views
    
    let profileImage: UIImageView =  {
        let image = UIImageView()
        image.layer.cornerRadius = 40
        image.clipsToBounds = true
        return image
    }()
    
    var profileImageButton:UIButton = {
        let button                        =   UIButton()
        button.layer.cornerRadius         =   40
        button.clipsToBounds              =   true
       // button.imageView?.alpha         =   0.5
        button.imageView?.contentMode     =   .scaleAspectFill
        return button
    }();
    
    var contactName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }()
    
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment    = .center
        stack.spacing      = 20.0
        stack.backgroundColor = .clear
        return stack
    }()
    

    let contactNumberButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        if #available(iOS 13.0, *) {
            button.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.6)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
        return button
    }()
    
    
    let contactMailButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
        if #available(iOS 13.0, *) {
            button.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.6)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
        return button
    }()
    
    let contactMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)
        if #available(iOS 13.0, *) {
            button.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.6)
        } else {
            button.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }
        return button
    }()
    
    
    let detailTableView: UITableView = {
        let tempTableView: UITableView = UITableView()
        tempTableView.rowHeight =   70
        return tempTableView
    }();
    
    // MARK:- Data
    
    let privateDatabase = CKContainer.default().privateCloudDatabase
    let publicDatabase  = CKContainer.default().publicCloudDatabase
    
    // Used in tableData
    var contact: Contact?
    var contactArray = [String:[String]]()
    var contactTitle = [String]()
    var sectionArray = [String]()
    
    var contactSavedClosure: ((Contact) -> Void)?
    var contactDeleteClosure: ((Contact) -> Void)?
    var favoriteClouser: ((Bool) -> Void)?
    
    let iphoneContact = CNMutableContact()
    
    let manager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    
    var qrImageView = UIImageView()
    
    // MARK:- Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(contact: Contact){
        self.contact = contact
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK:- View Life Cycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editContact))
        self.navigationController?.navigationBar.barTintColor      =  UIColor.white
        self.navigationController?.navigationBar.isTranslucent     =  true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
       if UIDevice.current.userInterfaceIdiom == .phone {
           let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(closeController))
           self.navigationItem.leftBarButtonItem =  backButton
        }
        
        // When Contact list appear then default Contact Detail Value
        var contactListArray = ContactDataManager.sharedManager.getContactsList()
        contactListArray = contactListArray.sorted(by: {$0.firstName! < $1.firstName!})
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            if contact == nil {
                if !contactListArray.isEmpty {
                    contact = contactListArray[0]
                } else {
                    return
                }
            }
        }
        
        
        // Table
        self.view.addSubview(detailTableView)
        detailTableView.dataSource = self
        detailTableView.delegate   = self
        
        detailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        detailTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        detailTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive  = true
        detailTableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        detailTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
         contactTableData()
        
        // For location
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func contactTableData() {
        // Contact Details parts
        
        var contactDetail = [String]()
        contactDetail.append(contact!.mobile!)
        contactDetail.append(contact!.email!)
        contactDetail.append(contact!.companyName!)
        
        contactArray["Details"] = contactDetail
        
        // Contact Detail Title
        contactTitle.append("Phone")
        contactTitle.append("Mail")
        contactTitle.append("Company Name")
        
        // Some action in Contact Detail Cell
        var actionArray = [String]()
        actionArray.append("Add to iPhone Contact")
        actionArray.append("Add to iCloud")
        actionArray.append("Share Contact")
        if contact!.isFavorite! {
            actionArray.append("Remove from Favourites")
        } else {
            actionArray.append("Add to Favourites")
        }
        actionArray.append("Share Location")
        actionArray.append("Generate QR Code")
        
        contactArray["Action"] = actionArray
        
        // Empty Section in Details Table
        sectionArray.append("  ")
        sectionArray.append("  ")
        
        // Register the Detail Table
        self.detailTableView.register(DetailTableViewCell.self, forCellReuseIdentifier: "detail")
        
        // Set Target For all the button
        contactNumberButton.addTarget(self, action: #selector(mobileList), for: .touchUpInside)
        contactMailButton.addTarget(self, action: #selector(mailList), for: .touchUpInside)
        contactMessageButton.addTarget(self, action: #selector(messageList), for: .touchUpInside)
        
        // Show the contact profile image, Number, Mail, Message Button
        headerViewDetails()
    }
   
    
    // MARK:- Local Functions
    
    func headerViewDetails() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: detailTableView.frame.size.width, height: 230))
        
        // Add Contact Image in Header View
        
        profileImageButton.setImage(contact!.contactImage!, for: .normal)
        profileImageButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
        headerView.addSubview(profileImageButton)
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            profileImageButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageButton.heightAnchor.constraint(equalToConstant: 80),
            profileImageButton.widthAnchor.constraint(equalToConstant: 80)
            ])
        
        
        // Add Contact Name in Header View
        
        contactName.text = contact!.firstName! + " " + contact!.lastName!
        headerView.addSubview(contactName)
        contactName.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contactName.topAnchor.constraint(equalTo: self.profileImageButton.bottomAnchor, constant: 20),
            contactName.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
            ])
        
        
        // Add Contact Stack Button in Header View
        
        stackView.addArrangedSubview(contactNumberButton)
        stackView.addArrangedSubview(contactMailButton)
        stackView.addArrangedSubview(contactMessageButton)

        // Ensure larger, consistent sizes for action buttons
        let buttonSize: CGFloat = 60
        contactNumberButton.translatesAutoresizingMaskIntoConstraints = false
        contactMailButton.translatesAutoresizingMaskIntoConstraints = false
        contactMessageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contactNumberButton.widthAnchor.constraint(equalToConstant: buttonSize),
            contactNumberButton.heightAnchor.constraint(equalToConstant: buttonSize),
            contactMailButton.widthAnchor.constraint(equalToConstant: buttonSize),
            contactMailButton.heightAnchor.constraint(equalToConstant: buttonSize),
            contactMessageButton.widthAnchor.constraint(equalToConstant: buttonSize),
            contactMessageButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])

        // Rounded "pill"/circular style like Phone app
        contactNumberButton.layer.cornerRadius = buttonSize/2
        contactNumberButton.layer.masksToBounds = true
        contactMailButton.layer.cornerRadius = buttonSize/2
        contactMailButton.layer.masksToBounds = true
        contactMessageButton.layer.cornerRadius = buttonSize/2
        contactMessageButton.layer.masksToBounds = true
        
        
        // Highlight Button if needed
        if contact?.mobile == "" {
            contactNumberButton.isEnabled   = false
            contactMessageButton.isEnabled  = false
//            contactNumberButton.imageView?.tintColor = UIColor.lightGray
//            contactMessageButton.imageView?.tintColor = UIColor.lightGray
            
        } else {
            contactNumberButton.isEnabled   = true
            contactMessageButton.isEnabled  = true
           // contactNumberButton.imageView?.image = UIImage(named: "call_icon")
           // contactMessageButton.imageView?.image = UIImage(named: "msg_icon")
        }
        
        
        if contact?.email == "" {
            contactMailButton.isEnabled = false
           // contactMailButton.imageView?.tintColor = UIColor.lightGray
        } else {
            contactMailButton.isEnabled = true
          //  contactMailButton.imageView?.image = UIImage(named: "mail_icon")
        }
        
        
        headerView.addSubview(stackView)
        
        // Set Constraints of Stack View
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.contactName.bottomAnchor, constant: 20),
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
            ])
        
        
        // Add Header View on the Top of Detail Table Header
        self.detailTableView.tableHeaderView = headerView
        
        // Remove seprator line below the table view
        self.detailTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100))
    }
    
    
    @objc func profileImageTapped() {
        
        // Profile Image in New View with full screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            let newImageView = UIImageView(image: contact!.contactImage!)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        } else {
            
            let vc = ContactProfileImage()
            vc.contact = contact
            vc.modalPresentationStyle = .formSheet
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc func editContact() {
        
        let vc = AddContactVC(contact: contact)
        vc.contactSavedClosure = {  (updatedContact) in
            
            self.contactSavedClosure?(updatedContact) 
            self.contact = updatedContact
            self.contactTableData()
            self.detailTableView.reloadData()
        }
        vc.closeClosure = { (updatedContact) in
            
            self.contactDeleteClosure?(updatedContact) 
            self.closeDetailVC()
        }
        
        if UIDevice.current.userInterfaceIdiom == .phone {
             self.present(UINavigationController(rootViewController: vc), animated: false, completion: nil)
        } else {
            let navicon = UINavigationController(rootViewController: vc)
            navicon.modalPresentationStyle = .overCurrentContext
            navicon.modalTransitionStyle   = .crossDissolve
            self.present(navicon, animated: true, completion: nil)
            
            //self.showDetailViewController(navicon, sender: self)
        }
    }
    
    
    func saveInAppleContact() {
        
        iphoneContact.givenName = contact!.firstName!
        iphoneContact.familyName = contact!.lastName!
        
        let image: UIImage = contact!.contactImage!
        iphoneContact.imageData = image.jpegData(compressionQuality: 0.2)
        
        if let email = contact?.email {
            let homeEmail = CNLabeledValue(label:CNLabelHome, value: email as NSString)
            iphoneContact.emailAddresses = [homeEmail]
        }
        
        iphoneContact.organizationName = contact!.companyName!
        
        iphoneContact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:contact!.mobile!))]
        
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(iphoneContact, toContainerWithIdentifier: nil)
        
        try? store.execute(saveRequest)
        saveInAppleContactSuccessAlert()
    }
    
    func saveInAppleContactSuccessAlert() {
        
        let  alert = UIAlertController(title: "", message: "Successfully Saved", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion:  nil)
    }
    
    
    func saveToiCloud() {
        print("save in iCloud")
        
        let newRecord = CKRecord(recordType: "Contacts")
        newRecord.setValue(contact!.firstName!, forKey: "firstName")
        newRecord.setValue(contact!.lastName!, forKey: "lastName")
        newRecord.setValue(contact!.mobile!, forKey: "mobile")
        newRecord.setValue(contact!.companyName!, forKey: "companyName")
        newRecord.setValue(contact!.email!, forKey: "email")
        newRecord.setValue(contact!.contactID!, forKey: "contactID")
        
        //       the only way to save upload UIImage as a CKAsset is to:
        //
        //        1.Save the image temporarily to disk
        //        2.Create the CKAsset
        //        3.Delete the temporary file
        
        let image = contact!.contactImage!
        let data = image.jpegData(compressionQuality: 0.2)// UIImage -> NSData, see also UIImageJPEGRepresentation
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        
        do {
            try data!.write(to: url!, options: [])
        } catch let e as NSError {
            print("Error! \(e)");
            return
        }
        newRecord["photo"] = CKAsset(fileURL: url!)
        
        publicDatabase.save(newRecord) { (records, error) in
            
            guard error == nil else {
                self.handle(error: error!)
                return
            }
            
            // Delete the temporary file (use in image) 
            do {
                try FileManager.default.removeItem(at: url!)
            } catch let error {
                print("Error deleting temp file: \(error)")
            }
            
            guard records != nil else { return }
            
            self.saveInAppleContactSuccessAlert()
            print("Record save successfully")
        }
    }
    
    func handle(error: Error) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true, completion: nil)
       // self.refreshControl!.endRefreshing()
    }
    
    func shareContactTapped(sourceView: UIView, sourceRect: CGRect) {
        
        let contact = createContact()
        
        do {
            try shareContacts(contacts: [contact], sourceView: sourceView, sourceRect: sourceRect)
        }
        catch let err{
            print("Error to share contact : \(err.localizedDescription)")
        }
    }
    
    func shareContacts(contacts: [CNContact], sourceView: UIView, sourceRect: CGRect) throws {
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        var filename = NSUUID().uuidString
        
        // Create a human friendly file name if sharing a single contact.
        if let contact = contacts.first, contacts.count == 1 {
            
            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: " ")
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        
        let data = try CNContactVCardSerialization.data(with: contacts)
        
        print("filename: \(filename)")
        print("contact: \(String(describing: String(data: data, encoding: String.Encoding.utf8)))")
        
        try data.write(to: fileURL, options: [.atomicWrite])
        
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        // On iPad, action sheets must be presented from a popover.
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceRect
            
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    func sharedLocation(sourceView: UIView, sourceRect: CGRect) {
        
        guard let cachesPathString = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            print("Error: couldn't find the caches directory.")
            return
        }
        
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
      
        let mapString = "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)"
//        guard CLLocationCoordinate2DIsValid(coordinate) else {
//            print("Error: the supplied coordinate, \(coordinate), is not valid.")
//            //return nil
//        }
        
        let vCardString = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;Shared Location;;;",
            "FN:Shared Location",
            "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "item1.X-ABLabel:map url",
            "homepage.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "END:VCARD"
            ].joined(separator: "\n")
        
        let vCardFilePath = (cachesPathString as NSString).appendingPathComponent("\(coordinate.latitude),\(coordinate.longitude).loc.vcf")
        
        do {
            try vCardString.write(toFile: vCardFilePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error {
            print("Error, \(error), saving vCard: \(vCardString) to file path: \(vCardFilePath).")
        }
        
        
       
       //let vCardData = NSURL(fileURLWithPath: vCardFilePath)
        
//        let imgViewMap = UIImageView()
////         let mapImage = UIImage(named: "default_user")
//
//        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue|\(coordinate.latitude),\(coordinate.longitude)&\("zoom=13&size=\(2 * Int(imgViewMap.frame.size.width))*\(2 * Int(imgViewMap.frame.size.height))")&sensor=true"
//
//      //  var mapUrl: NSURL = NSURL(string: staticMapUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))!
//        //var mapUrl: NSURL = NSURL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: String.Encoding.utf8))
//        let mapUrl: NSURL = NSURL(fileURLWithPath: staticMapUrl)
//
//        var image = UIImage()
//        let data = try? Data(contentsOf: mapUrl as URL)
//        if let imageData = data {
//            image = UIImage(data: imageData)!
//        }
        
//        let whtsapp = NSString.localizedStringWithFormat("whatsapp://send?webURLs=%@", mapString)
//        let whatsappURL = NSURL(string: whtsapp as String)
        
        let activityViewController = UIActivityViewController(
            activityItems: [mapString],
            applicationActivities: nil
        )
        
        // On iPad, action sheets must be presented from a popover.
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceRect
            
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func createContact() -> CNMutableContact {
        
        let newContact = CNMutableContact()
        newContact.givenName = contact!.firstName!
        newContact.familyName   = contact!.lastName!
        
        
        let image: UIImage = contact!.contactImage!
        let imageData = image.jpegData(compressionQuality: 0.02)
        newContact.imageData = imageData
        
        if let email = contact?.email {
            let homeEmail = CNLabeledValue(label:CNLabelHome, value: email as NSString)
            newContact.emailAddresses = [homeEmail]
        }
        
        newContact.organizationName = contact!.companyName!
        
        newContact.phoneNumbers = [CNLabeledValue(
            label:CNLabelPhoneNumberiPhone,
            value:CNPhoneNumber(stringValue:contact!.mobile!))]
        
        return newContact
    }
    
    func favoriteContact() {
        contact?.isFavorite = !(contact!.isFavorite!)
        ContactDataManager.sharedManager.update(contact: contact)
    }
    
    
    func createQRCode() {
        
        let contact = createContact()
        let contacts = [contact]
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }
        
        var filename = NSUUID().uuidString
        
        // Create a human friendly file name if sharing a single contact.
        if let contact = contacts.first, contacts.count == 1 {
            
            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: " ")
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        
        var data = Data()
        do {
            data = try CNContactVCardSerialization.data(with: contacts)
            
            try data.write(to: fileURL, options: [.atomicWrite])
        } catch let error {
            print(error)
        }
        
        
        //Converting vCard to QR Code
        guard let qrfilter = CIFilter(name: "CIQRCodeGenerator") else { return }
        qrfilter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = qrfilter.outputImage else { return }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = ciImage.transformed(by: transform)
        
        // --- INVERT Colors--
        // Create the filter
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return }
        
        // Set the input image to what we generated above
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        
        // Get the output CIImage
        guard let outputInvertedImage = colorInvertFilter.outputImage else { return }
        
        
        //---replace all black with transparency:
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
        // Set the input image to the colorInvertFilter output
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        // Get the output CIImage
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return }
        
        
        // Get a CIContext
        let context = CIContext()
        // Create a CGImage *from the extent of the outputCIImage*
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return }
        
        let image = UIImage(cgImage: cgImage)
        
        qrImageView.image = image
    }
    
    // CLose and Back the previous View Controller
    
    @objc func closeController(contact: Contact?) {
    
           self.dismiss(animated: true, completion: nil)
    }
    
    func closeDetailVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
   // MARK:- Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        self.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        //print(location.coordinate.latitude)
        //print(location.coordinate.longitude)
        
    }
    
    // MARK:- Action of Call , Message and Mail Button
    
    //Call on the Contact Number
    
    @objc func mobileList() {
        
        let number = contact?.mobile
        let phone = number!.replacingOccurrences(of: " ", with: "")
        
        if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    // Mail on the Contact Mail
    
    @objc func mailList() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([contact!.email!]);
        self.present(mailVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // Message on the Contact Message
    
    @objc func messageList() {
        if(MFMessageComposeViewController.canSendText()) {
            let controller =  MFMessageComposeViewController()
            controller.recipients = [contact!.mobile] as? [String]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch result {
        case MessageComposeResult.cancelled:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed:
            print("Message was failed")
            
        case MessageComposeResult.sent:
            print("Message sent successfully")
            break
        default:
            break
        }
    }
    
    
    // MARK:- Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 6
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailTableViewCell
            cell.detailTitle.text   =  contactTitle[indexPath.row]
            if let res = contactArray["Details"] {
                cell.detailValue.text   =  res[indexPath.row]
            }
            return cell
            
        } else {
            
           
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailTableViewCell
            
            if let res = contactArray["Action"] {
                cell.detailTitle.text   =  ""
                cell.detailValue.text   =  res[indexPath.row]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionArray[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 50
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    //MARK:- UITableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            saveInAppleContact()
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            saveToiCloud()
        }
        
        if indexPath.section == 1 && indexPath.row == 2 {
            
            if let cell = tableView.cellForRow(at: indexPath) {
                let selectedCellSourceView = tableView.cellForRow(at: indexPath)
                let selectedCellSourceRect = cell.bounds
                
                shareContactTapped(sourceView: selectedCellSourceView!, sourceRect: selectedCellSourceRect)
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            
            if contact!.isFavorite! {
                
                contactArray["Action"]![indexPath.row] = "Add to Favourites"
            } else {
                contactArray["Action"]![indexPath.row] = "Remove from Favourites"
            }
            favoriteContact()
            favoriteClouser?(true)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if let cell = tableView.cellForRow(at: indexPath) {
                let selectedCellSourceView = tableView.cellForRow(at: indexPath) 
                let selectedCellSourceRect = cell.bounds
                
                sharedLocation(sourceView: selectedCellSourceView!, sourceRect: selectedCellSourceRect)
            }
        }
        
        
        if indexPath.section == 1 && indexPath.row == 5 {
            print("Qr code generated..")
            createQRCode()
            
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                let newImageView = qrImageView
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .black
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                self.view.addSubview(newImageView)
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            } else {
                
                let vc = ContactQRCodeVC()
                vc.qrImageView = qrImageView
                vc.modalPresentationStyle = .formSheet
                self.present(vc, animated: true, completion: nil)
            }
        }
        
        self.detailTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}



