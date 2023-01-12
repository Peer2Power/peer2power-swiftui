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
    @StateObject var reachability = Reachability()
    
    var body: some View {
        if reachability.connected {
            if app.currentUser != nil && app.currentUser?.state == .loggedIn {
                LoggedInView().environment(\.realmConfiguration, app.currentUser!.flexibleSyncConfiguration(clientResetMode: .recoverOrDiscardUnsyncedChanges(), initialSubscriptions: { subs in
                    if subs.first(named: allTeamsSubName) == nil {
                        subs.append(QuerySubscription<Team>(name: allTeamsSubName))
                    }
                }))
            } else {
                NavigationView {
                    ClubsListView()
                        .navigationTitle(app.currentUser == nil ? "Sign Up" : "Choose a Club Team")
                }
            }
        } else {
            VStack(spacing: 10.0) {
                Text("No Internet Connection")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("You are not connected to the internet. Please check your internet connection and try again.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 15.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
