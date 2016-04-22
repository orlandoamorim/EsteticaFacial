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
