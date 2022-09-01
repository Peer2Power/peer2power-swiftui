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
    func applicationDidFinishLaunching(_ application: UIApplication) {
        FirebaseApp.configure()
    }
}

@main
struct Peer2PowerApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(app)
        }
    }
}
