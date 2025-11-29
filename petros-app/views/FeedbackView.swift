//
//  FeedbackView.swift
//  petros-app
//
//  Created by Auto on 1/15/25.
//

import SwiftUI

struct FeedbackView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String? = nil
    
    private let feedbackService = FeedbackService.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("We'd love to hear from you!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Name")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("Your name", text: $name)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("Your email", text: $email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Feedback2")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .topLeading) {
                        
//                                TextField("Your feedback, suggestion, bug report, or question...", text: $message,  axis: .vertical)
//                                    .lineLimit(5...10)
                        TextField("Feedback2", text: $message)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                    
                    }
                }
                .padding(.horizontal, 24)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 24)
                }
                
                Button(action: submitFeedback) {
                    HStack(spacing: 8) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text("Submitting...")
                                .fontWeight(.semibold)
                        } else if showSuccess {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Feedback submitted!")
                                .fontWeight(.semibold)
                        } else {
                            Text("Submit Feedback")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        showSuccess ? Color.green :
                        (isFormValid && !isSubmitting ? Color(red: 0.1, green: 0.2, blue: 0.6) : Color.gray)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!isFormValid || isSubmitting || showSuccess)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white)
        }
        .background(Color.white)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func submitFeedback() {
        guard isFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        let feedback = Feedback(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: Date()
        )
        
        Task {
            let result = await feedbackService.submitFeedback(feedback)
            
            await MainActor.run {
                isSubmitting = false
                
                if result.success {
                    // Clear form immediately
                    name = ""
                    email = ""
                    message = ""
                    
                    // Show success message
                    showSuccess = true
                    
                    // Reset success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showSuccess = false
                    }
                } else {
                    errorMessage = result.error?.localizedDescription ?? "Failed to submit feedback. Please try again."
                }
            }
        }
    }
}


