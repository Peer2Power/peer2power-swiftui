//
//  SettingsView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift

struct SettingsView: View {
    @State private var showingLogOutAlert = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingEndOfStudySurvey = false
    
    @ObservedRealmObject var userTeam: Team
    @Environment(\.realm) private var realm
    
    var body: some View {
        List {
            // TODO: revisit this to finalize the end-of-study survey.
            /*
            Section {
                Button("Show End Of Study Survey") {
                    showingEndOfStudySurvey.toggle()
                }
                .sheet(isPresented: $showingEndOfStudySurvey) {
                    EndOfStudySurveyView(userTeam: userTeam)
                }
            }
             */
            Section {
                NavigationLink {
                    AcknowledgementsView()
                } label: {
                    Button("Open Source Licenses", action: {})
                }
            }
            Section {
                Button("Log Out", role: .destructive) {
                    showingLogOutAlert.toggle()
                }
                .alert(Text("Are you sure you want to log out?"), isPresented: $showingLogOutAlert) {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Log Out", role: .destructive) {
                        app.currentUser!.logOut(completion: { error in
                            if let error = error {
                                print("An error occured while logging out: \(error.localizedDescription)")
                            }
                            
                            print("Current user logged out successfully.")
                        })
                    }
                }
                Button("Delete Account", role: .destructive) {
                    showingDeleteAccountAlert.toggle()
                }
                .alert(Text("Are you sure you want to delete your account?"), isPresented: $showingDeleteAccountAlert) {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Delete Account", role: .destructive, action: deleteCurrentUser)
                }
            }
        }
    }
}

extension SettingsView {
    private func deleteCurrentUser() {
        guard let team = userTeam.thaw() else { return }
        guard let currentUserIDIndex = team.member_ids.firstIndex(of: app.currentUser!.id) else { return }
        
        do {
            try realm.write {
                team.member_ids.remove(at: currentUserIDIndex)
                print("Removed the current user's ID from this team.")
                
                guard team.score > 0 else { return }
                team.score -= 1
                print("Subtracted a point from this team's score.")
            }
        } catch {
            print("Error removing current user from team: \(error.localizedDescription)")
            return
        }
        
        app.currentUser!.delete { logOutError in
            if let logOutError = logOutError {
                print("An error occurred while logging out: \(logOutError.localizedDescription)")
                
                do {
                    try realm.write {
                        team.member_ids.append(app.currentUser!.id)
                        team.score += 1
                    }
                } catch {
                    print("This situation is truly hopeless for the following reason: \(error.localizedDescription)")
                }
            }
            
            print("Current user deleted successfully.")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userTeam: Team())
    }
}
