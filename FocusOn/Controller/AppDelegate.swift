//
//  AppDelegate.swift
//  FocusOn
//
//  Created by Spencer Forrest on 23/09/2018.
//  Copyright © 2018 Spencer Forrest. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Ask permission to use User Notification
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {(bool, error) in })
    // Instantiate dataController for Core Data
    let dataController = DataController.init(xcdatamodeldName: Constant.datamodelName)
    dataController.load()
    // Generate dummy data for testing purpose.
//     DummyData.generate(context: dataController.context)
    // Instantiate window and storyboard
    let storyboard = UIStoryboard(name: Constant.storyboardName, bundle: nil)
    window = UIWindow()
    window?.rootViewController = storyboard.instantiateInitialViewController()
    // Dependency Injection to children view controllers
    let tabBarController = window?.rootViewController as! TabBarController
    if let children = tabBarController.viewControllers {
      for child in children {
        if let child = child as? ViewController {
          child.setupDataController(dataController)
        }
      }
    }
    window?.makeKeyAndVisible()
    print(NSHomeDirectory())
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

