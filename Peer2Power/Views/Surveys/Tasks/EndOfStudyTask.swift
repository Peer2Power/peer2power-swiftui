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
                                   question: "Below is a list of contacts that your team did not mark as confirmed volunteers. \n\nPlease follow up with anyone on the list that you know. \n\nDid anyone on this list confirm that they volunteered for a Georgia runoff campaign?",
                                   answer: nil)
        var textChoices = [ORKTextChoice]()
        
        for contact in team.contacts {
            let filteredOutreachAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
                .filter("volunteerStatus = %@", "I have confirmed that they volunteered.")
            let filteredResponses = team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue)
            
            if filteredOutreachAttempts.isEmpty && filteredResponses.isEmpty {
                let textChoice = ORKTextChoice(text: contact.name, value: contact.contact_id.stringValue as NSCoding & NSCopying & NSObjectProtocol)
                textChoices.append(textChoice)
            }
        }
        
        let noneTextChoice = ORKTextChoice(text: "None of the contacts I know volunteered.", value: "None of the contacts I know volunteered." as NSCoding & NSCopying & NSObjectProtocol)
        textChoices.append(noneTextChoice)
        
        let dontKnowTextChoice = ORKTextChoice(text: "I don't know anyone on this list.", value: "I don't know anyone on this list." as NSCoding & NSCopying & NSObjectProtocol)
        textChoices.append(dontKnowTextChoice)
        
        let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
        step.answerFormat = answerFormat
        
        step.isOptional = false
        
        return step
    }
    
    static func futureRecruitmentLikelihoodStep() -> ORKQuestionStep {
        let answerFormat = ORKAnswerFormat.continuousScale(withMaximumValue: 100.0, minimumValue: 0.0, defaultValue: 50.0, maximumFractionDigits: 0, vertical: false, maximumValueDescription: "Very likely", minimumValueDescription: "Not at all likely")
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.futureRecruitmentLikelihoodScaleStep),
                                   title: nil,
                                   question: "How likely are you to recruit volunteers in the future?",
                                   answer: answerFormat)
        
        return step
    }
    
    static func completionStep() -> ORKCompletionStep {
        let step = ORKCompletionStep(identifier: String(describing: Identifier.endOfStudyCompletionStep))
        
        step.title = "Thank you for participating in the Peer2Power competition!"
        step.detailText = "Thank you for participating in the political process and encouraging others to do so! We hope you keep up the good work!"
        
        return step
    }
}
