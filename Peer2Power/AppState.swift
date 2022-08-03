//
//  AppState.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import RealmSwift
import SwiftUI
import Combine

class AppState: ObservableObject {
    var loggedIn: Bool {
        app.currentUser != nil && app.currentUser?.state == .loggedIn
    }
}
