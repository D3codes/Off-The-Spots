//
//  RandomSpotView.swift
//  Off The Spots
//
//  Created by David Freeman on 10/28/26.
//

import SwiftUI

struct RandomSpotView: View {
    
    let spotPhrases: [String] = [
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
    
    let sleepingPhrases: [String] = [
        "I’ve practiced all the rests.",
        "Wake me for the key change.",
        "I’m not asleep. I’m holding a very long rest.",
    ]
    
    let barbershopPhrases: [String] = [
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
    
    let spotImages: [Image] = [
        Image("spot"),
        Image("escaping-notes"),
        Image("fetch-a-song"),
        Image("pointing"),
        Image("practicing-the-rests"),
        Image("tiny-rehearsal-stage"),
        Image("waiting-for-rehearsal"),
        Image("spot-barbershop")
    ]
    
    let sleeping: Int = 4
    let barbershop: Int = 7
    
    var body: some View {
        let index = Int.random(in: 0..<spotImages.count)
        
        spotImages[index]
            .resizable()
            .scaledToFit()
            .frame(width: 300)
        
        switch index {
        case sleeping:
            Text("\(String(describing: sleepingPhrases.randomElement()!))")
        case barbershop:
            Text("\(String(describing: barbershopPhrases.randomElement()!))")
        default:
            Text("\(String(describing: spotPhrases.randomElement()!))")
        }
    }
}

#Preview {
    RandomSpotView()
}
