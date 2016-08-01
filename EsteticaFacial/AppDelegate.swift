//
//  AppDelegate.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 05/10/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

// TESTANDO AGORA COM DELETE INCLUSO

import UIKit
import RealmSwift
import PasscodeLock
import SwiftyDropbox

import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let version:String = NSBundle.mainBundle().releaseVersionNumber!
    let build:String = NSBundle.mainBundle().buildVersionNumber!
    var trelloCard:String = "https://trello.com/c/TxP9AFJr"
    var trelloBoard:String = "https://trello.com/b/YfRp2cch"
    

    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        passcodeLockPresenter.presentPasscodeLock()
        
        print(Realm.Configuration.defaultConfiguration.schemaVersion)
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 1, //TESTE -> Default [1]
            migrationBlock: { migration, oldSchemaVersion in
                migration.enumerate(Patient.className()) { oldObject, newObject in
                    if oldSchemaVersion < 1 {
                        newObject?["records"] = nil
                    }
                }
                
                migration.enumerate(Record.className(), { (oldObject, newObject) in
                    if oldSchemaVersion < 1 {
                        newObject?["surgeryDescription"] = ""

                        newObject?["create_at"] = NSDate()
                        newObject?["update_at"] = NSDate()
                        newObject?["compareImage"] = nil
                        newObject?["cloudState"] = CloudState.Ok.rawValue

                    }
                    
                })
                //TESTE -> Default [1]
                migration.enumerate(Image.className(), { (oldObject, newObject) in
                    if oldSchemaVersion < 1 {
                        newObject?["imageRef"] = 0.toString()
                        newObject?["recordID"] = ""
                        if RealmParse.cloud.isLogIn() != .LogOut {
                            newObject?["cloudState"] = CloudState.Update.rawValue
                        }else {
                            newObject?["cloudState"] = CloudState.Ok.rawValue
                        }
                        newObject?["compareImageID"] = ""
                    }
                    
                })
        })

        let configuration = ParseClientConfiguration {
            $0.applicationId = "5aa6JqGqhC7iw8bG6CXC4imvXlCZ63i7j9bC9Ace"
//            $0.server = "http://YOUR_PARSE_SERVER:1337/parse"
            $0.clientKey = "0G40jdCQrAVB8cyzhEGrwDDLUMk0tiSQFh7WshCN"
        }
        Parse.initializeWithConfiguration(configuration)
        
        Dropbox.setupWithAppKey("ldu83a9eu7wtje1")
        
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }
        }
        
        return false
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        passcodeLockPresenter.presentPasscodeLock()
        self.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)

    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void)
    {
        let handledShhortcutItem = self.handleShortcutItem(shortcutItem)
        completionHandler(handledShhortcutItem)
        
    }
    
    
    enum ShortcutIdentifier: String
    {
        case First
        case Second
        
        init?(fullType: String)
        {
            guard let last = fullType.componentsSeparatedByString(".").last else {return nil}
            self.init(rawValue: last)
        }
        
        var type: String
        {
            return NSBundle.mainBundle().bundleIdentifier! + ".\(self.rawValue)"
        }
        
//        echo 'com.UFPI.EsteticaFacial.First' | nc 127.0.0.1 8000
    }
    
    @available(iOS 9.0, *)
    func handleShortcutItem(shortcutItem: UIApplicationShortcutItem) -> Bool
    {
        var handled = false
        
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        guard let shortcutType = shortcutItem.type as String? else { return false }
        
        switch (shortcutType)
        {
        case ShortcutIdentifier.First.type:
            handled = true

            let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SurgeryNavDetailsVC") as! UINavigationController
            let controller = navVC.viewControllers[0] as! SurgeryDetailsVC
            controller.contentToDisplay = .Adicionar
            self.window?.rootViewController?.presentViewController(navVC, animated: true, completion: nil)
            
            break
        case ShortcutIdentifier.Second.type:
            handled = true
            
            let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SurgeryNavDetailsVC") as! UINavigationController
            let controller = navVC.viewControllers[0] as! SurgeryDetailsVC
            controller.contentToDisplay = .Adicionar
            controller.handleShortcut = true
            self.window?.rootViewController?.presentViewController(navVC, animated: true, completion: nil)
            break
        default:
            break
        }
        
        return handled
        
    }
    
}

