/// Copyright (c) 2563 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

struct WeekDayConverter {
    enum WeekDay: Int {
        case Sun = 1, Mon = 2, Tue = 3, Wed = 4, Thurs = 5, Fri = 6, Sat = 7
        init(_ input: String) {
            if input.lowercased().contains("sun") {
                self = WeekDay.Sun
            } else if input.lowercased().contains("mon") {
                self = WeekDay.Mon
            } else if input.lowercased().contains("tue") {
                           self = WeekDay.Tue
           } else if input.lowercased().contains("wed") {
                          self = WeekDay.Wed
          } else if input.lowercased().contains("thu") {
                         self = WeekDay.Thurs
         } else if input.lowercased().contains("fri") {
                        self = WeekDay.Fri
            } else {
                self = WeekDay.Sat
            }
        }
    }
    
    static func getNextWeekDayOf(_ text: String) -> Date {
        var currentDate = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let nextWeekdays = WeekDay(text).rawValue
        
        let components = DateComponents(weekday: nextWeekdays)
        let nextOccurrence = calendar.nextDate(after: currentDate, matching: components, matchingPolicy: .nextTime)!
        currentDate = nextOccurrence
        return nextOccurrence
    }
}
