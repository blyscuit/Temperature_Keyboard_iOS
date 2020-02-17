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
import SwiftCSV

struct WeatherData {
    var data: [[String]]?
    init() {
        do {
            // From a file inside the app bundle, with a custom delimiter, errors, and custom encoding
            let resource: CSV? = try CSV(
                name: "weather",
                extension: "csv",
                bundle: .main,
                delimiter: ",",
                encoding: .utf8)
            data = resource?.enumeratedRows
        } catch {
            // Catch errors from trying to load files
        }
        temptFrom(dateFrom("2020-02-16"))
    }
    
    func dateFrom(_ text: String) -> Date {
        let dateFormatter = DateFormatter()
        if text.count >= "yyyy-MM-dd hh:mm:ss".count {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: text) ?? Date()
    }
    
    func temptFrom(_ date: Date) -> Double {
        let firstDate: Date = dateFrom(data?.first?[1] ?? "") ?? Date()
        print(firstDate)
        let lastDate: Date = dateFrom( data?.last?[1] ?? "") ?? Date()
        if date.compare(firstDate) == ComparisonResult.orderedAscending || date.compare(lastDate) == ComparisonResult.orderedDescending {
            return 0
        }
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        print(data?[((components.day! - 3) ?? 0)][1])
        return Double(data?[components.day ?? 0][2] ?? "0") ?? 0
    }
    
}
