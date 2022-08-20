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
    
    @ObservedResults(
        College.self,
        sortDescriptor: SortDescriptor(keyPath: "name", ascending: true))
    var colleges
    @ObservedResults(Team.self) var teams
    @ObservedResults(UserInfo.self) var userGoodies
    
    @State private var selectedParty: Party = .selectParty
    
    var body: some View {
        NavigationView {
            List {
                ForEach(colleges, id: \.self) { college in
                    NavigationLink {
                        List {
                            Picker("Select a Party", selection: $selectedParty) {
                                Text("Select Party").tag(Party.selectParty)
                                Text("Democratic").tag(Party.democrat)
                                Text("Republican").tag(Party.republican)
                            }
                        }
                    } label: {
                        Text("\(college.name)")
                    }
                }
            }
            .navigationBarTitle("Choose Your School")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/* extension CollegeListView {
    private func fetchTeam() -> Team? {
        let teamQuery = teams.where {
            ($0.school_id == selectedCollege._id.stringValue) && ($0.party == selectedParty)
        }
        
        return teamQuery.first
    }
    
    private func chooseTeam() {
        if let userInfo = userGoodies.first {
            print("A user's record exists.")
        } else {            
            print("Creating new user goody...")
            let newUserGoody = UserInfo()
            newUserGoody.owner_id = app.currentUser!.id
            
            if let userTeam = fetchTeam() {
                
            }
            
            let newTeam = Team()
            newTeam.school_id = selectedCollege._id.stringValue
            
            guard selectedParty != .selectParty else {
                print("This user has committed a great heresy.")
                return
            }
            
            newTeam.party = selectedParty
            
            $teams.append(newTeam)
            
            newUserGoody.team_id = newTeam._id.stringValue
            
            $userGoodies.append(newUserGoody)
            
            dismiss()
        }
        
       
    }
}
*/
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        CollegeListView()
    }
}
