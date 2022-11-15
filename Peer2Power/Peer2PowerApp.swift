//
//  Peer2PowerApp.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import SwiftUI
import RealmSwift
import Firebase

let app = RealmSwift.App(id: realmAppID)

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let remoteConfig = RemoteConfig.remoteConfig()
        /* let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // FIXME: remove this in production, should fetch the default value of 12 hours.
        remoteConfig.configSettings = settings */
        
        remoteConfig.setDefaults([
            "endOfStudySurveyAvailableDate": "01-01-2023 23:59" as NSObject
        ])
        
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
