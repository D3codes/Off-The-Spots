//
//  Double.swift
//  Off The Spots
//
//  Created by David Freeman on 12/4/24.
//

import Foundation

extension Double {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Double {
        return Double(CGFloat(self).map(from: from, to: to))
    }
}
