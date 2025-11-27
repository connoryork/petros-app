//
//  FeedbackView.swift
//  petros-app
//
//  Created by Auto on 1/15/25.
//

import SwiftUI

struct FeedbackView: View {
    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var message: String = ""
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String? = nil
    
    private let feedbackService = FeedbackService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if showSuccess {
                    SuccessMessage()
                        .padding(.top, 32)
                } else {
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
                            Text("Contact")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextField("Email or phone", text: $contact)
                                .textFieldStyle(.plain)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feedback")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $message)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }
                        
                        Button(action: submitFeedback) {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Submit Feedback")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isFormValid && !isSubmitting ? Color(red: 0.1, green: 0.2, blue: 0.6) : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || isSubmitting)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func submitFeedback() {
        guard isFormValid && !isSubmitting else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        let feedback = Feedback(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            contact: contact.trimmingCharacters(in: .whitespacesAndNewlines),
            message: message.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: Date()
        )
        
        Task {
            let result = await feedbackService.submitFeedback(feedback)
            
            await MainActor.run {
                isSubmitting = false
                
                if result.success {
                    showSuccess = true
                    name = ""
                    contact = ""
                    message = ""
                    
                    // Reset success message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        showSuccess = false
                    }
                } else {
                    errorMessage = result.error?.localizedDescription ?? "Failed to submit feedback. Please try again."
                }
            }
        }
    }
}

private struct SuccessMessage: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
            
            Text("Thank you!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your feedback has been submitted successfully.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

