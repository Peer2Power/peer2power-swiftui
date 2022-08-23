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

struct LogOutreachView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = LogOutreachTask(identifier: String(describing: Identifier.logAttemptQuestionTask), steps: [LogOutreachTask.howContactStep(), LogOutreachTask.volunteerInterestStep(), LogOutreachTask.volunteerStatusStep()])
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        taskViewController.delegate = context.coordinator
        
        return taskViewController
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject, ORKTaskViewControllerDelegate {
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
        
        private func uploadResult(from taskViewController: ORKTaskViewController) {
            let newOutreach = OutreachAttempt()
            
            guard let currentUser = app.currentUser else {
                print("The current user could not be found.")
                return
            }
            
            // TODO: add this to the contact list view or have some other way to select which contact the outreach attempt was made to.
        }
    }
}

struct LogOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        LogOutreachView()
    }
}
