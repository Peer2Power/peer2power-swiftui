//
//  LogOutreachView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/18/22.
//

import Foundation
import SwiftUI
import UIKit
import ResearchKit
import RealmSwift

struct LogOutreachView: UIViewControllerRepresentable {
    @ObservedRealmObject var contact: Contact
    @ObservedRealmObject var team: Team
    
    @Environment(\.realm) var realm
    
    @Binding var showDidVolunteerBanner: Bool
    @Binding var showAttemptLoggedBanner: Bool
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = LogOutreachTask(identifier: String(describing: Identifier.logAttemptQuestionTask), steps: [LogOutreachTask.volunteerStatusStep])
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = context.coordinator
        
        return taskViewController
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        var parent: LogOutreachView
        let newOutreach = OutreachAttempt()
        
        init(_ parent: LogOutreachView) {
            self.parent = parent
        }
        
        func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .saved:
                print("Log attempt survey saved.")
            case .discarded:
                print("User discarded survey.")
            case .completed:
                print("Log attempt survey completed.")
                uploadResult(from: taskViewController)
            case .failed:
                print("Log attempt survey failed with the following error: \(String(describing: error?.localizedDescription))")
            @unknown default:
                print("Unknown")
            }
            
            taskViewController.dismiss(animated: true, completion: nil)
        }
        
        // FIXME: replace all these nested if statements with guard clauses to make this read more cleanly.
        private func getHowContactAnswer(_ taskViewController: ORKTaskViewController) -> String? {
            if let howContactStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.howContact)) {
                if let howContactFirstResult = howContactStepResult.firstResult as? ORKChoiceQuestionResult {
                    if let howContactFirstAnswer = howContactFirstResult.choiceAnswers?.first as? String {
                        return howContactFirstAnswer
                    }
                }
            }
            
            return nil
        }
        
        private func getDescribeAttemptAnswer(_ taskViewController: ORKTaskViewController) -> String? {
            if let describeAttemptStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.describeAttempt)) {
                if let describeAttemptFirstResult = describeAttemptStepResult.firstResult as? ORKTextQuestionResult {
                    if let describeAttemptAnswer = describeAttemptFirstResult.textAnswer {
                        return describeAttemptAnswer
                    }
                }
            }
            
            return nil
        }
        
        private func getGovtLevelAnswer(_ taskViewController: ORKTaskViewController) -> String? {
            guard let govtLevelStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.whichLevelQuestionStep)) else { return nil }
            guard let govtLevelFirstResult = govtLevelStepResult.firstResult as? ORKChoiceQuestionResult else { return nil }
            guard let govtLevelFirstAnswer = govtLevelFirstResult.choiceAnswers?.first as? String else { return nil }
            
            return govtLevelFirstAnswer
        }
        
        private func awardPointsForOutreachAttempt(team: Team, answer: String) {
            // TODO: add support for multipliers based on student population
            if answer == theyVolunteeredText {
                team.score += 7
                print("Awarded 7 points for logging this outreach attempt indicating that the contact volunteered.")
                
                parent.showDidVolunteerBanner.toggle()
            } else {
                team.score += 4
                print("Awarded 4 points for logging an outreach attempt.")
                
                parent.showAttemptLoggedBanner.toggle()
            }
        }
        
        private func uploadResult(from taskViewController: ORKTaskViewController) {
            guard let currentUser = app.currentUser else {
                print("The current user could not be found.")
                return
            }
            
            newOutreach.owner_id = currentUser.id
            newOutreach.to = parent.contact.contact_id
            
            let howContactAnswer = getHowContactAnswer(taskViewController)
            if let howContactAnswer = howContactAnswer {
                if !howContactAnswer.isEmpty {
                    newOutreach.contactMethod = howContactAnswer
                }
            }
                
            let attemptDescription = getDescribeAttemptAnswer(taskViewController)
            if let attemptDescription = attemptDescription {
                if !attemptDescription.isEmpty {
                    newOutreach.attemptDescription = attemptDescription
                }
            }
            
            if let govtLevelAnswer = getGovtLevelAnswer(taskViewController) {
                guard !govtLevelAnswer.isEmpty else { return }
                newOutreach.govtLevel = govtLevelAnswer
            }
            
            guard let volunteerStatusStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.volunteerStatus)) else {
                print("The volunteer status answer could not be found.")
                return
            }
            
            guard let volunteerStatusFirstResult = volunteerStatusStepResult.firstResult as? ORKChoiceQuestionResult else {
                print("The first result of the volunteer status step could not be found.")
                return
            }
            
            guard let volunteerStatusFirstAnswer = volunteerStatusFirstResult.choiceAnswers?.first as? String else {
                print("The answer to the volunteer status step could not be found.")
                return
            }
            
            newOutreach.volunteerStatus = volunteerStatusFirstAnswer
            
            // Very confused about how this works, but it somehow fixed the problem.
            guard let userTeam = parent.team.thaw() else {
                print("Could not thaw the user's team.")
                return
            }
            
            do {
                try parent.realm.write {
                    userTeam.outreachAttempts.append(newOutreach)
                    
                    print("Uploaded outreach attempt.")
                    
                    awardPointsForOutreachAttempt(team: userTeam, answer: volunteerStatusFirstAnswer)
                }
            } catch {
                print("Error uploading outreach attempt: \(error.localizedDescription)")
            }
        }
    }
}

struct LogOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        LogOutreachView(contact: Contact(), team: Team(), showDidVolunteerBanner: .constant(false), showAttemptLoggedBanner: .constant(false))
    }
}
