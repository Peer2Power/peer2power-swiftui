//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift

struct CollegeListView: View {
    @Environment (\.dismiss) var dismiss
    
    @ObservedResults(College.self) var colleges
    @ObservedResults(UserInfo.self) var userGoodies
    
    @State private var userInfo = UserInfo()
    
    var body: some View {
        NavigationView {
            List {
                Picker("College", selection: $userInfo.college) {
                    ForEach(colleges, id: \.self) { college in
                        Text("\(college.name)")
                    }
                }
                Picker("Party", selection: $userInfo.party) {
                    Text("Democratic").tag(Party.democrat)
                    Text("Republican").tag(Party.republican)
                }
            }
            .navigationBarTitle("Choose a Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        $userGoodies.append(userInfo)
                        dismiss()
                    } label: {
                        Text("Choose")
                    }
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
