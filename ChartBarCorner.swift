//
//  ChartBarCorner.swift
//  Charts
//
//  Created by Eman Basic on 04.10.22.
//

import Foundation

public enum ChartBarCorner {
    /// exactly the half of the bar width
    case perfect
    /// custom corner radius, but not larger than the half of the bar width
    case custom(value: CGFloat)
    /// default value, 0
    case none
}
