import SwiftUI

struct ChatbotUI: View {
    @State private var animateGradient: Bool = false
    
    private let blueColor: Color = Color(hex: "#212227")
    private let whiteColor: Color = Color(hex: "#4C526F")
    @State private var messages: [Message] = [] // Chat messages
    @State private var inputText: String = ""  // User input
    @State private var isSending: Bool = false // Sending state
    
    @Environment(\.dismiss) private var dismiss // To dismiss the current view

    var body: some View {
        VStack {
            // Back Button
            HStack {
                Button(action: {
                    dismiss() // Programmatically dismiss the view
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50) // Adjust the size
                        .foregroundColor(.white)
                }
                .padding(.leading, 20)
                .padding(.top, 10)

                Spacer()
            }
            
            // Chat Display Area
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(maxHeight: .infinity) // Ensure the scroll view uses all available space

            // Input Field
            HStack {
                TextField("Type your message...", text: $inputText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
                    .disabled(isSending)

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(inputText.isEmpty || isSending ? Color.gray : Color.red)
                        .cornerRadius(16)
                }
                .disabled(inputText.isEmpty || isSending)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: animateGradient ? [whiteColor, blueColor] : [blueColor, whiteColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            animateGradient = true
        }
    }

    // Function to send a message
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        isSending = true

        // Add user message
        let userMessage = Message(id: UUID(), text: inputText, isUser: true)
        messages.append(userMessage)

        // Capture input and clear the field
        let userInput = inputText
        inputText = ""

        // Simulate a chatbot response
        Chatbot.shared.sendMessage(userInput) { response, error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    // Handle errors
                    let errorMessage = Message(id: UUID(), text: "Error: \(error.localizedDescription)", isUser: false)
                    messages.append(errorMessage)
                } else if let response = response {
                    // Add the bot's response
                    let botMessage = Message(id: UUID(), text: response, isUser: false)
                    messages.append(botMessage)
                }
            }
        }
    }
}

// Message Model
struct Message: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
}

// Preview
struct ChatbotUI_Previews: PreviewProvider {
    static var previews: some View {
        ChatbotUI()
    }
}
