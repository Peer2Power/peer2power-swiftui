//
//  LoggedInView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct LoggedInView: View {
    @State private var showingContactForm = false
    @State private var showingContactList = false
    @State private var showingCollegesList = false
    @State private var showingLogOutreachSurvey = false
    
    @ObservedResults(Team.self) var teams
    @Environment(\.realm) var realm
    
    var flexSyncConfig = app.currentUser!.flexibleSyncConfiguration { subs in
        if subs.first(named: allCollegesSubName) == nil {
            subs.append(QuerySubscription<College>(name: allCollegesSubName))
        }
        
        if subs.first(named: allTeamsSubName) == nil {
            subs.append(QuerySubscription<Team>(name: allTeamsSubName))
        }
        
        if subs.first(named: userInfoSubName) == nil {
            subs.append(QuerySubscription<UserInfo>(name: userInfoSubName) { info in
                info.owner_id == app.currentUser!.id
            })
        }
        
        return
    }
    
    var body: some View {
        TabView {
            if teams.isEmpty {
                Text("Your team could not be found.")
                    .multilineTextAlignment(.center)
                    .font(.callout)
            } else {
                HomeView(userTeam: teams.first!)
                    .environment(\.realmConfiguration, flexSyncConfig)
                    .tabItem {
                        Label("Contacts", systemImage: "person.3.sequence")
                    }
                LeaderboardView()
                    .environment(\.realmConfiguration, flexSyncConfig)
                    .tabItem {
                        Label("Leaderboard", systemImage: "chart.bar")
                    }
            }
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
