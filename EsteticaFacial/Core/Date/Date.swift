//
//  Date.swift
//  EsteticaFacial
//
//  Created by Orlando Amorim - LabInC on 13/04/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//

import Foundation
import Darwin

func dateTimeAgo(date: NSDate) -> String {
    
    let deltaSeconds = secondsFrom(date)
    let deltaMinutes:Double = Double(deltaSeconds / 60)
    
    if (deltaSeconds < 5) {
        return "agora a pouco"
    }
    if (deltaSeconds < 60) {
        return String(deltaSeconds) + " segundos atrás"
    }
    if (deltaSeconds < 120) {
        return "um minuto atrás"
    }
    if (deltaMinutes < 60) {
        return String(Int(deltaMinutes)) + " minutos atrás"
    }
    if (deltaMinutes < 120) {
        return "uma hora atrás"
    }
    if (deltaMinutes < (24 * 60)) {
        let hours = flooredString(deltaMinutes, dividedBy: 60)
        return hours + " horas atrás"
    }
    if (deltaMinutes < (24 * 60 * 2)) {
        return "ontem"
    }
    if (deltaMinutes < (24 * 60 * 7)) {
        let days = flooredString(deltaMinutes, dividedBy: (60 * 24))
        return days + " dias atrás"
    }
    if (deltaMinutes < (24 * 60 * 14)) {
        return "semana passada"
    }
    if (deltaMinutes < (24 * 60 * 31)) {
        let weeks = flooredString(deltaMinutes, dividedBy: (60 * 24 * 7))
        return weeks + " semanas atrás"
    }
    if (deltaMinutes < (24 * 60 * 61)) {
        return "mês passado"
    }
    if (deltaMinutes < (24 * 60 * 365.25)) {
        let months = flooredString(deltaMinutes, dividedBy: (60 * 24 * 30))
        return months + " meses atrás"
    }
    if (deltaMinutes < (24 * 60 * 731)) {
        return "ano passado"
    }
    
    let years = flooredString(deltaMinutes, dividedBy: (60 * 24 * 365))
    return years + " anos atrás"
}

private func secondsFrom(date:NSDate) -> Int {
    return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: NSDate(), options: []).second
}

private func flooredString(delta: Double, dividedBy: Double) -> String {
    return String(Int(floor(delta/dividedBy)))
}


typealias Time = Int

extension Time {
    var years: Time {
        return self * 365.days
    }
    var year: Time { return years }
    
    var days: Time {
        return self * 24.hours
    }
    var day: Time { return days }
    
    var hours: Time {
        return self * 60.minutes
    }
    var hour: Time { return hours }
    
    var minutes: Time {
        return self * 60.seconds
    }
    var minute: Time { return minutes }
    
    
    var seconds: Time {
        return self
    }
    var second: Time { return seconds }
    
    var ago: Time {
        return NSDate(timeIntervalSinceNow: NSTimeInterval(-self)).asTime
    }
    
    static var minTime: Time {
        return NSDate.minTime
    }
    
    static var now: Time {
        return NSDate().asTime
    }
}

extension NSDate {
    var asTime: Time {
        return Time(timeIntervalSince1970)
    }
    
    class var minTime: Time {
        return distantPast().asTime
    }
    
    class var maxTime: Time {
        return distantFuture().asTime
    }
    
    func equalToDate(date: NSDate) -> Bool {
        
        return self.compare(date) == NSComparisonResult.OrderedSame
    }
    
    func greaterThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    func lessThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedAscending
    }
    
    func toString() -> String{
        return String(self)
    }
}

public func < (first: NSDate, second: NSDate) -> Bool {
    return first.compare(second) == .OrderedAscending
}

public func > (first: NSDate, second: NSDate) -> Bool {
    return first.compare(second) == .OrderedDescending
}

public func <= (first: NSDate, second: NSDate) -> Bool {
    let cmp = first.compare(second)
    return cmp == .OrderedAscending || cmp == .OrderedSame
}

public func >= (first: NSDate, second: NSDate) -> Bool {
    let cmp = first.compare(second)
    return cmp == .OrderedDescending || cmp == .OrderedSame
}

public func == (first: NSDate, second: NSDate) -> Bool {
    return first.compare(second) == .OrderedSame
}

extension NSDate: Comparable {
    // Makes it Comparable so we can use (min(dateA, dateB), max(dateA, dateB), ...)
}
