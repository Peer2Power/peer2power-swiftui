//
//  ContentView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/2/22.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @EnvironmentObject var app: RealmSwift.App
    
    var body: some View {
        NavigationView {
            if app.currentUser != nil && app.currentUser?.state == .loggedIn {
                LoggedInView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
