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

@main
struct Peer2PowerApp: SwiftUI.App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(app)
        }
    }
}
