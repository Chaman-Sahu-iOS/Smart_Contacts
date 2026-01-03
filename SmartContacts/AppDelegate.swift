//
//  AppDelegate.swift
//  DemoApp
//
//  Created by chaman-pt2789 on 25/02/19.
//  Copyright © 2019 Zoho. All rights reserved.
//

import UIKit
import GoogleSignIn
import WatchConnectivity
import Contacts

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    
    // When sign in button tapped
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        
//        if let error = error {
//            print("\(error.localizedDescription)")
//        } else {
//            // Perform any operations on signed in user here.
//            //            let userId = user.userID                  // For client-side use only!
//            //            let idToken = user.authentication.idToken // Safe to send to the server
//            //            let fullName = user.profile.name
//            //            let givenName = user.profile.givenName
//            //            let familyName = user.profile.familyName
//            //            let email = user.profile.email
//            //            // ...
//            print(user.profile.email!)
//            print(user.profile.imageURL(withDimension: 400)!)
//        }
//    }
    
    

    // MARK:- UIApplication Delegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("did finish launch")
        
        window = UIWindow(frame: UIScreen.main.bounds)
    
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            let rootNavigationControllerVC = MainTabBarVC()
            window?.rootViewController          =   rootNavigationControllerVC
            window?.makeKeyAndVisible()
        } else {
            window?.backgroundColor = UIColor.white
            
            let splitViewController = UISplitViewController()
            let rootViewController    = MainTabBarVC()
            let detailViewController  = ContactDetailVC()   
            
           // let rootNavigationController = UINavigationController(rootViewController: rootViewController)
          //  let detailNavigationController = UINavigationController(rootViewController: detailViewController)
            splitViewController.viewControllers = [rootViewController, detailViewController]
            
            splitViewController.delegate = self
            
            splitViewController.preferredDisplayMode = UISplitViewController.DisplayMode.allVisible
            
            let containerViewController: CustomVC = CustomVC()
            containerViewController.setEmbeddedViewController(splitViewController: splitViewController)
            
            window?.rootViewController = containerViewController
            window?.makeKeyAndVisible()
        }
        
       
        
        // Client ID for sign in google account
      //  GIDSignIn.sharedInstance().clientID = "1009501789746-su8sdu78hc29bs2eotfih4nsqmimuluh.apps.googleusercontent.com"
        
        print("Document Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found !!" )
        
        
        // Check Watch are connected or not if Connect set delegate and activate
        if WCSession.isSupported() {

            WCSession.default.delegate = self
            WCSession.default.activate()
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // For GoogleSignIn v9+, simply forward the URL to the handler.
        return GIDSignIn.sharedInstance.handle(url)
    }
    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//        // ...
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("Reisgn active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("did enter background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("will enter foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("did become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("terminate")
    }
}


extension AppDelegate: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

        if let error = error {
            print("Activation in iOS failed with error: \(error.localizedDescription)")
            return
        }
        print("iOS activated with state: \(activationState.rawValue)")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")

    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
    }


    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {

        
        if let response = message["request"] as? String {
            
            //-----Contacts--------------
            var  contactListArray = [Contact]()
            contactListArray = ContactDataManager.sharedManager.getContactsList()
            contactListArray = contactListArray.sorted(by: {$0.firstName! < $1.firstName!})
            
            var contactArray = [String: [Any]]()
            contactArray = populateContacts(contactListArray: contactListArray)
            
            
            //--------Groups--------------
            var groupData      =   [String: [Contact]]()  // Key is Group Name & Value is Group Contact
            groupData = GroupDataManager.sharedManager.getGroupsList()
            
            var groupsArray = [String: [String: [Any]]]()
            
            for (key, value) in groupData {
                
                var groupContactArray = [String: [Any]]()
                groupContactArray = populateContacts(contactListArray: value)
                
                groupsArray[key] = groupContactArray
            }
            
            
            
            switch response {
            case "Contacts":
                replyHandler(contactArray)
            case "Groups":
                replyHandler(groupsArray)
            default:
                replyHandler([:])
            }
           
        } 
        
         if let name = message["firstName"] as? String {
            
            print(name)
            replyHandler(["NewContact": "Successfully Saved"])
        }
        
        
    }
    
    func populateContacts(contactListArray: [Contact]) -> [String: [Any]] {
        
        var contactArray = [String: [Any]]()
        
        var contactIDArray = [Int32]()
        var nameArray = [String]()
        var mobileArray = [String]()
        var emailArray = [String]()
        var imageArray = [Data]()
        var favouriteArray = [Bool]()
        
        var qrCodeImageArray = [Data]()
        
        for contact in contactListArray {
            // IDs and strings
            contactIDArray.append(contact.contactID ?? Int32(Int.random(in: 0...1_000_000_000)))
            let name = "\(contact.firstName ?? "")  \(contact.lastName ?? "")"
            nameArray.append(name)
            mobileArray.append(contact.mobile ?? "")
            emailArray.append(contact.email ?? "")
            favouriteArray.append(contact.isFavorite ?? false)

            // Contact thumbnail image (always append to keep arrays in sync)
            if let image = contact.contactImage {
                let compressedImage = ResizeImage(image: image, targetSize: CGSize(width: 50, height: 50))
                let imageData = compressedImage.jpegData(compressionQuality: 0.05) ?? Data()
                imageArray.append(imageData)
            } else {
                imageArray.append(Data())
            }

            // QR image (always append valid PNG data to avoid crashes on watch)
            if let qrImage = createQRCode(contact: contact) {
                let compressedQR = ResizeImage(image: qrImage, targetSize: CGSize(width: 75, height: 75))
                let qrData = compressedQR.pngData() ?? Data()
                qrCodeImageArray.append(qrData)
            } else {
                qrCodeImageArray.append(placeholderPNGData())
            }
        }
        
        contactArray["contactId"] = contactIDArray
        contactArray["name"]   = nameArray
        contactArray["mobile"] = mobileArray
        contactArray["email"]  = emailArray
        contactArray["image"]  = imageArray
        contactArray["favourite"] = favouriteArray
        
        contactArray["qrImage"]  = qrCodeImageArray
        
        return contactArray
    }

    // Produce a 1x1 transparent PNG to keep arrays aligned and avoid decode crashes
    private func placeholderPNGData() -> Data {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData() ?? Data()
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
    
    
    func createQRCode(contact: Contact) -> UIImage? {
        
        let contact = createContact(contact: contact)
        let contacts = [contact]
        
        guard let directoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        var filename = NSUUID().uuidString
        
        // Create a human friendly file name if sharing a single contact.
        if let contact = contacts.first, contacts.count == 1 {
            
            if let fullname = CNContactFormatter().string(from: contact) {
                filename = fullname.components(separatedBy: " ").joined(separator: " ")
            }
        }
        
        let fileURL = directoryURL.appendingPathComponent(filename).appendingPathExtension("vcf")
        
        var data: Data?
        do {
           try  data = CNContactVCardSerialization.data(with: contacts)
            
            do {
                try data?.write(to: fileURL, options: [.atomic])
            } catch let error {
                print("Error to write data to fileURL \(error)")
            }
            
           
        } catch let error {
            print("Error to create vCard \(error)")
        }
        
        
        //Converting vCard to QR Code
        guard let qrfilter = CIFilter(name: "CIQRCodeGenerator") else { return  nil}
        qrfilter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = qrfilter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 1, y: 1)
        let scaledQrImage = ciImage.transformed(by: transform)
        
        // --- INVERT Colors--
        // Create the filter
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else { return  nil}
        
        // Set the input image to what we generated above
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        
        // Get the output CIImage
        guard let outputInvertedImage = colorInvertFilter.outputImage else { return nil }
        
        
        //---replace all black with transparency:
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        // Set the input image to the colorInvertFilter output
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        // Get the output CIImage
        guard let outputCIImage = maskToAlphaFilter.outputImage else { return nil }
        
        
        // Get a CIContext
        let context = CIContext()
        // Create a CGImage *from the extent of the outputCIImage*
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil}
    
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
    
    func createContact(contact: Contact) -> CNMutableContact {
        
        let newContact = CNMutableContact()
        newContact.givenName = contact.firstName ?? ""
        newContact.familyName   = contact.lastName ?? ""
        
        if let image: UIImage = contact.contactImage {
            newContact.imageData = image.jpegData(compressionQuality: 0.02)
        }
        
        if let email = contact.email, !email.isEmpty {
            let homeEmail = CNLabeledValue(label:CNLabelHome, value: email as NSString)
            newContact.emailAddresses = [homeEmail]
        }
        
        if let company = contact.companyName { newContact.organizationName = company }
        
        if let mobile = contact.mobile, !mobile.isEmpty {
            newContact.phoneNumbers = [CNLabeledValue(
                label:CNLabelPhoneNumberiPhone,
                value:CNPhoneNumber(stringValue: mobile))]
        }
        
        return newContact
    }
}
