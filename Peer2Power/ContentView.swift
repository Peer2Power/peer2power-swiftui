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
                LoggedInView().environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration(initialSubscriptions: { subs in
                    if subs.first(named: userTeamSubName) == nil {
                        subs.append(QuerySubscription<Team>(name: userTeamSubName) {
                            $0.member_ids.contains(app.currentUser!.id)
                        })
                    }
                }))
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
