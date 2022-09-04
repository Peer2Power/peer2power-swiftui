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
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = LogOutreachTask(identifier: String(describing: Identifier.logAttemptQuestionTask), steps: [LogOutreachTask.howContactStep(), LogOutreachTask.describeAttemptStep(), LogOutreachTask.volunteerStatusStep()])
        
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
        
        fileprivate func getHowContactAnswer(_ taskViewController: ORKTaskViewController) -> String? {
            if let howContactStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.howContact)) {
                if let howContactFirstResult = howContactStepResult.firstResult as? ORKChoiceQuestionResult {
                    if let howContactFirstAnswer = howContactFirstResult.choiceAnswers?.first as? String {
                        return howContactFirstAnswer
                    }
                }
            }
            
            return nil
        }
        
        fileprivate func getDescribeAttemptAnswer(_ taskViewController: ORKTaskViewController) -> String? {
            if let describeAttemptStepResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.describeAttempt)) {
                if let describeAttemptFirstResult = describeAttemptStepResult.firstResult as? ORKTextQuestionResult {
                    if let describeAttemptAnswer = describeAttemptFirstResult.textAnswer {
                        return describeAttemptAnswer
                    }
                }
            }
            
            return nil
        }
        
        private func uploadResult(from taskViewController: ORKTaskViewController) {
            guard let currentUser = app.currentUser else {
                print("The current user could not be found.")
                return
            }
            
            newOutreach.owner_id = currentUser.id
            newOutreach.to = parent.contact.contact_id
            
            if let howContactAnswer = getHowContactAnswer(taskViewController) {
                newOutreach.contactMethod = howContactAnswer
            }
            
            if let attemptDescription = getDescribeAttemptAnswer(taskViewController) {
                newOutreach.attemptDescription = attemptDescription
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
                }
            } catch {
                print("Error uploading outreach attempt: \(error.localizedDescription)")
            }
        }
    }
}

struct LogOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        LogOutreachView(contact: Contact(), team: Team())
    }
}
