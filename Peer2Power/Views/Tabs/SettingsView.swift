//
//  SettingsView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/31/22.
//

import SwiftUI
import RealmSwift
import AlertToast

struct SettingsView: View {
    @State private var showingLogOutAlert = false
    @State private var showingDeleteAccountAlert = false
    
    @State private var showingFAQView = false
    @State private var showingEndOfStudySurvey = false
    @State private var showingBanner = false
    
    @ObservedRealmObject var userTeam: Team
    @Environment(\.realm) private var realm
    
    @Binding var canUploadOrLog: Bool
    
    var body: some View {
        List {
            // TODO: revisit this to finalize the end-of-study survey.
            /* if !userTeam.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id).isEmpty {
                Section {
                    Button("Edit End of Study Survey Response") {
                        print("Something")
                    }
                    Button("Delete End of Study Survey Response", role: .destructive) {
                        print("Something")
                    }
                }
            } */
            Section {
                Button("FAQ") {
                    showingFAQView.toggle()
                }
                .sheet(isPresented: $showingFAQView) {
                    WebView(url: .constant(URL(string: "https://www.peer2power.org/faq")!))
                }
                Text("Questions or want to report a problem? Email lafayette@peer2power.org.")
            }
            if !canUploadOrLog && userTeam.endOfStudyResponses.where({ response in
                return response.owner_id == app.currentUser!.id
            }).isEmpty {
                Section {
                    Button("Fill Out End of Study Survey") {
                        showingEndOfStudySurvey.toggle()
                    }
                    .fullScreenCover(isPresented: $showingEndOfStudySurvey) {
                        EndOfStudySurveyView(team: userTeam, showResponseUploadedBanner: $showingBanner)
                            .ignoresSafeArea(.container, edges: .bottom)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
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
                .alert(Text("Are you sure you want to delete your account?"), isPresented: $showingDeleteAccountAlert, actions: {
                    Button("Cancel", role: .cancel, action: {})
                    Button("Delete Account", role: .destructive, action: deleteCurrentUser)
                }, message: {
                    Text("Deleting your account will delete any contacts or outreach attempts you uploaded and your team will lose the points it was awarded for these. Your team will also lose the point it was awarded when you joined it.")
                })
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
                
                for contact in team.contacts.filter("owner_id = %@", app.currentUser!.id) {
                    for outreachAttempt in team.outreachAttempts.filter("to = %@", contact.contact_id) {
                        let volunteerStatus = outreachAttempt.volunteerStatus
                        realm.delete(outreachAttempt)
                        
                        if volunteerStatus == theyVolunteeredText {
                            team.score -= 7
                            
                            print("Deleted an outreach attempt and subtracted seven points.")
                        } else {
                            team.score -= 4
                            
                            print("Deleted an outreach attempt and subtracted four points.")
                        }
                    }
                    
                    realm.delete(contact)
                    team.score -= 2

                    print("Deleted a contact and subtracted two points.")
                }
                
                for outreachAttempt in team.outreachAttempts.filter("owner_id = %@", app.currentUser!.id) {
                    let volunteerStatus = outreachAttempt.volunteerStatus
                    realm.delete(outreachAttempt)
                    
                    if volunteerStatus == theyVolunteeredText {
                        team.score -= 7
                        
                        print("Deleted an outreach attempt and subtracted seven points.")
                    } else {
                        team.score -= 4
                        
                        print("Deleted an outreach attempt and subtracted four points.")
                    }
                }
                
                for surveyResponse in team.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id) {
                    realm.delete(surveyResponse)
                    team.score -= 12
                    
                    print("Deleted an end-of-survey response and subtracted 12 points.")
                }
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
        SettingsView(userTeam: Team(), canUploadOrLog: .constant(true))
    }
}
