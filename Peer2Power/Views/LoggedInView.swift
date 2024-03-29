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
    
    @State private var showingFatalErrorAlert = false
    
    @State private var canUploadOrLog = true
    
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
                    HomeView(canUploadContacts: $canUploadOrLog, isPastCompDate: .constant(pastSurveyCloseDate), userTeam: teams.first!)
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
                    SettingsView(userTeam: teams.first!, canUploadOrLog: $canUploadOrLog)
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle("Settings")
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
            .alert("Major Error", isPresented: $showingFatalErrorAlert, actions: {
                Button("OK", role: .cancel, action: {})
            }, message: {
                Text("A major error has occurred. Please force quit the app and reopen it.")
            })
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    checkEndOfStudyAvailability()
                }
            }
            .onAppear {
                checkEndOfStudyAvailability()
                addSyncErrorHandler()
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
        guard pastSurveyOpenDate else { return }
        
        canUploadOrLog = false
    }
    
    private var pastSurveyOpenDate: Bool {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        guard let surveyOpenDate = remoteConfig["endOfStudySurveyAvailableDate"].stringValue else { return false }
        print("Got end of study available date \(surveyOpenDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        
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
        print("Got end of study close date \(surveyCloseDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "EDT")
        
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
