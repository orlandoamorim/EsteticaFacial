//
//  AppDelegate.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim on 05/10/15.
//  Copyright © 2015 Orlando Amorim. All rights reserved.
//

import UIKit
import RealmSwift
import PasscodeLock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var passcodeLockPresenter: PasscodeLockPresenter = {
        
        let configuration = PasscodeLockConfiguration()
        let presenter = PasscodeLockPresenter(mainWindow: self.window, configuration: configuration)
        
        return presenter
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        passcodeLockPresenter.presentPasscodeLock()
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                migration.enumerate(Patient.className()) { oldObject, newObject in
                    if oldSchemaVersion < 1 {
                        newObject?["records"] = nil
                    }
                }
                
                migration.enumerate(Record.className(), { (oldObject, newObject) in
                    if oldSchemaVersion < 2 {
                        newObject?["surgeryDescription"] = ""
                    }
                    if oldSchemaVersion < 3 {
                        newObject?["create_at"] = NSDate()
                        newObject?["update_at"] = NSDate()
                    }
                    
                })
        })
        
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        passcodeLockPresenter.presentPasscodeLock()
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
}

