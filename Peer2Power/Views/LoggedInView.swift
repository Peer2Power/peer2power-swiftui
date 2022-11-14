//
//  LoggedInView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/3/22.
//

import SwiftUI
import RealmSwift
import FirebaseRemoteConfig
import AlertToast

struct LoggedInView: View {
    @State private var showingSurveyAlert = false
    @State private var showingEndOfStudySurvey = false
    @State private var showingSurveyResponseUploadedBanner = false
    
    @ObservedResults(Team.self,
                     where: {$0.member_ids.contains(app.currentUser!.id)})
    var teams
    
    var daysBeforeReminding: Double = 1
    
    var body: some View {
        if teams.isEmpty {
            NavigationView {
                SchoolsListView()
            }
        } else {
            TabView {
                HomeView(userTeam: teams.first!)
                    .tabItem {
                        Label("Contacts", systemImage: "person.3.sequence")
                    }
                LeaderboardView(userTeam: teams.first!)
                    .tabItem {
                        Label("Leaderboard", systemImage: "chart.bar")
                    }
                NavigationView {
                    SettingsView(userTeam: teams.first!)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .alert("Are you ready to complete the Peer2Power competition?", isPresented: $showingSurveyAlert) {
                Button("I'm Ready", action: showSurveyIfAllowed)
                Button("Maybe Later", action: setShowLater)
                Button("Don't Ask Again", role: .cancel, action: neverShowEndOfStudySurvey)
            } message: {
                Text("The election is over! To score your final points, we need you to let us know how many of your friends and family actually volunteered for a Georgia runoff campaign!")
            }
            .sheet(isPresented: $showingEndOfStudySurvey) {
                EndOfStudySurveyView(team: teams.first!, showResponseUploadedBanner: $showingSurveyResponseUploadedBanner)
                    .interactiveDismissDisabled(true)
            }
            .onAppear(perform: checkEndOfStudyAvailability)
            .toast(isPresenting: $showingSurveyResponseUploadedBanner, duration: 4) {
                AlertToast(displayMode: .banner(.pop), type: .complete(Color(uiColor: .systemGreen)), title: "Response Uploaded!", subTitle: "Your team received 12 points!")
            }
        }
    }
}

extension LoggedInView {
    private func checkEndOfStudyAvailability() {
        /* let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                handleFetchedDate()
            }
        } */
        showingSurveyAlert.toggle()
    }
    
    private func handleFetchedDate() {
        let hasDeclinedSurvey = UserDefaults.standard.bool(forKey: "declinedEndOfStudySurvey")
        guard !hasDeclinedSurvey else { return }
        
        let remoteConfig = RemoteConfig.remoteConfig()
        
        guard let fetchedDate = remoteConfig["endOfStudySurveyAvailableDate"].stringValue else { return }
        print("Got end of study date \(fetchedDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        
        guard let date = dateFormatter.date(from: fetchedDate) else { return }
        let compareResult = Date().compare(date)
        
        if compareResult == .orderedSame || compareResult == .orderedDescending {
            showPromptIfAllowed()
        }
    }
    
    private func showPromptIfAllowed() {
        let defaults = UserDefaults.standard
        
        guard let remindLaterDate = defaults.object(forKey: "remindLaterPressedDate") as? Date else { return }
        let timeInterval = Date().timeIntervalSince(remindLaterDate)
        let remindLaterDaysCount = ((timeInterval / 3600) / 24)
        
        guard remindLaterDaysCount >= daysBeforeReminding else { return }
    
        guard let team = teams.first else { return }
        guard team.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id).isEmpty else { return }
        
        showingSurveyAlert.toggle()
    }
    
    private func showSurveyIfAllowed() {
        guard let team = teams.first else { return }
        // guard team.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id).isEmpty else { return }
        
        showingEndOfStudySurvey.toggle()
    }
    
    private func neverShowEndOfStudySurvey() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "declinedEndOfStudySurvey")
    }
    
    private func setShowLater() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: "remindLaterPressedDate")
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
