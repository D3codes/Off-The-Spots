//
//  SpotPose.swift
//  Off The Spots
//
//  Created by David Freeman on 11/2/26.
//


import Foundation

enum SpotPose: String, CaseIterable, Sendable {
    case standard = "spot"
    case escapingNotes = "escaping-notes"
    case fetchASong = "fetch-a-song"
    case pointing = "pointing"
    case practicingTheRests = "practicing-the-rests"
    case tinyRehearsalStage = "tiny-rehearsal-stage"
    case waitingForRehearsal = "waiting-for-rehearsal"
    case barbershop = "spot-barbershop"

    var phrases: [String] {
        switch self {
        case .practicingTheRests: SpotContent.sleepingPhrases
        case .barbershop: SpotContent.barbershopPhrases
        default: SpotContent.spotPhrases
        }
    }
}

struct SpotAppearance: Equatable, Sendable {
    let pose: SpotPose
    let quote: String
}

enum SpotContent {
    static let quoteFontName = "AnakOrang"

    static let spotPhrases: [String] = [
        "My favorite key? The one you sing in.",
        "I’ve been practicing. Mostly sitting. But in tempo.",
        "You sing. I’ll handle the tail section.",
        "I’m classically trained. Sit, stay, crescendo.",
        "Perfect pitch? Is that when you throw the ball just right?",
        "My ears are floppy. My rhythm is solid.",
        "One, two, three… squirrel.",
        "I only howl in sympathetic keys.",
        "My vocal range? Doorbell to vacuum.",
        "I put the paw in a cappella.",
        "My tail has its own time signature.",
        "I’ve marked my part. Please don’t ask how.",
        "I promise not to eat the sheet music. Again.",
        "Can we take that from the bark?",
        "A little practice. A little progress. A little treat.",
        "I’m your biggest fan. And your smallest roadie."
    ]

    static let sleepingPhrases: [String] = [
        "I’ve practiced all the rests.",
        "Wake me for the key change.",
        "I’m not asleep. I’m holding a very long rest.",
    ]

    static let barbershopPhrases: [String] = [
        "I put the paw in a cappella.",
        "I sing baritone. It’s like barking, but employed.",
        "Four parts. Four paws. Coincidence?",
        "I’m looking for three other good boys.",
        "My hat is flat. My singing is a work in progress.",
        "I’ve got the vest. How hard can the notes be?",
        "Please hold your appaws until the chord rings.",
        "Some dogs chase tails. I chase overtones.",
        "That chord gave me the tail wags.",
        "I know a great tag. It’s on my collar."
    ]

    static func random(excluding previousPose: SpotPose? = nil) -> SpotAppearance {
        var generator = SystemRandomNumberGenerator()
        return random(using: &generator, excluding: previousPose)
    }

    static func random<Generator: RandomNumberGenerator>(
        using generator: inout Generator,
        excluding previousPose: SpotPose? = nil
    ) -> SpotAppearance {
        let poses = SpotPose.allCases.filter { $0 != previousPose }
        let pose = poses.randomElement(using: &generator)!
        return SpotAppearance(pose: pose, quote: pose.phrases.randomElement(using: &generator)!)
    }
}
