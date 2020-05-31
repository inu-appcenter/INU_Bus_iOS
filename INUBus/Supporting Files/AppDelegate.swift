//
//  AppDelegate.swift
//  INUBus
//
//  Created by zun on 09/07/2019.
//  Copyright © 2019 zun. All rights reserved.
//

import UIKit
import KYDrawerController
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 첫 실행시 즐겨찾기 UserDefaults를 생성
    if UserDefaults.standard.value(forKey: StringConstants.favorArray.rawValue) == nil {
      UserDefaults.standard.set([String](), forKey: StringConstants.favorArray.rawValue)
    }
    
    // drawer 설정 부분
    let mainViewController = UIStoryboard(name: StringConstants.main.rawValue,
                                          bundle: nil)
      .instantiateViewController(withIdentifier: StringConstants.tabBarController.rawValue)
    let drawerViewController = UIStoryboard(name: StringConstants.drawer.rawValue,
                                            bundle: nil)
      .instantiateViewController(withIdentifier: StringConstants.drawerViewController.rawValue)
    let drawerController = ExtensionKYDrawerController(drawerDirection: .right,
                                                       drawerWidth: 265)
    
    drawerController.mainViewController = mainViewController
    drawerController.drawerViewController = drawerViewController
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = drawerController
    window?.makeKeyAndVisible()
    
    UITabBarItem.appearance()
      .setTitleTextAttributes([NSAttributedString.Key.font: UIFont(
        name: StringConstants.notoSansMedium.rawValue, size: 15)!],
        for: .normal)

    return true
  }
  
  // 화면 고정
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    // 세로 화면 고정
    return [.portrait]
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
