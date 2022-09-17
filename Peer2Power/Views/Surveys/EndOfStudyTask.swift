//
//  EndOfStudyTask.swift
//  Peer2Power
//
//  Created by Deja Jackson on 9/16/22.
//

import ResearchKit
import RealmSwift

class EndOfStudyTask: ORKOrderedTask {
    static func knowContactsStep(contacts: List<Contact>) -> ORKFormStep {
        let step = ORKFormStep(identifier: String(describing: Identifier.knownContactsFormStep))
        var formItems = [ORKFormItem]()
        
        for contact in contacts {
            let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I was not able to find out.", value: "I was not able to find out." as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "I don't know this person.", value: "I don't know this person." as NSCoding & NSCopying & NSObjectProtocol)]
            let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
            
            let formItemText = "Did " + contact.name + " volunteer for a 2022 general election campaign?"
            let formItem = ORKFormItem(identifier: "know" + contact.contact_id.stringValue,
                                       text: formItemText,
                                       answerFormat: answerFormat)
            
            formItem.isOptional = false
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        step.isOptional = false
        
        return step
    }
    
    static func volunteerMethodStep(stepResult: ORKStepResult) -> ORKFormStep? {
        let step = ORKFormStep(identifier: String(describing: Identifier.volunteerMethodFormStep))
        
        guard let results = stepResult.results else { return nil }
        var formItems = [ORKFormItem]()
        
        for result in results {
            guard let result = result as? ORKChoiceQuestionResult else { return nil }
            guard let choiceAnswers = result.choiceAnswers else { return nil }
            
            for choiceAnswer in choiceAnswers {
                if choiceAnswer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol) {
                    let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Canvass", value: "Canvass" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Phone bank", value: "Phone bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Text bank", value: "Text bank" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Write postcards", value: "Write postcards" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther.choice(withText: "Other", detailText: nil, value: "Other" as NSCoding & NSCopying & NSObjectProtocol, exclusive: false, textViewPlaceholderText: "Please specify")]
                    let answerFormat = ORKTextChoiceAnswerFormat(style: .multipleChoice, textChoices: textChoices)
                    
                    let formItemText = "How did they volunteer?"
                    let formItem = ORKFormItem(identifier: "\(arc4random())",
                                               text: formItemText,
                                               answerFormat: answerFormat)
                    
                    formItems.append(formItem)
                }
            }
        }
        
        step.formItems = formItems
        
        return step
    }
    
    static func campaignTypeStep(prevStep: ORKFormStep) -> ORKFormStep? {
        let step = ORKFormStep(identifier: String(describing: Identifier.campaignTypeFormStep))
        
        guard let prevStepFormItems = prevStep.formItems else { return nil }
        var formItems = [ORKFormItem]()
        
        for _ in prevStepFormItems {
            let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Senate", value: "Senate" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "House of Representatives", value: "House of Representatives" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Gubernatorial", value: "Gubernatorial" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "State Legislative", value: "State Legislative" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoiceOther(text: "Other Local", value: "Other Local" as NSCoding & NSCopying & NSObjectProtocol)]
            let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
            
            let formItemText = "What kind of campaign?"
            let formItem = ORKFormItem(identifier: "\(arc4random())",
                                       text: formItemText,
                                       answerFormat: answerFormat)
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        return step
    }
    
    static func whyVolunteerStep(prevStep: ORKFormStep) -> ORKFormStep? {
        let step = ORKFormStep(identifier: String(describing: Identifier.whyVolunteerFormStep))
        
        guard let prevStepFormItems = prevStep.formItems else { return nil }
        var formItems = [ORKFormItem]()
        
        for _ in prevStepFormItems {
            let answerFormat = ORKTextAnswerFormat()
            answerFormat.multipleLines = true
            
            let formItemText = "Why do you think they chose to volunteer?"
            let formItem = ORKFormItem(identifier: "\(arc4random())",
                                       text: formItemText,
                                       answerFormat: answerFormat)
            
            formItems.append(formItem)
        }
        
        step.formItems = formItems
        
        return step
    }
    
    static func isFirstTimeStep() -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.isFirstTimeStep), title: nil, question: "Is this your first time recruiting people to volunteer for a campaign?", answer: ORKBooleanAnswerFormat())
        
        return step
    }
    
    static func volunteeringEasierStep() -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.volunteeringEasierStep), title: nil, question: "Did the Peer2Power app make volunteering more accessible to you?", answer: ORKBooleanAnswerFormat())
        
        return step
    }
    
    static func futureRecruitLikelihoodStep() -> ORKQuestionStep {
        let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Very likely", value: "Very likely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Somewhat likely", value: "Somewhat likely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Neither likely nor unlikely", value: "Neither likely nor unlikley" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Somewhat unlikely", value: "Somewhat unlikely" as NSCoding & NSCopying & NSObjectProtocol), ORKTextChoice(text: "Very unlikely", value: "Very unlikely" as NSCoding & NSCopying & NSObjectProtocol)]
        let answerFormat = ORKTextChoiceAnswerFormat(style: .singleChoice, textChoices: textChoices)
        
        let step = ORKQuestionStep(identifier: String(describing: Identifier.futureRecruitLikelihoodStep), title: nil, question: "How likely are you to recruit volunteers again in the future?", answer: answerFormat)
        
        return step
    }
    
    static func didUserVolunteerStep() -> ORKQuestionStep {
        let step = ORKQuestionStep(identifier: String(describing: Identifier.didUserVolunteerStep), title: nil, question: "Did you volunteer for a campaign during your participation in this study?", answer: ORKBooleanAnswerFormat())
        
        return step
    }
    
    static override func makeCompletionStep() -> ORKCompletionStep {
        let step = ORKCompletionStep(identifier: String(describing: Identifier.endOfStudyCompletionStep))
        
        step.title = "Thank you for completing this survey!"
        step.detailText = "Thank you for participating in the political process and encouraging others to do so! We hope you keep up the good work!"
        
        return step
    }
    
    override func step(after step: ORKStep?, with result: ORKTaskResult) -> ORKStep? {
        let identifier = step?.identifier
        
        switch identifier {
        case String(describing: Identifier.knownContactsFormStep):
            guard let stepResult = result.stepResult(forStepIdentifier: String(describing: Identifier.knownContactsFormStep)) else { return nil }
            guard let results = stepResult.results as? [ORKChoiceQuestionResult] else { return nil }
            
            for result in results {
                guard let answers = result.choiceAnswers else { return nil }
                
                let hasYes = answers.contains { answer in
                    return answer.isEqual("Yes" as NSCoding & NSCopying & NSObjectProtocol)
                }
                
                if hasYes {
                    return EndOfStudyTask.volunteerMethodStep(stepResult: stepResult)
                }
            }
        case String(describing: Identifier.volunteerMethodFormStep):
            guard let prevStep = step as? ORKFormStep else { return nil }
            return EndOfStudyTask.campaignTypeStep(prevStep: prevStep)
        case String(describing: Identifier.campaignTypeFormStep):
            guard let prevStep = step as? ORKFormStep else { return nil }
            return EndOfStudyTask.whyVolunteerStep(prevStep: prevStep)
        case String(describing: Identifier.whyVolunteerFormStep):
            return EndOfStudyTask.isFirstTimeStep()
        case String(describing: Identifier.isFirstTimeStep):
            return EndOfStudyTask.volunteeringEasierStep()
        case String(describing: Identifier.volunteeringEasierStep):
            return EndOfStudyTask.futureRecruitLikelihoodStep()
        case String(describing: Identifier.futureRecruitLikelihoodStep):
            return EndOfStudyTask.didUserVolunteerStep()
        case String(describing: Identifier.didUserVolunteerStep):
            return EndOfStudyTask.makeCompletionStep()
        default:
            break
        }
        
        return super.step(after: step, with: result)
    }
}
