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
    @Environment (\.realm) var realm
    
    @ObservedResults(College.self) var colleges
    @ObservedResults(UserInfo.self) var userGoodies
    
    @State private var selectedCollege: College = College()
    @State private var userInfo = UserInfo()
    
    var body: some View {
        NavigationView {
            List {
                Picker("College", selection: $selectedCollege) {
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
                        userInfo.college_id = selectedCollege._id.stringValue
                        userInfo.owner_id = app.currentUser!.id
                        
                        $userGoodies.append(userInfo)
                        
                        dismiss()
                    } label: {
                        Text("Choose")
                    }
                }
            }
        }
        .onAppear(perform: setSubscription)
    }
}

extension CollegeListView {
    private func setSubscription() {
        let subs = realm.subscriptions
        if subs.first(named: "user_info") == nil {
            subs.update {
                subs.append(QuerySubscription<UserInfo>(name: "user_info") { info in
                    info.owner_id == app.currentUser!.id
                })
            }
        } else {
            print("A subscription to the UserInfo type already exists.")
        }
    }
}

struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        CollegeListView()
    }
}
