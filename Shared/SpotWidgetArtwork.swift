//
//  SpotWidgetArtwork.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import UIKit

enum SpotWidgetArtwork {
    // WidgetKit archives the image's pixels, regardless of its SwiftUI frame.
    // 400 pixels keeps every pose below the small widget's archive limit,
    // with enough resolution for its image area on a 3x display.
    static func image(for pose: SpotPose, in bundle: Bundle = .main) -> UIImage? {
        UIImage(named: pose.rawValue, in: bundle, compatibleWith: nil)?
            .preparingThumbnail(of: CGSize(width: 400, height: 400))
    }
}
