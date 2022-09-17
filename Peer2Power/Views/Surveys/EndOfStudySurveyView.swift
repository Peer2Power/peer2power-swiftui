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
    @ObservedRealmObject var userTeam: Team
    
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = EndOfStudyTask(identifier: String(describing: Identifier.endOfStudyTask),
                                  steps: [EndOfStudyTask.knowContactsStep(contacts: userTeam.contacts), ORKFormStep(identifier: "hey"), ORKFormStep(identifier: "yo")])
        
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
                // TODO: upload results of survey to database.
                print("End of study survey completed.")
            case .failed:
                print("End of study survey failed.")
            @unknown default:
                print("Who knows what happened!")
            }
            
            taskViewController.dismiss(animated: true)
        }
    }
}
