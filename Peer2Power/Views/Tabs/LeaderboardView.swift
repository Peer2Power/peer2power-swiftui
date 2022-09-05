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
    
    var body: some View {
        HStack {
            Image("Democrats")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.2)
                .overlay(alignment: .center) {
                    VStack {
                        Text("Democrats have")
                            .multilineTextAlignment(.center)
                        Text("\(demTeams.sum(of: \Team.score))")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("points")
                            .multilineTextAlignment(.center)
                    }
                }
            Image("Republicans")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.2)
                .overlay(alignment: .leading) {
                    VStack {
                        Text("Republicans have")
                        Text("\(repTeams.sum(of: \Team.score))")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("points")
                    }
                }
        }
        .padding([.leading, .trailing], 15.0)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
