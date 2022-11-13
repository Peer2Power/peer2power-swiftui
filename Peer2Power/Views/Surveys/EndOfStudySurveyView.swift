//
//  EndOfStudyView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import SwiftUI
import ResearchKit
import RealmSwift

struct EndOfStudySurveyView: UIViewControllerRepresentable {
    @ObservedRealmObject var team: Team
    
    @Environment(\.realm) var realm
    
    @Binding var showResponseUploadedBanner: Bool
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = EndOfStudyTask(identifier: String(describing: Identifier.endOfStudyTask),
                                  steps: [
                                    EndOfStudyTask.whoVolunteeredStep(team: team),
                                    EndOfStudyTask.futureRecruitmentLikelihoodStep(),
                                    EndOfStudyTask.completionStep()
                                  ])
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = context.coordinator
        
        return taskViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
        var parent: EndOfStudySurveyView
        
        let newResponse = EndOfStudyReponse()
        
        init(_ parent: EndOfStudySurveyView) {
            self.parent = parent
        }
                
        func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
            switch reason {
            case .saved:
                print("End of study survey saved.")
            case .discarded:
                print("End of study survey discarded.")
            case .completed:
                getResults(from: taskViewController)
                print("End of study survey completed.")
            case .failed:
                print("End of study survey failed.")
            @unknown default:
                print("Who knows what happened!")
            }
            
            taskViewController.dismiss(animated: true)
        }
        
        private func getResults(from taskViewController: ORKTaskViewController) {
            guard let currentUser = app.currentUser else { return }
            newResponse.owner_id = currentUser.id
            
            let selectedContacts = getVolunteeredContacts(taskViewController)
            newResponse.contact_ids.append(objectsIn: selectedContacts)
            print("The user said \(newResponse.contact_ids.count) contacts volunteered.")
            
            let futureRecruitmentLikelihood = getFutureRecruitmentLikelihood(taskViewController)
            if let futureRecruitmentLikelihood = futureRecruitmentLikelihood {
                newResponse.futureRecruitLikelihood = futureRecruitmentLikelihood
                print("The user indicated the likelihood they would recruit volunteers in the future as \(newResponse.futureRecruitLikelihood).")
            }
            
            uploadResults()
        }
        
        private func uploadResults() {
            guard let userTeam = parent.team.thaw() else { return }
            
            do {
                try parent.realm.write {
                    userTeam.endOfStudyResponses.append(newResponse)
                    
                    print("Uploaded end of study survey response.")
                    
                    awardPointsForSurveyResponse(team: userTeam)
                }
            } catch {
                print("Error uploading results: \(error.localizedDescription)")
            }
        }
        
        private func awardPointsForSurveyResponse(team: Team) {
            parent.showResponseUploadedBanner.toggle()
        }
        
        private func getVolunteeredContacts(_ taskViewController: ORKTaskViewController) -> [String] {
            var arr = [String]()
            
            let rawResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.whichVolunteeredStep))
            
            guard let selectionResult = rawResult?.firstResult as? ORKChoiceQuestionResult else { return arr }
            guard let selectedContacts = selectionResult.choiceAnswers else { return arr }
            
            for selectedContact in selectedContacts {
                guard let contact_id = selectedContact as? String else { return arr }
                
                arr.append(contact_id)
            }
            
            return arr
        }
        
        private func getFutureRecruitmentLikelihood(_ taskViewController: ORKTaskViewController) -> Int? {
            let rawResult = taskViewController.result.stepResult(forStepIdentifier: String(describing: Identifier.futureRecruitmentLikelihoodScaleStep))
            guard let rawResult = rawResult else { return nil }
            
            guard let scaleResult = rawResult.firstResult as? ORKScaleQuestionResult else { return nil }
            guard let likelihood = scaleResult.scaleAnswer else { return nil }
            
            return likelihood.intValue
        }
    }
}
