//
//  PlanViewController+Types.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import SwiftDate

enum PlanStyle {
    case hybrid
    case plan
    case entries
}

struct PlanConfig {
    var date: Date
    var detail: PlanDetail

    var selectedStyle = PlanStyle.plan
    
    init(date: Date, detail: PlanDetail) {
        self.date = date
        self.detail = detail
    }
    
    var style: PlanStyle {
        get {
            switch detail {
            case .daily:
                return .hybrid
            case .weekly:
                return selectedStyle
            }
        }
        set {
            selectedStyle = newValue
        }
    }
    
    static var defaultConfig = PlanConfig(
        date: Date(),
        detail: .daily
    )
    
    var lanes: [PlanLane] {
        switch detail {
        case .daily:
            return [.task, .pomodoro]
        case .weekly:
            return [.task]
        }
    }
    
    var dayCount: Int {
        switch detail {
        case .daily:
            return 1
        case .weekly:
            return 7
        }
    }
    
    var firstDay: Date {
        switch detail {
        case .daily:
            return date.startOf(component: .day)
        case .weekly:
            return date.startOf(component: .weekOfYear)
        }
    }
    
    var lastDay: Date {
        switch detail {
        case .daily:
            return firstDay
        case .weekly:
            return firstDay + 6.days
        }
    }
    
    var days: [Date] {
        var days = [Date]()
        
        for i in 0...(dayCount - 1) {
            days.append(firstDay + i.days)
        }
        
        return days
    }
    
    /**
     Range to be used when building queries.
    */
    var queryRange: (Date, Date) {
        return (firstDay.startOf(component: .day), lastDay.endOf(component: .day))
    }
}

enum PlanLane {
    case project
    case task
    case pomodoro
    
    var laneId: LaneId {
        switch self {
        case .project:
            fatalError()
        case .task:
            return LaneId.general
        case .pomodoro:
            return LaneId.pomodoro
        }
    }
}

enum PlanDetail {
    case daily
    case weekly
}
