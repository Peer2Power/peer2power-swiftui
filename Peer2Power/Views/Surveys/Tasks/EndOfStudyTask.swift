//
//  EndOfStudyTask.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import ResearchKit
import RealmSwift

class EndOfStudyTask: ORKOrderedTask {
    static func whoVolunteeredStep(team: Team) -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.whichVolunteeredStep),
                                   title: nil,
                                   question: "Please talk to these contacts and confirm whether they volunteered.",
                                   answer: nil)
        var textChoices = [ORKTextChoice]()
        
        for contact in team.contacts {
            let filteredOutreachAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
                .filter("volunteerStatus = %@", "I have confirmed that they volunteered.")
            
            if filteredOutreachAttempts.isEmpty {
                let textChoice = ORKTextChoice(text: contact.name, value: contact.name as NSCoding & NSCopying & NSObjectProtocol)
                textChoices.append(textChoice)
            }
        }
        
        let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
        step.answerFormat = answerFormat
        
        step.isOptional = false
        
        return step
    }
    
    static func futureRecruitmentLikelihoodStep() -> ORKQuestionStep {
        let answerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 100.0, minimumValue: 0.0, defaultValue: 99.0, maximumFractionDigits: 0, vertical: false, maximumValueDescription: "Very likely", minimumValueDescription: "Not at all likely")
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.futureRecruitmentLikelihoodScaleStep),
                                   title: nil,
                                   question: "How likely are you to recruit volunteers in the future?",
                                   answer: answerFormat)
        
        return step
    }
    
    static func completionStep() -> ORKCompletionStep {
        let step = ORKCompletionStep(identifier: String(describing: Identifier.endOfStudyCompletionStep))
        
        step.title = "Thank you for completing this survey!"
        step.detailText = "Thank you for participating in the political process and encouraging others to do so! We hope you keep up the good work!"
        
        return step
    }
}
