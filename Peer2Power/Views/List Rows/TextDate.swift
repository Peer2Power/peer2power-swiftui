//
//  TextDate.swift
//  TextDate
//
//  Created by Andrew Morgan on 14/09/2021.
//

import SwiftUI

struct TextDate: View {
    let date: Date
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        Text(dateText)
    }
}

extension TextDate {
    private var dateText: String {
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(fromTimeInterval: date.timeIntervalSinceNow)
    }
}

struct TextDate_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TextDate(date: Date(timeIntervalSinceNow: -60 * 60 * 24 * 365)) // 1 year ago
            TextDate(date: Date(timeIntervalSinceNow: -60 * 60 * 24 * 7))   // 1 week ago
            TextDate(date: Date(timeIntervalSinceNow: -60 * 60 * 24))       // 1 day ago
            TextDate(date: Date(timeIntervalSinceNow: -60 * 60))            // 1 hour ago
            TextDate(date: Date(timeIntervalSinceNow: -60))                 // 1 minute ago
            TextDate(date: Date())                                          // Now
        }
    }
}
