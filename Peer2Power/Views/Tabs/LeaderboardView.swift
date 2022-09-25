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
                     where: {$0.party == .democrat})
    var demTeams
    
    @ObservedResults(Team.self,
                     where: {$0.party == .republican})
    var repTeams
    
    @ObservedRealmObject var userTeam: Team
    
    var body: some View {
        VStack {
            Text("Your team, the \(userTeam.school_name) \(userTeam.party.rawValue), has contributed \(userTeam.score) points to the national \(userTeam.party.rawValue) total.")
                .font(.title2)
                .multilineTextAlignment(.center)
            HStack {
                Image("Democrats")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.45)
                    .overlay(alignment: .center) {
                        VStack {
                            Text("Democrats have")
                                .font(.title3)
                                .multilineTextAlignment(.center)
                            Text("\(demTeams.sum(of: \Team.score))")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("points")
                                .multilineTextAlignment(.center)
                                .font(.title3)
                        }
                    }
                Image("Republicans")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.45)
                    .overlay(alignment: .center) {
                        VStack {
                            Text("Republicans have")
                                .font(.title3)
                            Text("\(repTeams.sum(of: \Team.score))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("points")
                                .font(.title3)
                        }
                    }
            }
        }
        .padding(.horizontal, 15.0)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView( userTeam: Team(value: [
            "school_name": "Lafayette College",
            "party": "Democrats",
            "score": 42
        ]))
    }
}
