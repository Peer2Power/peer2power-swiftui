//
//  LoggedInView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift

struct LoggedInView: View {
    @State private var showingLogOutreachSurvey = false
    
    @ObservedResults(Team.self,
                     where: {$0.member_ids.contains(app.currentUser!.id)})
    var teams
    
    @ViewBuilder
    var body: some View {
        if teams.isEmpty {
            NavigationView {
                SchoolsListView()
            }
        } else {
            TabView {
                HomeView(userTeam: teams.first!)
                    .tabItem {
                        Label("Contacts", systemImage: "person.3.sequence")
                    }
                LeaderboardView(userTeam: teams.first!)
                    .tabItem {
                        Label("Leaderboard", systemImage: "chart.bar")
                    }
                NavigationView {
                    SettingsView(userTeam: teams.first!)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .accentColor(Color("TabItemSelectedColor"))
        }
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
