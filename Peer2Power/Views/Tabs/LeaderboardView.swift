//
//  LeaderboardView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift

struct LeaderboardView: View {
    @ObservedResults(Team.self,
                     sortDescriptor: SortDescriptor(keyPath: "score", ascending: false))
    var teams
    
    var body: some View {
        if teams.isEmpty {
            VStack {
                Text("No Teams Found")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
                Text("No teams could be found. Please check your internet connection and try again.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 15)
            }
        } else {
            List {
                ForEach(teams) { team in
                    LeaderboardRow(team: team)
                }
            }
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
