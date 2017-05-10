//
//  PlanViewController+Types.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/10/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Foundation
import SwiftDate

struct PlanRange {
    var start: Date
    var dayCount: Int
    
    var lastDay: Date {
        return start + (dayCount - 1).days
    }
    
    var dateRange: (Date, Date) {
        let start = self.start.startOf(component: .day)
        let end = lastDay.endOf(component: .day)
        
        return (start, end)
    }
}

enum PlanStyle {
    case hybrid
    case plan
    case entries
}

struct PlanConfig {
    var range: PlanRange
    var lanes: [PlanLane]
    var detail: PlanDetail
    var style = PlanStyle.hybrid
    
    static var defaultConfig = PlanConfig.daily(date: Date())
    
    public static func daily(date: Date) -> PlanConfig {
        let range = PlanRange(start: date.startOf(component: .day), dayCount: 1)
        
        return PlanConfig(
            range: range,
            lanes: [.task, .pomodoro],
            detail: .daily,
            style: .hybrid
        )
    }
    
    public static func weekly(date: Date) -> PlanConfig {
        let range = PlanRange(start: date.startOf(component: .weekOfYear), dayCount: 7)
        
        return PlanConfig(
            range: range,
            lanes: [.task],
            detail: .weekly,
            style: .plan
        )
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
