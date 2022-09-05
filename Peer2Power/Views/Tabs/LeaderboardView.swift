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
    
    @State private var demPointsText = ""
    @State private var repPointsText = ""
    
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
                        Text(demPointsText)
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
                        Text(repPointsText)
                            .font(.title)
                            .fontWeight(.bold)
                        Text("points")
                    }
                }
        }
        .padding([.leading, .trailing], 15.0)
        .onAppear(perform: populatePointLabels)
    }
}

extension LeaderboardView {
    private func populatePointLabels() {
        demPointsText = "\(demTeams.sum(of: \Team.score))"
        repPointsText = "\(repTeams.sum(of: \Team.score))"
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
