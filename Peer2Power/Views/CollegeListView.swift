//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift

struct CollegeListView: View {
    @ObservedResults(College.self) var colleges
    
    @State private var selectedCollege: College = College()
    @State private var selectedParty: Party = .democrat
    
    var body: some View {
        NavigationView {
            List {
                Picker("College", selection: $selectedCollege) {
                    ForEach(colleges, id: \.self) { college in
                        Text("\(college.name)")
                    }
                }
                Picker("Party", selection: $selectedParty) {
                    Text("Democratic").tag(Party.democrat)
                    Text("Republican").tag(Party.republican)
                }
            }
        }
    }
}

struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        CollegeListView()
    }
}
