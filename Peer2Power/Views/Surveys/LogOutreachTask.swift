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
    
    static func howContactStep() -> ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Text", value: "Text" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Email", value: "Email" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone Call", value: "Phone Call" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Social Media", value: "Social Media" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "In Person", value: "In Person" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify")]
        let contactMethodAnswerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let howStep = ORKQuestionStep(identifier: String(describing: Identifier.howContact),
                                      title: nil,
                                      question: "How did you contact this person?",
                                      answer: contactMethodAnswerFormat)
        
        return howStep
    }
    
    static func describeAttemptStep() -> ORKQuestionStep {
        let describeAttemptAnswerFormat = ORKTextAnswerFormat()
        describeAttemptAnswerFormat.multipleLines = true
        
        let describeStep = ORKQuestionStep(identifier: String(describing: Identifier.describeAttempt),
                                           title: nil,
                                           question: "What word or phrase would you use to describe the outreach attempt?",
                                           answer: describeAttemptAnswerFormat)
        
        return describeStep
    }
    
    static func volunteerStatusStep() -> ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "They volunteered!", value: "They volunteered!" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "They plan to volunteer.", value: "They plan to volunteer." as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I'm still working on them.", value: "I'm still working on them." as NSCoding & NSCopying & NSObjectProtocol)]
        let volunteerStatusFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let volunteerStep = ORKQuestionStep(identifier: String(describing: Identifier.volunteerStatus),
                                            title: nil,
                                            question: "Did they volunteer or have they committed to volunteering?",
                                            answer: volunteerStatusFormat)
        volunteerStep.isOptional = false
        
        return volunteerStep
    }
    
    static func volunteerMethodStep() -> ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Phone banking", value: "Phone banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text banking", value: "Text banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Writing post cards or letters", value: "Writing post cards or letters" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Door-to-door canvassing", value: "Door-to-door canvassing" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Some other way", detailText: nil, value: "Some other way" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify"), ORKTextChoice(text: "I don't know or I'm not sure", value: "I don't know or I'm not sure" as NSCoding & NSCopying & NSObjectProtocol)]
        let volunteerMethodFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let methodStep = ORKQuestionStep(identifier: String(describing: Identifier.volunteerMethod),
                                         title: nil,
                                         question: "Great! How did they volunteer?",
                                         answer: volunteerMethodFormat)
        
        return methodStep
    }
    
    static func theyVolunteeredStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.theyVolunteeredCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "You multiplied their political power! Thanks for bringing more people into the political process!"
        
        return completionStep
    }
    
    static func planVolunteerStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.planVolunteerCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "Don't forget to follow up with them and confirm that they volunteered."
        
        return completionStep
    }
    
    static func stillWorkingStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.stillWorkingCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "Put your next outreach attempt in the calendar so you don't forget."
        
        return completionStep
    }
    
    override func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.volunteerMethod):
            return LogOutreachTask.volunteerStatusStep()
        case String(describing: Identifier.theyVolunteeredCompletion):
            return LogOutreachTask.volunteerMethodStep()
        case String(describing: Identifier.stillWorkingCompletion):
            return LogOutreachTask.volunteerStatusStep()
        case String(describing: Identifier.planVolunteerCompletion):
            return LogOutreachTask.volunteerStatusStep()
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
                    if choiceAnswer.isEqual("They volunteered!" as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.volunteerMethodStep()
                    } else if choiceAnswer.isEqual("They plan to volunteer." as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.planVolunteerStep()
                    } else if choiceAnswer.isEqual("I'm still working on them." as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.stillWorkingStep()
                    }
                }
            }
            
        case String(describing: Identifier.volunteerMethod):
            return LogOutreachTask.theyVolunteeredStep()
            
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
