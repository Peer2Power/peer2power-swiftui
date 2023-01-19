//
//  LogOutreachTask.swift
//  GovLab
//
//  Created by Deja Jackson on 3/28/22.
//

import UIKit
import ResearchKit

class LogOutreachTask: ORKOrderedTask {
    
    override init(identifier: String, steps: [ORKStep]?) {
        super.init(identifier: identifier, steps: steps)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static var volunteerStatusStep: ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: theyVolunteeredText, value: theyVolunteeredText as NSString), ORKTextChoice(text: "I am still working on them!", value: "I am still working on them!" as NSString), ORKTextChoice(text: "They are certainly not going to send an email.", value: "They are certainly not going to send an email." as NSString)]
        let volunteerStatusFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let volunteerStep = ORKQuestionStep(identifier: String(describing: Identifier.volunteerStatus),
                                            title: nil,
                                            question: "Did they email an elected representative or have they committed to emailing?",
                                            answer: volunteerStatusFormat)
        volunteerStep.isOptional = false
        
        return volunteerStep
    }
    
    static var whichLevelQuestionStep: ORKQuestionStep {
        let govLevelTextChoices: [ORKTextChoice] = [ORKTextChoice(text: "A local elected representative", value: "A local elected representative" as NSString), ORKTextChoice(text: "A state elected representative", value: "A state elected representative" as NSString), ORKTextChoice(text: "A federal elected representative", value: "A federal elected representative" as NSString), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSString, exclusive: true, textViewPlaceholderText: "Please specify")]
        let govLevelAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: govLevelTextChoices)
        
        let govLevelStep = ORKQuestionStep(identifier: String(String(describing: Identifier.whichLevelQuestionStep)),
                                           title: nil,
                                           question: "Who did they email?",
                                           answer: govLevelAnswerFormat)
        
        return govLevelStep
    }
    
    static var theyVolunteeredCompletionStep: ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.theyVolunteeredCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "You multiplied their political power! Thanks for bringing more people into the political process!"
        
        return completionStep
    }
    
    static var stillWorkingCompletionStep: ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.stillWorkingCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "Put your next outreach attempt in the calendar so you don't forget."
        
        return completionStep
    }
    
    static var wontVolunteerCompletionStep: ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.wontVolunteerCompletionStep))
        completionStep.title = "Thank you for logging this outreach attempt!"
        
        return completionStep
    }
    
    override func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.whichLevelQuestionStep):
            return LogOutreachTask.volunteerStatusStep
        case String(describing: Identifier.theyVolunteeredCompletion):
            return LogOutreachTask.whichLevelQuestionStep
        case String(describing: Identifier.stillWorkingCompletion):
            return LogOutreachTask.volunteerStatusStep
        case String(describing: Identifier.wontVolunteerCompletionStep):
            return LogOutreachTask.volunteerStatusStep
        
        default:
            return super.step(before: step, with: result)
        }
    }
    
    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifer = step?.identifier
        
        // TODO: might have to add these steps back to the outreach controller so it can show the user their progress (like showing "step 1 of 9")
        
        switch identifer {
        case String(describing: Identifier.volunteerStatus):
            let stepResult = result.stepResult(forStepIdentifier: String(describing: Identifier.volunteerStatus))
            
            if let result = stepResult?.firstResult as? ORKChoiceQuestionResult {
                if let choiceAnswer = result.choiceAnswers?.first {
                    if choiceAnswer.isEqual(theyVolunteeredText as NSString) {
                        return LogOutreachTask.whichLevelQuestionStep
                    } else if choiceAnswer.isEqual("I am still working on them!" as NSString) {
                        return LogOutreachTask.stillWorkingCompletionStep
                    } else if choiceAnswer.isEqual("They are certainly not going to send an email." as NSString) {
                        return LogOutreachTask.wontVolunteerCompletionStep
                    }
                }
            }
        case String(describing: Identifier.whichLevelQuestionStep):
            return LogOutreachTask.theyVolunteeredCompletionStep
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
