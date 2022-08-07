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
    
    @Environment(\.realm) var realm
    
    var body: some View {
        NavigationView {
            List {
                if colleges.isEmpty {
                    Text("No colleges could be found")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                
                ForEach(colleges) { college in
                    Text("\(college.name)")
                }
            }
        }.onAppear(perform: setSubscription)
    }
}

extension CollegeListView {
    private func setSubscription() {
        let subs = realm.subscriptions
        
        subs.update {
            if subs.first(named: "all_colleges") == nil {
                print("Appending new subscription to the College type...")
                subs.append(QuerySubscription<College>(name: "all_colleges"))
            } else {
                print("A subscription to the College type already exists.")
            }
        }
    }
}

struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        CollegeListView()
    }
}
