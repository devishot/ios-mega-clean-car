//
//  Statistic.swift
//  cleancar
//
//  Created by MacBook Pro on 9/14/16.
//  Copyright © 2016 a. All rights reserved.
//

import Foundation
import SwiftyJSON


let StatisticSinceDay: NSDate = parseTime("2016-09-01 09:00:00")


func getStaticKey(date: NSDate, forFilter: StatisticFilter) -> String {
    let calendar = getCalendar()
    
    switch forFilter {
    case .Year:
        let year = calendar.components(.Year, fromDate: date).year
        return "/years/" + String(year)
    case .Month:
        let updCalendar = calendar.components([.Year, .Month], fromDate: date)
        return "/months/" + "\(updCalendar.year)-\(updCalendar.month)"
    case .Week:
        var firstDayOfWeek: NSDate?,
        lastDayOfWeek: NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &firstDayOfWeek, interval: nil, forDate: date)
        lastDayOfWeek = calendar.dateByAddingUnit(.Day, value: 7, toDate: firstDayOfWeek!, options: [])
        let weekRange = [firstDayOfWeek!, lastDayOfWeek!]
            .map({ formatAsString($0, onlyDate: true) })
            .joinWithSeparator("_")
        return "/weeks/" + weekRange
    case .Day:
        return "/days/" + formatAsString(date, onlyDate: true)
    }
}

func getStaticKeyDisplay(date: NSDate, forFilter: StatisticFilter) -> String {
    let calendar = getCalendar()
    
    switch forFilter {
    case .Month:
        return getMonth(date, inFormat: "MMMM") + "'" + formatAsString(date, inFormat: "yy")
    case .Week:
        var firstDayOfWeek: NSDate?,
        lastDayOfWeek: NSDate?
        calendar.rangeOfUnit(.WeekOfYear, startDate: &firstDayOfWeek, interval: nil, forDate: date)
        lastDayOfWeek = calendar.dateByAddingUnit(.Day, value: 7, toDate: firstDayOfWeek!, options: [])
        let weekRange = [firstDayOfWeek!, lastDayOfWeek!]
            .map({ formatAsString($0, inFormat: "MMMM dd") })
            .joinWithSeparator(" .. ")
        return weekRange
    case .Day:
        return formatAsString(date, inFormat: "d MMMM - EEEE")
    default:
        return ""
    }
}


enum StatisticFilter: Int {
    case Day
    case Week
    case Month
    case Year
}

class StatisticItem {
    var filter: StatisticFilter
    var date: NSDate
    var info: Dictionary<String, Int>?

    init(filter: StatisticFilter, date: NSDate, info: Dictionary<String, Int>?) {
        self.filter = filter
        self.date = date
        self.info = info
    }


    func key() -> String {
        return getStaticKey(date, forFilter: filter)
    }

    func name() -> String {
        return getStaticKeyDisplay(date, forFilter: filter)
    }

    func genPrev() -> StatisticItem? {
        let calendar = getCalendar()
        var prevDate: NSDate?

        switch filter {
        case .Day:
            prevDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])
        case .Week:
            prevDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: date, options: [])
        case .Month:
            prevDate = calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: [])
        default:
            break
        }

        if prevDate!.timeIntervalSinceReferenceDate < StatisticSinceDay.timeIntervalSinceReferenceDate  {
            return nil
        }

        return StatisticItem(filter: filter, date: prevDate!, info: nil)
    }

    func fetchInfo(completion: ()->(Void)) {
        getFirebaseRef()
            .child("/statistics"+key())
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                var newInfo = Dictionary<String, Int>()

                if snapshot.value is NSNull {
                } else {
                    let parsed = JSON(snapshot.value!).dictionaryValue
                    newInfo = parsed.reduce([String: Int]()) { (var acc, nextValue) in
                        acc.updateValue(nextValue.1.intValue, forKey: nextValue.0)
                        return acc
                    }
                }

                self.info = newInfo
                completion()
            })
    }
}
