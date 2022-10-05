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
        VStack(spacing: 10.0) {
            Text("Your team, the \(userTeam.school_name) \(userTeam.party.rawValue), has contributed")
                .font(.title2)
                .multilineTextAlignment(.center)
            Text("\(userTeam.score)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            if userTeam.score != 1 {
                Text("points to the national \(userTeam.party.rawValue) total.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
            } else {
                Text("point to the national \(userTeam.party.rawValue) total.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            Divider()
            HStack {
                VStack {
                    Image("Democrats")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("DemsColor"))
                    Text("Democrats have")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    Text("\(demTeams.sum(of: \Team.score))")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    if demTeams.sum(of: \Team.score) != 1 {
                        Text("points")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                    } else {
                        Text("point")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                    }
                }
                VStack {
                    Image("Republicans")
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("GOPColor"))
                    Text("Republicans have")
                        .font(.title3)
                    Text("\(repTeams.sum(of: \Team.score))")
                        .font(.title)
                        .fontWeight(.bold)
                    if repTeams.sum(of: \Team.score) != 1 {
                        Text("points")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                    } else {
                        Text("point")
                            .multilineTextAlignment(.center)
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
