//
//  Calendar.swift
//  SpaceX
//
//  Created by Foggin, Oliver (Developer) on 14/07/2021.
//

import Foundation

extension Calendar {
    func numDaysBetween(_ date1: Date, _ date2: Date) -> Int {
        let fromDate = startOfDay(for: date1)
        let toDate = startOfDay(for: date2)
        
        let numberDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberDays.day ?? 0
    }
}
