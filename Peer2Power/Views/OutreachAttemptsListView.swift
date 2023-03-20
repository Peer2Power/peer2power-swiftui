//
//  OutreachAttemptsListView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/25/22.
//

import SwiftUI
import RealmSwift
import AlertToast
import FirebaseRemoteConfig

struct OutreachAttemptsListView: View {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    @State private var presentingLogOutreachForm = false
    @State private var presentingEditContactInfoForm = false
    
    @State private var showingDeleteAttemptAlert = false
    @State private var offsetsToDelete: IndexSet?
    
    @State private var showingAttemptLoggedBanner = false
    @State private var showingDidVolunteerBanner = false
    
    @State private var showingOutreachSteps = false
    
    private let imageNames = ["OutreachStep1", "OutreachStep2", "OutreachStep3"]
    
    @Environment(\.realm) var realm
    
    var body: some View {
        if team.outreachAttempts.filter("to = %@", contact.contact_id).isEmpty && team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue).isEmpty {
            VStack(spacing: 10.0) {
                Text("No Outreach Attempts Logged")
                    .font(.title)
                    .multilineTextAlignment(.center)
                Text("Your team hasn't logged any attempts to get this contact to email a representative yet. Talk to them using your contact method of choice, then return here to tell us about how the interaction went.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                TabView {
                    ForEach(imageNames, id: \.self) { name in
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .padding(.horizontal, 15.0)
            .navigationTitle(contact.name)
            .navigationBarTitleDisplayMode(.inline)
        } else {
            VStack {
                if !team.outreachAttempts.filter("to = %@", contact.contact_id).isEmpty {
                    List {
                        ForEach(team.outreachAttempts.filter("to = %@", contact.contact_id).sorted(by: \OutreachAttempt.createdAt, ascending: false)) { attempt in
                            OutreachListRow(attempt: attempt)
                        }
                        .onDelete { offsets in
                            offsetsToDelete = offsets
                            showingDeleteAttemptAlert.toggle()
                        }
                    }
                    .navigationTitle(contact.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .alert("Are you sure you want to delete this outreach attempt?", isPresented: $showingDeleteAttemptAlert) {
                        Button("Cancel", role: .cancel, action: {})
                        Button("Delete", role: .destructive, action: deleteOutreachAttempt)
                    } message: {
                        Text("Your team will lose the points it gained for logging this outreach attempt.")
                    }
                    .toolbar {
                        EditButton()
                    }
                    .toast(isPresenting: $showingAttemptLoggedBanner, duration: 4.0) {
                        AlertToast(displayMode: .banner(.pop),
                                   type: .complete(Color(.systemGreen)),
                                   title: "Outreach Attempt Logged!",
                                   subTitle: "Your team received 4 points!")
                    }
                    .onChange(of: showingAttemptLoggedBanner, perform: { newValue in
                        guard newValue == true else { return }
                        
                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.getPendingNotificationRequests { requests in
                            if requests.contains(where: { request in
                                return request.identifier == outreachAttemptNotifIdentifier
                            }) {
                                removeOutreachAttemptReminderNotification()
                            }
                        }
                    })
                    .toast(isPresenting: $showingDidVolunteerBanner, duration: 4.0) {
                        AlertToast(displayMode: .banner(.pop),
                                   type: .complete(Color(.systemGreen)),
                                   title: "Outreach Attempt Logged!",
                                   subTitle: "Your team received 7 points!")
                    }
                    Button("Show Outreach Steps") {
                        showingOutreachSteps.toggle()
                    }
                    .sheet(isPresented: $showingOutreachSteps) {
                        if #available(iOS 16.0, *) {
                            TabView {
                                ForEach(imageNames, id: \.self) { name in
                                    Image(name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                            .presentationDetents([.medium, .large])
                        } else {
                            // Fallback on earlier versions
                            
                            TabView {
                                ForEach(imageNames, id: \.self) { name in
                                    Image(name)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .tabViewStyle(.page)
                            .indexViewStyle(.page(backgroundDisplayMode: .always))
                        }
                    }
                }
            }
        }
        Button {
            presentingLogOutreachForm.toggle()
        } label: {
            Label("Log Outreach Attempt", systemImage: "square.and.pencil")
        }
        .disabled(isPastCompDate)
        .buttonStyle(.borderedProminent)
        .fullScreenCover(isPresented: $presentingLogOutreachForm) {
            LogOutreachView(contact: contact, team: team, showDidVolunteerBanner: $showingDidVolunteerBanner, showAttemptLoggedBanner: $showingAttemptLoggedBanner)
                .ignoresSafeArea(.container, edges: .bottom)
                .ignoresSafeArea(.container, edges: .top)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

extension OutreachAttemptsListView {
    private func deleteOutreachAttempt() {
        guard let team = team.thaw() else { return }
        guard let offsets = offsetsToDelete else { return }
        // TODO: get the outreach attempt by figuring out its index using the provided IndexSet.
        
        let filteredAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
        guard !filteredAttempts.isEmpty else { return }
        
        do {
            try realm.write {
                offsets.forEach { i in
                    let attemptToDelete = filteredAttempts[i]
                    let volunteeredAttempt = attemptToDelete.volunteerStatus == theyVolunteeredText
                    
                    realm.delete(attemptToDelete)
                    
                    if volunteeredAttempt {
                        guard team.score > 0 else { return }
                        
                        team.score -= 7
                    } else {
                        guard team.score > 0 else { return }
                        
                        team.score -= 4
                    }
                }
                // TODO: remove 8 points for attempts that triggered the multiplier
            }
        } catch {
            print("Error deleting outreach attempt: \(error.localizedDescription)")
        }
    }
    
    private func removeOutreachAttemptReminderNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [outreachAttemptNotifIdentifier])
        
        print("Removed outreach attempt reminder notification.")
    }
    
    private var isPastCompDate: Bool {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        Task {
            do {
                let status = try await remoteConfig.fetchAndActivate()
                
                if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                    guard let fetchedDate = remoteConfig["endOfStudySurveyAvailableDate"].stringValue else { return false }
                    print("Got end of study date \(fetchedDate)")
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                    dateFormatter.timeZone = TimeZone(abbreviation: "EST")
                    
                    guard let date = dateFormatter.date(from: fetchedDate) else { return false }
                    let compareResult = Date().compare(date)
                    
                    return compareResult == .orderedSame || compareResult == .orderedDescending
                }
            } catch {
                print("Error fetching from remote config: \(error.localizedDescription)")
                return false
            }
            
            return false
        }
        
        return false
    }
}
