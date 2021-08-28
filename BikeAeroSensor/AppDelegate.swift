//
//  AppDelegate.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/16.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initWindow()
        return true
    }

    private func initWindow() {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = #colorLiteral(red: 0.1791777015, green: 0.1778892577, blue: 0.1801685095, alpha: 1)
        window.makeKeyAndVisible()
        
        let color = UserDefaults.standard.object(forKey: "theme_color") as? String
        UIColor.theme = UIColor(hexStr: color ?? "018BD5")
//        App.isToHiddenStatus = window.safeAreaInsets.top <= 20
        
        window.rootViewController = MainViewController()
        
        self.window = window
        
    }
    
    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

