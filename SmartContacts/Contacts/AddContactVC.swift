//
//  ViewController.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 25/02/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import CloudKit

class AddContactVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    
    //MARK:- Views
    
    var firstNameTextField:UITextField =  {
        let textField                     =   UITextField()
        textField.autocorrectionType      =   .no
        textField.autocapitalizationType  =   .words
        textField.font                    =    UIFont.systemFont(ofSize: 16)
        var attributeTitle                     = NSMutableAttributedString()
        attributeTitle.append(NSAttributedString(string: "First Name *"))
        attributeTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 10, length: 2))
        textField.attributedPlaceholder   =  attributeTitle
        textField.returnKeyType           =    .next
        textField.tag                     =     0
        return textField
    }();
    
    var lastNameTextField:UITextField =  {
        let textField                     =   UITextField()
        textField.autocorrectionType      =   .no
        textField.autocapitalizationType  =   .words
        textField.font                    =    UIFont.systemFont(ofSize: 16)
        textField.placeholder             =   "Last name"
        textField.returnKeyType           =   .next
        textField.tag                     =   1
        return textField
    }();
    
    var companyNameTextField:UITextField =  {
        let textField                     =   UITextField()
        textField.autocorrectionType      =   .no
        textField.autocapitalizationType  =   .words
        textField.font                    =    UIFont.systemFont(ofSize: 16)
        textField.placeholder             =   "Company name"
        textField.returnKeyType           =   .next
        textField.tag                     =   2
        return textField
    }();
    
    var mobileTextField:UITextField =  {
        let textField                     =   UITextField()
        textField.autocorrectionType      =   .no
        textField.font                    =    UIFont.systemFont(ofSize: 16)
        var attributeTitle                     = NSMutableAttributedString()
        attributeTitle.append(NSAttributedString(string: "Mobile Number *"))
        attributeTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location: 13, length: 2))
        textField.attributedPlaceholder   =  attributeTitle
        textField.keyboardType            =    .phonePad
        textField.tag                     =   3
        return textField
    }();
    
    var emailTextField:UITextField =  {
        let textField                     =   UITextField()
        textField.autocorrectionType      =   .no
        textField.autocapitalizationType  =   .none
        textField.font                    =    UIFont.systemFont(ofSize: 16)
        textField.keyboardType            =   .emailAddress
        textField.placeholder             =   "Email "
        textField.returnKeyType           =   .done
        textField.tag                     =   4
        return textField
    }();
    
    var profileImageButton:UIButton = {
        let button                        =   UIButton()
        button.titleLabel?.lineBreakMode  =   .byWordWrapping
        button.titleLabel?.textAlignment  =   .center
        button.setTitle("Add\nPhoto", for: .normal)
        button.titleLabel?.font           = UIFont(name: "Arial", size: 16)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.backgroundColor            =   UIColor.lightGray
        button.setBackgroundImage(UIImage(named: "default_user"), for: .normal)
        button.imageView?.alpha           =   0.5
        button.titleLabel?.alpha          =   0.75
        button.imageView?.contentMode     =   .scaleAspectFill
        return button
    }();
    
    
    let cancelButton: UIButton = {
        let button                        = UIButton(type: .custom)
        let image                         = UIImage(named: "close_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.black
        return button
    }();
    
    let resetButton: UIButton = {
        let button                        =   UIButton(type: .custom)
        let image                         =   UIImage(named: "refresh_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor       = UIColor.black
        return button
    }();
    
    let submitButton: UIButton = {
        let button                        =   UIButton(type: .custom)
        let image                         =   UIImage(named: "done_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor       = UIColor.black
        return button
    }();
    
    // MARK:- Data
    
    var contactID: Int32?
    
    var isFavourite:Bool = false
    
    var contactSavedClosure: ((Contact) -> Void)?
    
    var contactImage = UIImageView(image: UIImage(named: "default_user"))
    
    var refContact:Contact? // used for editing
    
    var closeClosure: ((Contact) -> Void)?
    
    let transition = CustomTransition()
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    
    // MARK:- Initializers
    
    init(contact: Contact?) {
        
        self.refContact = contact
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isSync: Bool = false
    
    var isSyncCloud: Bool? {
        didSet {
            guard let res = isSyncCloud else {
                return
            }
            isSync = res
        }
    }
    
    
    // MARK:- View Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title  =   "New Contact"
        
        firstNameTextField.delegate      = self
        lastNameTextField.delegate       = self
        companyNameTextField.delegate    = self
        mobileTextField.delegate         = self
        emailTextField.delegate          = self
        
       // contactID = generateRandomNumber(numDigits: 10)
        contactID   = Int32(Int.random(in: 0...1000000000))
        
        createNewContactForm()
    }
    
    // MARK:- Local Methods
    
    func createNewContactForm(){
        
        // First Name Text Field
        
        self.view.addSubview(firstNameTextField)
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            firstNameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            firstNameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            firstNameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 130),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        let line1 = UIView()
        line1.backgroundColor = UIColor.black
        self.view.addSubview(line1)
        line1.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            line1.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 130),
            line1.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            line1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 120),
            line1.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        // Last Name Text Field
        
        self.view.addSubview(lastNameTextField)
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            lastNameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
            lastNameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            lastNameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 130),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        let line2 = UIView()
        line2.backgroundColor = UIColor.black
        self.view.addSubview(line2)
        line2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            line2.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 180),
            line2.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            line2.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 120),
            line2.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        // Company Name Text Field
        
        self.view.addSubview(companyNameTextField)
        companyNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            companyNameTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            companyNameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            companyNameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 130),
            companyNameTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        let line3 = UIView()
        line3.backgroundColor = UIColor.black
        self.view.addSubview(line3)
        line3.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            line3.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 230),
            line3.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            line3.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 120),
            line3.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        // Mobile Number Text Field
        
        self.view.addSubview(mobileTextField)
        mobileTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            mobileTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 250),
            mobileTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            mobileTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 130),
            mobileTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        let line4 = UIView()
        line4.backgroundColor = UIColor.black
        self.view.addSubview(line4)
        line4.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            line4.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 280),
            line4.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            line4.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 120),
            line4.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        // Email Text Field
        
        self.view.addSubview(emailTextField)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            emailTextField.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
            emailTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            emailTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 130),
            emailTextField.heightAnchor.constraint(equalToConstant: 30)
            ])
        
        let line5 = UIView()
        line5.backgroundColor = UIColor.black
        self.view.addSubview(line5)
        line5.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            line5.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 330),
            line5.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -18),
            line5.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 120),
            line5.heightAnchor.constraint(equalToConstant: 0.4)
            ])
        
        
        // Select Image
        
        self.view.addSubview(profileImageButton)
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            profileImageButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120),
            profileImageButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            profileImageButton.widthAnchor.constraint(equalToConstant: 80),
            profileImageButton.heightAnchor.constraint(equalToConstant: 80)
            ])
        
        profileImageButton.addTarget(self, action: #selector(profileImageButtonPressed), for: .touchUpInside)
        profileImageButton.layer.cornerRadius = 40
        profileImageButton.clipsToBounds      = true
        
        
        // Cancel Button
        
//        cancel.setImage(ResizeImage(image: UIImage(named: "close_icon")!, targetSize: CGSize(width: 20, height: 20)), for: .normal)
        
      //  if UIDevice.current.userInterfaceIdiom == .phone {
            cancelButton.addTarget(self, action: #selector(self.closeViewController), for: .touchUpInside)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: cancelButton), animated: true)
      // }
       
       
        // Reset Button
          resetButton.setImage(ResizeImage(image: UIImage(named: "refresh_icon")!, targetSize: CGSize(width: 16, height: 16)), for: .normal)
          resetButton.addTarget(self, action: #selector(self.resetFields), for: .touchUpInside)
          let rightBarButton1 = UIBarButtonItem()
          rightBarButton1.customView = resetButton

        
        // Submit Button
        submitButton.setImage(ResizeImage(image: UIImage(named: "done_icon")!, targetSize: CGSize(width: 25, height: 25)), for: .normal)
        submitButton.addTarget(self, action: #selector(self.saveContact), for: .touchUpInside)
        let rightBarButton2 = UIBarButtonItem()
        rightBarButton2.customView = submitButton
        
        
        if let _ = refContact {
            
            isMutable()
            
            self.navigationItem.setRightBarButtonItems([rightBarButton2], animated: true)
        } else {
            
            self.navigationItem.setRightBarButtonItems([rightBarButton1,rightBarButton2], animated: true)
        }
    }
    
    
    // When edit mode is active then update the fields
    func isMutable() {
        
        self.title = ""
        self.navigationController?.navigationBar.barTintColor      =  UIColor.white
        self.navigationController?.navigationBar.isTranslucent     =  true
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        self.contactID                  =  refContact?.contactID
        self.firstNameTextField.text    =  refContact?.firstName
        self.lastNameTextField.text     =  refContact?.lastName
        self.companyNameTextField.text  =  refContact?.companyName
        self.mobileTextField.text       =  refContact?.mobile
        self.emailTextField.text        =  refContact?.email
        self.profileImageButton.setImage(refContact?.contactImage, for: .normal)
        self.contactImage.image         =  refContact?.contactImage
        self.isFavourite                =  refContact!.isFavorite!
        
        
        let deleteButton           =  UIButton()
        deleteButton.setTitle("Delete Contact", for: .normal)
        deleteButton.backgroundColor = UIColor.red
        deleteButton.layer.cornerRadius = 10
        self.view.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        deleteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40).isActive = true
        deleteButton.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 30).isActive = true
        
        deleteButton.addTarget(self, action: #selector(deleteAlert), for: .touchUpInside)
    }
    
    
    // Select the Image or Camera from the Action Sheet
    
    @objc func profileImageButtonPressed() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { alert in
                self.openCamera()
            }))
        
           alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { alert in
                self.openGallery()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // On iPad, action sheets must be presented from a popover.
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.profileImageButton.frame.midX, y: self.profileImageButton.frame.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = [UIPopoverArrowDirection.left]
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
   @objc func openCamera() {
    
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            //UIImagePickerCOntroller is a view controller that lets a user pick media from their photo library.
            let imagePickerController = UIImagePickerController()
            
            //Only allow mobile to open camera.
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing  = true
            
            //Make sure ViewController is notified when the user picks an image.
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
 @objc  func openGallery() {
      
        //UIImagePickerCOntroller is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        //Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing  =  true
        
        //Make sure ViewController is notified when the user picks an image.
         imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
   
    
    // Push to Contact Details View Controller and show the alert for successful submit
    
    @objc func  saveContact() {
        
        if firstNameTextField.text == "" {
            errorAlert(message: "First Name")
            return
        }
        
        if mobileTextField.text  == "" {
            errorAlert(message: "Mobile Number")
            return
        }
        
        if !isValidMobile(value: mobileTextField.text!) {
            mobileValidationAlert()
            return
        }
        
//        if let mail = emailTextField.text {
//            if !isValidEmail(email: mail) {
//                emailValidationAlert()
//                return
//            }
//        }
        
        let newContact = Contact()
        
        newContact.contactID       = self.contactID!
        newContact.firstName       = self.firstNameTextField.text!
        newContact.lastName        = self.lastNameTextField.text!
        newContact.companyName     = self.companyNameTextField.text!
        newContact.mobile          = self.mobileTextField.text!
        newContact.email           = self.emailTextField.text!
        newContact.contactImage    = self.contactImage.image
        newContact.isFavorite      = self.isFavourite
        
        DispatchQueue.main.async {
        if let _ = self.refContact {
            
            ContactDataManager.sharedManager.update(contact: newContact)
            
            
            let isSync = AppSettings.shared.isSynchWithICloud
            if isSync == true {
                iCloudDataManager.sharedManager.updateContactsFromiCloud(contact: newContact)
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.dismiss(animated: true) {
                    self.contactSavedClosure?(newContact)
                }
            } else {
                
//                let vc = ContactDetailVC(contact: newContact)
//                self.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
//                self.contactSavedClosure?(newContact)
                self.dismiss(animated: true) {
                    self.contactSavedClosure?(newContact)
                }
            }
           

        } else {
            
            ContactDataManager.sharedManager.add(contact: newContact)
            ContactDataManager.sharedManager.saveContactList()
            
         
            // Find in database is syncable or not if isSync is on then save in icloud otherwise not
            let isSync = AppSettings.shared.isSynchWithICloud
                if isSync == true {
                  // self.saveToiCloud(contact: newContact)
                    iCloudDataManager.sharedManager.saveContactsToiCloud(contact: newContact)
                }
            
            self.dismiss(animated: true) {
                self.contactSavedClosure?(newContact)
            }
        }
        }
    }

    
    @objc func deleteContact() {
        
        DispatchQueue.main.async {
            if let contact = self.refContact {
                
                 // Find in database is syncable or not if isSync is on then delete from icloud database otherwise not
                let isSync = AppSettings.shared.isSynchWithICloud
                    if isSync == true {
                        iCloudDataManager.sharedManager.queryToFetchICloudDatabase()
                        iCloudDataManager.sharedManager.deleteFromiCloud(contact: contact)
                    }
                ContactDataManager.sharedManager.delete(contact: contact)
            }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.dismiss(animated: false, completion: {
                    self.closeClosure?(self.refContact!)
                })
                
            } else {
//                let vc = ContactDetailVC(contact: self.refContact!)
//                self.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
//                self.closeClosure?(self.refContact!)
                
                self.dismiss(animated: false, completion: {
                    self.closeClosure?(self.refContact!)
                })
            }
        }
    }

    
    @objc func resetFields() {
        
        firstNameTextField.text = ""
        lastNameTextField.text = ""
        companyNameTextField.text = ""
        mobileTextField.text = ""
        emailTextField.text = ""
        
        profileImageButton.titleLabel?.lineBreakMode  =   .byWordWrapping
        profileImageButton.titleLabel?.textAlignment  =   .center
        profileImageButton.setTitle("Add\nPhoto", for: .normal)
        profileImageButton.titleLabel?.font           = UIFont(name: "Arial", size: 16)
        profileImageButton.setTitleColor(UIColor.blue, for: .normal)
        profileImageButton.backgroundColor            =   UIColor.lightGray
        profileImageButton.setBackgroundImage(UIImage(named: "default_user"), for: .normal)
        profileImageButton.imageView?.alpha           =   0.5
        profileImageButton.titleLabel?.alpha          =   0.75
        isFavourite = false
    }
    
    
    // CLose and Back the previous View Controller
    
    @objc func closeViewController() {
         // Dismiss in iPhone
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.dismiss(animated: true, completion: nil)
        } else {
            // Dismiss in iPad when update tab open
//            if let contact = refContact {
//                 let vc = ContactDetailVC(contact: contact)
//                 self.showDetailViewController(UINavigationController(rootViewController: vc), sender: self)
//
//
//            } else {
                // Dismiss in iPad when new tab open
                self.dismiss(animated: true, completion: nil)
           // }
        }
    }
    
    
    // MARK:-  Alert Function
    
    func isValidMobile(value: String) -> Bool {
        let PHONE_REGEX = "^[0-9+]{0,1}+[0-9- ()]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    func mobileValidationAlert() {
        let alert = UIAlertController(title: "", message: "Mobile Number is not Valid", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func emailValidationAlert() {
        let alert = UIAlertController(title: "", message: "Email is not Valid", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func ValidationAlert() {
        let alert = UIAlertController(title: "", message: "Mobile Number is not Valid", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func errorAlert(message: String) {
        
        let alert = UIAlertController(title: "", message: "\(message) Required", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func duplicateAlert() {
        
        let alert = UIAlertController(title: "Duplicate Alert", message: "Contact Number already added", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func deleteAlert() {
        let alert = UIAlertController(title: "", message: "Are you sure want to delete this Contact?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alert in
            return (self.deleteContact())
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK:- UIImagePickerController Delegate
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //The info dictionary may cantain multiple representaioons of the image. You want to use the edit or original.
        
        if let selectImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            //Set photoImageIvew to display the selected image.
            profileImageButton.setImage(selectImage, for: .normal)
            profileImageButton.imageView?.layer.cornerRadius = 40
            
            contactImage.image = selectImage
            
        }  else  if let selectImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            //Set photoImageIvew to display the selected image.
            profileImageButton.setImage(selectImage, for: .normal)
            profileImageButton.imageView?.layer.cornerRadius = 40
            
          //  let resizeImage = ResizeImage(image: selectImage, targetSize: CGSize(width: 80, height: 80))
            
            contactImage.image = selectImage
            
        }
        
        //Dismiss the picker.
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // Change The Size of Image
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    // MARK:- UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            saveContact()
        }
        return true
    }
    
}

extension AddContactVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        transition.presenting = false
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
