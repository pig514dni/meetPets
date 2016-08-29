//
//  AppDelegate.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/3.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMobileAds
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let GoogleAdsID = "填入Admob Id"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //GOOGLE MAP KEY
        GMSServices.provideAPIKey("填入Google map Key")
    
  
        //NavigationBar 背景顏色
        UINavigationBar.appearance().barTintColor = UIColor(red:255.0/255.0, green:224.0/255.0, blue:102.0/255.0 ,alpha: 1.0)
        
        //NavigationBar 字體顏色
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        if let barFont = UIFont(name: "Avenir-Book", size: 24.0) {
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName:barFont]
        }
        
        // GOOGLE ADMOB ID
        GADMobileAds.configureWithApplicationID(GoogleAdsID);
        
        
        
        // 判斷是否是第一次執行APP
        let firstLuanch = !NSUserDefaults.standardUserDefaults().boolForKey("notFirstLuanch")
        
        if firstLuanch == true {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstLuanch")
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainPageVC = storyboard.instantiateViewControllerWithIdentifier("MainPage")
            window?.rootViewController = mainPageVC
        }
        
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func application(application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        for window in UIApplication.sharedApplication().windows {
            window.removeConstraints(window.constraints)
        }
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

