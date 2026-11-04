import Foundation
import Testing
import UIKit
@testable import Off_The_Spots

struct SpotWidgetTests {
    @MainActor
    @Test(arguments: SpotPose.allCases)
    func artworkAndLetteringAreAvailableInAppAndWidget(pose: SpotPose) throws {
        let app = Bundle.main
        let extensionURL = try #require(app.builtInPlugInsURL?.appendingPathComponent("SongsWidget.appex"))
        let widget = try #require(Bundle(url: extensionURL))
        #expect(UIImage(named: pose.rawValue, in: app, compatibleWith: nil) != nil)
        let original = try #require(UIImage(named: pose.rawValue, in: widget, compatibleWith: nil)?.cgImage)
        let artwork = try #require(SpotWidgetArtwork.image(for: pose, in: widget)?.cgImage)
        // Check actual bitmap dimensions: a small SwiftUI frame alone does not
        // prevent WidgetKit's imageTooLarge archive failure.
        #expect(artwork.width <= 400)
        #expect(artwork.height <= 400)
        #expect(artwork.width > 0 && artwork.height > 0)
        #expect(artwork.width * artwork.height < original.width * original.height)
        let originalAspect = Double(original.width) / Double(original.height)
        let thumbnailAspect = Double(artwork.width) / Double(artwork.height)
        #expect(abs(originalAspect - thumbnailAspect) < 0.01)
        #expect(widget.url(forResource: "Anak Orang", withExtension: "ttf") != nil)
        #expect(UIFont(name: SpotContent.quoteFontName, size: 14) != nil)
    }

    @Test func randomAppearancesKeepThemedQuotesAndRotateImages() {
        var generator = SpotTestGenerator()
        var previousPose: SpotPose?
        var seen = Set<SpotPose>()
        for _ in 0..<200 {
            let appearance = SpotContent.random(using: &generator, excluding: previousPose)
            #expect(appearance.pose != previousPose)
            #expect(appearance.pose.phrases.contains(appearance.quote))
            if appearance.pose == .practicingTheRests {
                #expect(SpotContent.sleepingPhrases.contains(appearance.quote))
            } else if appearance.pose == .barbershop {
                #expect(SpotContent.barbershopPhrases.contains(appearance.quote))
            }
            seen.insert(appearance.pose)
            previousPose = appearance.pose
        }
        #expect(seen == Set(SpotPose.allCases))
    }
}

private struct SpotTestGenerator: RandomNumberGenerator {
    private var state: UInt64 = 42

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
