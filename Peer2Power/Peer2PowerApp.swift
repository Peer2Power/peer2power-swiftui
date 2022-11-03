//
//  Peer2PowerApp.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import SwiftUI
import RealmSwift
import Firebase
import SPAlert

let app = RealmSwift.App(id: realmAppID)

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        SPAlertView.appearance().tintColor = .systemGreen
        
        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")
        UITabBar.appearance().unselectedItemTintColor = .white
        
        return true
    }
}

@main
struct Peer2PowerApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(app)
        }
    }
}
