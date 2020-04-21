//
//  AppDelegate.swift
//  SenseEar-Project
//
//  Created by Lauren Bannon on 08/12/2019.
//  Copyright © 2019 Lauren Bannon. All rights reserved.
//

import UIKit
import Firebase
import PDFNet
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        PTPDFNet.initialize("Insert Commercial License Key Here After Purchase")
        
        let audioSession = AVAudioSession.sharedInstance()
                       
        do {
           
           try! audioSession.setCategory(.playback, mode: .default)
           try! audioSession.setMode(AVAudioSession.Mode.measurement)
           try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
           
        } catch {
           print("Setting category to AVAudioSessionCategoryPlayback failed: \(error)")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

