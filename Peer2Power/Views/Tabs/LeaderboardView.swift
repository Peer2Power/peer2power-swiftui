//
//  LeaderboardView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift

struct LeaderboardView: View {
    @ObservedResults(Team.self) var teams
    
    @State private var demPoints = ""
    @State private var repPoints = ""
    
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
                        Text("1,000,000")
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
                        Text("2")
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
        
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
