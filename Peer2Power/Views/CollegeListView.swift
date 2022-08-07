//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift

struct CollegeListView: View {
    @ObservedResults(college.self) var colleges
    
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
        }
    }
}

struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        CollegeListView()
    }
}
