//
//  ComplicationController.swift
//  time-apple-watch Extension
//
//  Created by Sohil Pandya on 17/03/2017.
//  Copyright © 2017 dwyl. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    var oldDate = Date()
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
//        handler([.forward, .backward])
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "dwyl")
            template.line2TextProvider = CLKRelativeDateTextProvider(date: oldDate, style: .timer, units: [.hour, .minute, .second])
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        case .modularLarge:
            
            let time = CLKRelativeDateTextProvider(date: oldDate, style: .timer, units: [.hour, .minute, .second])

            let template = CLKComplicationTemplateModularLargeTallBody()
            template.bodyTextProvider = time
            template.headerTextProvider = CLKSimpleTextProvider(text: "dwyl")
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        default:
            print("Unknown complication type: \(complication.family)")
            handler(nil)
        }
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        if complication.family == .modularSmall {
            print("YOU ARE IN MODULAR SMALL")
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "dwyl")
            template.line2TextProvider = CLKRelativeDateTextProvider(date: oldDate, style: .timer, units: [.hour, .minute, .second])
            handler(template)
        }
        if complication.family == .modularLarge {
            print("YOU ARE IN MODULAR LARGE")
            let template = CLKComplicationTemplateModularLargeTable()
            template.headerTextProvider = CLKSimpleTextProvider(text: "dwyl")
            template.row1Column1TextProvider = CLKSimpleTextProvider(text: "Sohil")
            template.row1Column2TextProvider = CLKSimpleTextProvider(text: "Pandya")
            template.row2Column1TextProvider = CLKSimpleTextProvider(text: "time")
            template.row2Column2TextProvider = CLKSimpleTextProvider(text: "time")
            handler(template)
        }
        else {
            handler(nil)
        }
        
    }
    
}
