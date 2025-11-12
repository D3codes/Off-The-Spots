//
//  MailView.swift
//  Off The Spots
//
//  Created by David Freeman on 7/16/25.
//

import SwiftUI
import MessageUI
import UIKit

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss

    class Coordinator: NSObject, @MainActor MFMailComposeViewControllerDelegate {
        let parent: MailView
        init(_ parent: MailView) { self.parent = parent }
        @MainActor func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = context.coordinator
            vc.setToRecipients(["david@d3.codes"])
            vc.setSubject("Feedback for Off The Spots")
            return vc
        } else {
            // Fallback view explaining the situation; dismiss or guide user.
            let fallback = UIHostingController(
                rootView: MailNotAvailableView(dismiss: { dismiss() })
            )
            return fallback
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct MailNotAvailableView: View {
    @Environment(\.openURL) var openURL
    
    var dismiss: () -> Void = { }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Mail Not Available")
                .font(.headline)
            
            Text("This device isn’t configured to send mail. Please set up a Mail account or send feedback using the link below:")
                .multilineTextAlignment(.center)
            
            Button(action: { openURL(URL(string: "https://d3.codes/contact/")!) } ) {
                Text("Contact Me")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    Text("HI")
        .sheet(isPresented: .constant(true)) {
            MailView()
        }
}
