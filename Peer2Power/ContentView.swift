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
        if app.currentUser != nil && app.currentUser?.state == .loggedIn {
            LoggedInView().environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration(initialSubscriptions: { subs in
                if subs.first(named: allTeamsSubName) == nil {
                    subs.append(QuerySubscription<Team>(name: allTeamsSubName))
                }
            }))
        } else {
            NavigationView {
                ChooseTeamView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
