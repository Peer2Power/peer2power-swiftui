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
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "I have confirmed that they volunteered.", value: "I have confirmed that they volunteered." as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I am still working on them!", value: "I am still working on them!" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "They are certainly not going to volunteer.", value: "They are certainly not going to volunteer." as NSCoding & NSCopying & NSObjectProtocol)]
        let volunteerStatusFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let volunteerStep = ORKQuestionStep(identifier: String(describing: Identifier.volunteerStatus),
                                            title: nil,
                                            question: "Did they volunteer or have they committed to volunteering?",
                                            answer: volunteerStatusFormat)
        volunteerStep.isOptional = false
        
        return volunteerStep
    }
    
    static var volunteeredFormStep: ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.volunteeredFormStep))
        
        let volunteerMethodTextChoices: [ORKTextChoice] = [ORKTextChoice(text: "Phone banking", value: "Phone banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text banking", value: "Text banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Writing post cards or letters", value: "Writing post cards or letters" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Door-to-door canvassing", value: "Door-to-door canvassing" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Volunteering at a campaign office", value: "Volunteering at a campaign office" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Internship", value: "Internship" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Some other way", detailText: nil, value: "Some other way" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify"), ORKTextChoice(text: "I don't know or I'm not sure", value: "I don't know or I'm not sure" as NSCoding & NSCopying & NSObjectProtocol)]
        let volunteerMethodAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: volunteerMethodTextChoices)
        
        let volunteerMethodFormItem = ORKFormItem(identifier: String(describing: Identifier.volunteerMethodFormItem),
                                                  text: "How did they volunteer?",
                                                  answerFormat: volunteerMethodAnswerFormat)
        
        let campaignTypeTextChoices: [ORKTextChoice] = [ORKTextChoice(text: "Senate", value: "Senate" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "House of Representatives", value: "House of Representatives" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Gubernatorial", value: "Gubernatorial" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "State legislative", value: "State legislative" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther(text: "Other Local", value: "Other Local" as NSCoding & NSCopying & NSObjectProtocol)]
        let campaignTypeAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: campaignTypeTextChoices)
        
        let campaignTypeFormItem = ORKFormItem(identifier: String(describing: Identifier.campaignTypeFormItem),
                                               text: "What kind of campaign did they volunteer for?",
                                               answerFormat: campaignTypeAnswerFormat)
        // Add this back to the formitems array if questions about campaign type are ever reconsidered.
        
        step.formItems = [volunteerMethodFormItem]
        
        return step
    }
    
    static var optionalQFormStep: ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.optionalQFormStep))
        
        let howContactTextChoices: [ORKTextChoice] = [ORKTextChoice(text: "Text", value: "Text" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Email", value: "Email" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone Call", value: "Phone Call" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Social Media", value: "Social Media" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "In Person", value: "In Person" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify")]
        let contactMethodAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: howContactTextChoices)
        
        let howContactFormItem = ORKFormItem(identifier: String(describing: Identifier.howContactFormItem),
                                             text: "How did you contact them?",
                                             answerFormat: contactMethodAnswerFormat)
        
        let attemptDescriptionFormItem = ORKFormItem(identifier: String(describing: Identifier.attemptDescriptionFormItem),
                                                     text: "What word or phrase would you use to describe this outreach attempt?",
                                                     answerFormat: ORKTextAnswerFormat())
        
        step.formItems = [howContactFormItem, attemptDescriptionFormItem]
        
        return step
    }
    
    static var volunteerMethodStep: ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Phone banking", value: "Phone banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text banking", value: "Text banking" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Writing post cards or letters", value: "Writing post cards or letters" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Door-to-door canvassing", value: "Door-to-door canvassing" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Volunteering at a campaign office", value: "Volunteering at a campaign office" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Internship", value: "Internship" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Some other way", detailText: nil, value: "Some other way" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify"), ORKTextChoice(text: "I don't know or I'm not sure", value: "I don't know or I'm not sure" as NSCoding & NSCopying & NSObjectProtocol)]
        let volunteerMethodFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let methodStep = ORKQuestionStep(identifier: String(describing: Identifier.volunteerMethod),
                                         title: nil,
                                         question: "Great! How did they volunteer?",
                                         answer: volunteerMethodFormat)
        
        return methodStep
    }
    
    static var howContactStep: ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Text", value: "Text" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Email", value: "Email" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone Call", value: "Phone Call" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Social Media", value: "Social Media" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "In Person", value: "In Person" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true, textViewPlaceholderText: "Please specify")]
        let contactMethodAnswerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let howStep = ORKQuestionStep(identifier: String(describing: Identifier.howContact),
                                      title: nil,
                                      question: "How did you contact this person?",
                                      answer: contactMethodAnswerFormat)
        
        return howStep
    }
    
    // TODO: combing contact method and attempt description into single form step.
    static var describeAttemptStep: ORKQuestionStep {
        let describeAttemptAnswerFormat = ORKTextAnswerFormat()
        describeAttemptAnswerFormat.multipleLines = true
        
        let describeStep = ORKQuestionStep(identifier: String(describing: Identifier.describeAttempt),
                                           title: nil,
                                           question: "What word or phrase would you use to describe the outreach attempt?",
                                           answer: describeAttemptAnswerFormat)
        
        return describeStep
    }
    
    static func theyVolunteeredCompletionStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.theyVolunteeredCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "You multiplied their political power! Thanks for bringing more people into the political process!"
        
        return completionStep
    }
    
    static func planToVolunteerCompletionStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.planVolunteerCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "Don't forget to follow up with them and confirm that they volunteered."
        
        return completionStep
    }
    
    static func stillWorkingCompletionStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.stillWorkingCompletion))
        completionStep.title = "Thank you for logging this outreach attempt!"
        completionStep.detailText = "Put your next outreach attempt in the calendar so you don't forget."
        
        return completionStep
    }
    
    static func wontVolunteerCompletionStep() -> ORKCompletionStep {
        let completionStep = ORKCompletionStep(identifier: String(describing: Identifier.wontVolunteerCompletionStep))
        completionStep.title = "Thank you for logging this outreach attempt!"
        
        return completionStep
    }
    
    override func step(before step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.volunteeredFormStep):
            return LogOutreachTask.volunteerStatusStep
        case String(describing: Identifier.theyVolunteeredCompletion):
            return LogOutreachTask.describeAttemptStep
        case String(describing: Identifier.stillWorkingCompletion):
            return LogOutreachTask.describeAttemptStep
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
                    if choiceAnswer.isEqual("I have confirmed that they volunteered." as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.volunteeredFormStep
                    } else if choiceAnswer.isEqual("I am still working on them!" as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.howContactStep
                    } else if choiceAnswer.isEqual("They are certainly not going to volunteer." as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.wontVolunteerCompletionStep()
                    }
                }
            }
            
        case String(describing: Identifier.volunteeredFormStep):
            return LogOutreachTask.howContactStep
            
        case String(describing: Identifier.describeAttempt):
            let stepResult = result.stepResult(forStepIdentifier: String(describing: Identifier.volunteerStatus))
            
            if let result = stepResult?.firstResult as? ORKChoiceQuestionResult {
                if let choiceAnswer = result.choiceAnswers?.first {
                    if choiceAnswer.isEqual("I have confirmed that they volunteered." as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.theyVolunteeredCompletionStep()
                    } else if choiceAnswer.isEqual("I am still working on them!" as NSCoding & NSCopying & NSObjectProtocol) {
                        return LogOutreachTask.stillWorkingCompletionStep()
                    }
                }
            }
            
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
