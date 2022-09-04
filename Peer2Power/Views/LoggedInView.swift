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
    
    var body: some View {
        if teams.isEmpty {
            CollegeListView()
        } else {
            TabView {
                HomeView(userTeam: teams.first!)
                    .tabItem {
                        Label("Contacts", systemImage: "person.3.sequence")
                    }
                LeaderboardView()
                    .tabItem {
                        Label("Leaderboard", systemImage: "chart.bar")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
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
