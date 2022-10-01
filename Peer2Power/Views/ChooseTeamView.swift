//
//  CollegeListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/6/22.
//

import SwiftUI
import RealmSwift

struct ChooseTeamView: View {
    @ObservedResults(Team.self) var teams
    
    @State private var selectedParty: Party = .selectParty
    @State private var showingConfirmAlert = false
    @State private var showingDidSignUpAlert = false
    
    @State private var searchText = ""
    
    @Environment(\.realm) private var realm
    @Environment(\.dismiss) private var dismiss
    
    var searchResults: Results<Team> {
        if searchText.isEmpty {
            return teams.sorted(by: \Team.school_name, ascending: true).distinct(by: [\Team.school_name])
        }
        
        return teams.where {
            $0.school_name.contains(searchText, options: .caseInsensitive)
        }.distinct(by: [\Team.school_name]).sorted(by: \Team.school_name, ascending: true)
    }
    
    var body: some View {
        List {
            ForEach(searchResults.distinct(by: [\Team.state]).sorted(by: \Team.state, ascending: true), id: \.self) { stateTeam in
                Section {
                    ForEach(searchResults.filter("state = %@", stateTeam.state)) { team in
                        NavigationLink {
                            List {
                                Picker("Party", selection: $selectedParty) {
                                    ForEach(Party.allCases, id: \.self) { party in
                                        Text(party.rawValue).tag(party)
                                    }
                                }
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button("Choose") {
                                            showingConfirmAlert.toggle()
                                        }
                                        .disabled(selectedParty == .selectParty)
                                        .alert("Are you sure you want to join this team?", isPresented: $showingConfirmAlert) {
                                            Button(role: .cancel, action: {}) {
                                                Text("Cancel")
                                            }
                                            Button("Choose") {
                                                handleTeamSelection(for: team.school_name)
                                            }
                                        } message: {
                                            Text("You won't be able to change your team after joining.")
                                        }
                                    }
                                }
                            }
                            .navigationBarTitle("Choose Your Party")
                        } label: {
                            Text("\(team.school_name)")
                        }
                    }
                } header: {
                    Text("\(stateTeam.state)")
                }
            }
        }
        .navigationTitle("Choose Your School")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Enter the name of your school")
        .listStyle(.insetGrouped)
        .onChange(of: showingDidSignUpAlert) { newValue in
            if newValue == true {
                dismiss()
            }
        }
        /*
        .SPAlert(isPresent: $showingDidSignUpAlert,
                 title: "Points Received!",
                 message: "Your team received 1 point because you signed up!",
                 preset: .custom(UIImage(systemName: "plus.circle")!),
                 haptic: .success)
         */
    }
}

extension ChooseTeamView {
    private func handleTeamSelection(for schoolName: String) {
        let filteredTeams = teams.where {
            $0.party == selectedParty && $0.school_name == schoolName
        }
        
        guard !filteredTeams.isEmpty else { return }
        
        guard let currentUser = app.currentUser else { return }

        print("A team already exists for this school and party.")
        
        guard let team = filteredTeams.first?.thaw() else { return }
        
        do {
            try realm.write {
                team.member_ids.append(currentUser.id)
                team.score += 1
                
                print("The current user was added to an existing team.")
                showingDidSignUpAlert.toggle()
            }
        } catch {
            print("Error adding user to team: \(error.localizedDescription)")
        }
    }
}
 
struct CollegeListView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseTeamView()
    }
}
