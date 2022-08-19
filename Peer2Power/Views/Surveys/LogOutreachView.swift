//
//  LogOutreachView.swift
//  Peer2Power
//
//  Created by Deja Jackson on 8/18/22.
//

import SwiftUI
import UIKit
import ResearchKit

struct LogOutreachView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ORKTaskViewController {
        let task = LogOutreachTask(identifier: String(describing: Identifier.logAttemptQuestionTask), steps: [LogOutreachTask.howContactStep(), LogOutreachTask.volunteerInterestStep(), LogOutreachTask.volunteerStatusStep()])
        
        let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
        
        return taskViewController
    }
    
    func updateUIViewController(_ uiViewController: ORKTaskViewController, context: Context) {
        
    }
}

struct LogOutreachView_Previews: PreviewProvider {
    static var previews: some View {
        LogOutreachView()
    }
}
