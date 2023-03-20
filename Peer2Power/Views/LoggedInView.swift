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
    @Environment(\.scenePhase) var scenePhase
    
    @State private var showingSurveyAlert = false
    @State private var showingEndOfStudySurvey = false
    @State private var showingConfirmDontShowAlert = false
    @State private var showingSurveyResponseUploadedBanner = false
    @State private var showingFatalErrorAlert = false
    
    let reminderNotificationIdentifier = "uploadReminder"
    
    @ObservedResults(Team.self,
                     where: {$0.member_ids.contains(app.currentUser!.id)})
    var teams
    
    var daysBeforeReminding: Double = 1
    
    var body: some View {
        if teams.isEmpty {
            NavigationView {
                ClubsListView()
                    .navigationTitle(app.currentUser == nil ? "Sign Up" : "Choose a Club Team")
                    .navigationViewStyle(StackNavigationViewStyle())
            }
        } else {
            TabView {
                NavigationView {
                    HomeView(userTeam: teams.first!)                        
                }
                .tabItem {
                    Label("Contacts", systemImage: "person.3.sequence")
                }
                NavigationView {
                    LeaderboardView()
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle("Leaderboard")
                }
                .tabItem {
                    Label("Leaderboard", systemImage: "list.number")
                }
                NavigationView {
                    SettingsView(userTeam: teams.first!)
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle("Settings")
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .alert("Are you ready to complete the Peer2Power competition?", isPresented: $showingSurveyAlert) {
                Button("I'm Ready", action: showSurveyIfAllowed)
                Button("Maybe Later", action: setShowLater)
                Button("Don't Ask Again", role: .cancel) {
                    showingConfirmDontShowAlert.toggle()
                }
            } message: {
                Text("The election is over! To score your final points, we need you to let us know how many of your friends and family actually volunteered for a Georgia runoff campaign!")
            }
            .alert("Are you sure you want to quit the competition?", isPresented: $showingConfirmDontShowAlert, actions: {
                Button("No, I'd Like to Fill Out the Survey", action: showSurveyIfAllowed)
                Button("No, Show Me This Again Later", action: setShowLater)
                Button("Yes, Never Ask Me Again", role: .cancel, action: neverShowEndOfStudySurvey)
            }, message: {
                Text("Failing to complete the end-of-study survey means your team will miss an opportunity to gain a significant number of points.")
            })
            .fullScreenCover(isPresented: $showingEndOfStudySurvey) {
                EndOfStudySurveyView(team: teams.first!, showResponseUploadedBanner: $showingSurveyResponseUploadedBanner)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .ignoresSafeArea(.container, edges: .top)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .alert("Major Error", isPresented: $showingFatalErrorAlert, actions: {
                Button("OK", role: .cancel, action: {})
            }, message: {
                Text("A major error has occurred. Please force quit the app and reopen it.")
            })
            .toast(isPresenting: $showingSurveyResponseUploadedBanner, duration: 4) {
                AlertToast(displayMode: .banner(.pop), type: .complete(Color(.systemGreen)), title: "Response Uploaded!", subTitle: "Your team received 12 points!")
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    checkEndOfStudyAvailability()
                    scheduleReminderNotification()
                }
            }
            .onAppear {
                checkEndOfStudyAvailability()
                addSyncErrorHandler()
                scheduleReminderNotification()
            }
        }
    }
}

extension LoggedInView {
    private func checkEndOfStudyAvailability() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                handleFetchedDate()
            }
        }
    }
    
    private func handleFetchedDate() {
        let hasDeclinedSurvey = UserDefaults.standard.bool(forKey: "declinedEndOfStudySurvey")
        guard !hasDeclinedSurvey else { return }
        
        guard pastSurveyOpenDate else { return }
        guard !pastSurveyCloseDate else { return }
        
        showPromptIfAllowed()
    }
    
    private func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder to Upload Contacts!"
        content.body = "Remember to upload some contacts you want to encourage to email their elected representatives!"
        
        var dateComponents = DateComponents()
        dateComponents.calendar = .current
        dateComponents.weekday = 4 // Wednesday
        dateComponents.hour = 12 // 12:00 hours
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: reminderNotificationIdentifier, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { requests in
            if !requests.contains(where: { request in
                return request.identifier == reminderNotificationIdentifier
            }) {
                print("Adding scheduled reminder notification...")
                notificationCenter.add(request) { error in
                    guard error == nil else {
                        print("Error scheduling reminder notification: \(error?.localizedDescription)")
                        return
                    }
                    
                    print("Scheduled reminder notification.")
                }
            }
        }
    }
    
    private func showPromptIfAllowed() {
        guard pastRemindLaterDate else { return }
    
        guard let team = teams.first else { return }
        guard team.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id).isEmpty else { return }
        
        showingSurveyAlert.toggle()
    }
    
    private func showSurveyIfAllowed() {
        guard let team = teams.first else { return }
        guard team.endOfStudyResponses.filter("owner_id = %@", app.currentUser!.id).isEmpty else { return }
        
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
    
    private var pastSurveyOpenDate: Bool {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        guard let surveyOpenDate = remoteConfig["endOfStudySurveyAvailableDate"].stringValue else { return false }
        print("Got end of study date \(surveyOpenDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        
        guard let date = dateFormatter.date(from: surveyOpenDate) else { return false }
        let compareResult = Date().compare(date)
        
        return compareResult == .orderedSame || compareResult == .orderedDescending
    }
    
    private var pastRemindLaterDate: Bool {
        let defaults = UserDefaults.standard
        
        guard let remindLaterDate = defaults.object(forKey: "remindLaterPressedDate") as? Date else { return true }
        let timeInterval = Date().timeIntervalSince(remindLaterDate)
        let remindLaterDaysCount = ((timeInterval / 3600) / 24)
        
        return remindLaterDaysCount >= daysBeforeReminding
    }
    
    private var pastSurveyCloseDate: Bool {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        guard let surveyCloseDate = remoteConfig["endOfStudySurveyCloseDate"].stringValue else { return false }
        print("Got end of study date \(surveyCloseDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EST")
        
        guard let date = dateFormatter.date(from: surveyCloseDate) else { return false }
        let compareResult = Date().compare(date)
        
        return compareResult == .orderedSame || compareResult == .orderedDescending
    }
    
    private func addSyncErrorHandler() {
        guard app.syncManager.errorHandler == nil else { return }
        
        app.syncManager.errorHandler = { error, session in
            guard let syncError = error as? SyncError else {
                print("Unexpected error type passed to sync error handler! \(error)")
                return
            }
            switch syncError.code {
            case .clientResetError:
                if let (path, clientResetToken) = syncError.clientResetInfo() {
                    handleClientReset()
                    SyncSession.immediatelyHandleError(clientResetToken, syncManager: app.syncManager)
                }
            case .clientSessionError:
                print("Client session error.")
            case .clientUserError:
                print("Client user error.")
            case .clientInternalError:
                print("Client internal error.")
            case .underlyingAuthError:
                print("Underlying auth error.")
            case .permissionDeniedError:
                print("Permission denied error.")
            case .writeRejected:
                print("Write rejected.")
            @unknown default:
                print("Unknown error.")
            }
        }
    }
    
    private func handleClientReset() {
        showingFatalErrorAlert.toggle()
    }
}

struct LoggedInView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInView()
    }
}
