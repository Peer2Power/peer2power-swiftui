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
    @State private var showingConfirmAlert = false
    
    @State private var searchText = ""
    
    var searchResults: Results<College> {
        if searchText.isEmpty {
            return colleges
        }
        
        return colleges.where {
            $0.name.contains(searchText, options: .caseInsensitive)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(searchResults, id: \.self) { college in
                    NavigationLink {
                        List {
                            Button {
                                showingConfirmAlert.toggle()
                            } label: {
                                Text("Democratic").tag(Party.democrat)
                            }
                            .alert("Are You Sure You Want to Join This Team?", isPresented: $showingConfirmAlert) {
                                Button("Cancel", role: .cancel) {}
                                Button("Choose") {
                                    print("The user's team should be chosen here.")
                                }
                            } message: {
                                Text("You won't be able to change teams after confirming your choice.")
                            }

                            Button {
                                showingConfirmAlert.toggle()
                            } label: {
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
            .searchable(text: $searchText)
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
