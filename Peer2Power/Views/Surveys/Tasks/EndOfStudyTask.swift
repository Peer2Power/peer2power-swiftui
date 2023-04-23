//
//  EndOfStudyTask.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import ResearchKit
import RealmSwift

class EndOfStudyTask: ORKOrderedTask {
    static func welcomeStep() -> ORKInstructionStep {
        let step = ORKInstructionStep(identifier: String(describing: Identifier.endOfStudyWelcomeStep))
        step.title = "End Of Study Survey"
        step.text = "This survey is the last step of the competition. Please not that you can only submit *ONE* response. After you select \"Done\" you will not be able to return to this survey."
        
        return step
    }
    
    static func whoVolunteeredStep(team: Team) -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.whichVolunteeredStep),
                                   title: nil,
                                   question: "Below is a list of your team's contacts that did not send an email. \n\nPlease follow up with anyone on the list that you know and confirm if they have emailed an elected representative.",
                                   answer: nil)
        var textChoices = [ORKTextChoice]()
        
        for contact in team.contacts {
            let filteredOutreachAttempts = team.outreachAttempts.filter("to = %@", contact.contact_id)
                .filter("volunteerStatus = %@", theyVolunteeredText)
            let filteredResponses = team.endOfStudyResponses.filter("%@ in contact_ids", contact.contact_id.stringValue)
            
            if filteredOutreachAttempts.isEmpty && filteredResponses.isEmpty {
                let textChoice = ORKTextChoice(text: contact.name, value: contact.contact_id.stringValue as NSString)
                textChoices.append(textChoice)
            }
        }
        
        let noneTextChoice = ORKTextChoice(text: "None of the contacts listed above who I know emailed an elected representative.", value: "None of the contacts listed above who I know emailed an elected representative." as NSString)
        textChoices.append(noneTextChoice)
        
        let dontKnowTextChoice = ORKTextChoice(text: "I don't know anyone on this list.", value: "I don't know anyone on this list." as NSString)
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
                                   question: "How likely are you to recruit friends and family to reach out to their representatives in the future?",
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
