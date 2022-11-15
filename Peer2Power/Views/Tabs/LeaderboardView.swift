//
//  LeaderboardView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift
import Charts

struct LeaderboardView: View {
    @ObservedResults(Team.self,
                     where: {$0.party == .democrat})
    var demTeams
    
    @ObservedResults(Team.self,
                     where: {$0.party == .republican})
    var repTeams
    
    @ObservedRealmObject var userTeam: Team
    
    var body: some View {
        VStack(alignment: .center, spacing: 15.0) {
            VStack(alignment: .center, spacing: 5) {
                Text("Your team,")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.25)
                Text("the \(userTeam.school_name) \(userTeam.party.rawValue),")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .minimumScaleFactor(0.25)
                Text("has earned")
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .minimumScaleFactor(0.25)
                Text("\(userTeam.score)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                if userTeam.score != 1 {
                    Text("points for the \(userTeam.party.rawValue).")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.25)
                } else {
                    Text("point for the \(userTeam.party.rawValue).")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.25)
                }
            }
            .padding(.horizontal, 15)
            Divider()
            if #available(iOS 16.0, *) {
                Chart {
                    BarMark(
                        x: .value("Party", "Democrats"),
                        y: .value("Total Score", demTeams.sum(of: \Team.score))
                    )
                    .foregroundStyle(Color("DemsColor"))
                    .annotation(position: .overlay, alignment: .center, spacing: nil) {
                        if demTeams.sum(of: \Team.score) > 0 {
                            VStack(alignment: .center) {
                                Image("Democrats")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                Text("\(demTeams.sum(of: \Team.score))")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            .padding(.horizontal, 15.0)
                        }
                    }
                    BarMark(
                        x: .value("Party", "Republicans"),
                        y: .value("Total Score", repTeams.sum(of: \Team.score))
                    )
                    .foregroundStyle(Color("GOPColor"))
                    .annotation(position: .overlay, alignment: .center, spacing: nil) {
                        if repTeams.sum(of: \Team.score) > 0 {
                            VStack(alignment: .center) {
                                Image("Republicans")
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                                Text("\(repTeams.sum(of: \Team.score))")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                            .padding(.horizontal, 15.0)
                        }
                    }
                }
                .chartXScale(type: .category)
                .chartYScale(domain: 0...demTeams.sum(of: \Team.score) + repTeams.sum(of: \Team.score))
            } else {
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
        }
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
