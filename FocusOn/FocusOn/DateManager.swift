//
//  DateManager.swift
//  FocusOn
//
//  Created by Matthew Sousa on 7/23/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation

class DateManager {
    
     // MARK: - Time Management
        // MARK: Start of Day
        func startOfTheDay() -> Date {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            return calendar.startOfDay(for: Date())
        }
        
        func endOfDay() -> Date {
            var components = DateComponents()
            components.day = 1
            let endOfTheDay = Calendar.current.date(byAdding: components, to: startOfTheDay()) ?? Date()
            print("\(endOfTheDay)")
            return endOfTheDay
        }
        
        func printTimeStamps() {
            let start = startOfTheDay()
            let end = endOfDay()
            let x = end.compare(start)
            print("start: \(start), end: \(end) \n comparison: \(x.rawValue)")
        }
        
        
        // False == Same Day, True == Next Day
        func compareDays(from date1: Date) -> Bool {
            let days1 = Calendar.current.component(.day, from: date1)
            let days2 = Calendar.current.component(.day, from: endOfDay())
            let comparison = days1 - days2
            print(#function +  "\ncurrent: \(date1), endOfDay: \(endOfDay()), comparison = \(comparison)")
            print("## the actual date: \(Date())")
            if comparison >= 1 {
                // The next day
                return true
            } else {
                // The same day
                return false
            }
        }
        
        // Check if dates Month, Day match
        func isDateFromToday(_ date: Date?) -> Bool? {
            print(#function)
            guard let inputDate = date else { return nil }
            let todaysDate = Date()
            // Get dates
            let tYear = Calendar.current.component(.year, from: todaysDate)
            let tMonth = Calendar.current.component(.month, from: todaysDate)
            let tDay = Calendar.current.component(.day, from: todaysDate)
            
            let iYear = Calendar.current.component(.year, from: inputDate)
            let iMonth = Calendar.current.component(.month, from: inputDate)
            let iDay = Calendar.current.component(.day, from: inputDate)
            
            // Check if dates match
            // If ALL components MATCH
            if tYear == iYear && tMonth == iMonth && tDay == iDay {
                print(#function + "true")
                return true
            // Else { if ANY of the compnents DONT MATCH
            } else if tYear != iYear || tMonth != iMonth || tDay != iDay {
                print(#function + "false")
                return false
            }
            return nil
        }
        
        
        // return "MMM/dd/YY" date
        func formatDate(from goal: GoalData? = nil, from task: TaskData? = nil) -> String? {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM/dd/YY"
            
            if goal != nil {
                let date = goal?.dateCreated!
                return formatter.string(from: date!)
                
            } else if task != nil {
                let date = task?.dateCreated!
                return formatter.string(from: date!)
            }
            return nil
        }
        
        // return short day of week / numerical day - "Tu/13"
        func formatDate(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEEEE d"
            return formatter.string(from: date)
            
        }
        
        // Check if date is from Current Month
        func isDateFromCurrentMonth(_ date: Date?) -> Bool? {
            guard let input = date else { return nil }
            let currentDate = Date()
            
            // Get dates
            let currentMonth = Calendar.current.component(.month, from: currentDate)
            let inputMonth = Calendar.current.component(.month, from: input)
            
            if currentMonth == inputMonth {
                return true
            } else {
                return false
            }
        }
        
        // check if date is within the last three months
        func isDateFromLastThreeMonths(_ date: Date?) -> Bool? {
            guard let input = date else { return nil }
            let currentDate = Date()
            
            // get dates
            let currentMonth = Calendar.current.component(.month, from: currentDate)
            let inputMonth = Calendar.current.component(.month, from: input)
            
            let threeMonthsPrior = currentMonth - 3
    //        for month in threeMonthsPrior...currentMonth {
            for month in threeMonthsPrior...currentMonth {
                print("lastThreeMonths - TEST - \(month) ----------------")
                if inputMonth == month {
                    print("lastThreeMonths - TEST - RETURN TRUE - inputMonth: \(inputMonth) == month: \(month)")
    //                return true
                }
            }
            
            for month in threeMonthsPrior...currentMonth {
                if inputMonth == month {
                    print("lastThreeMonths - isDateFromLastThreeMonths(\(inputMonth)) - current: \(currentMonth): TRUE - month: \(month)")
                    return true
                } else if inputMonth != month {
                    print("lastThreeMonths - isDateFromLastThreeMonths(\(inputMonth)) - current: \(currentMonth): FALSE - month: \(month)")
                    return false
                }
            }
            return nil
        }

        // Check if date is from Current Week
        func isDateFromCurrentWeek(_ date: Date?) -> Bool? {
            guard let input = date else { return nil }
            let currentDate = Date()
            
            // Get dates
            let currentMonth = Calendar.current.component(.weekOfYear, from: currentDate)
            let inputMonth = Calendar.current.component(.weekOfYear, from: input)
            
            if currentMonth == inputMonth {
                return true
            } else {
                return false
            }
        }
        
        // Create a date using figures
        func createDate(month: Int, day: Int, year: Int) -> Date {
            let calendar = Calendar.current
            let components = DateComponents(year: year, month: month, day: day)
            
            return calendar.date(from: components)!
        }
}