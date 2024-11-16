import SwiftUI

struct ChatView: View {
    @State private var messages: [String] = [] // Stores conversation history
    @State private var inputText: String = "" // User input
    @State private var isSending: Bool = false // Tracks message sending status

    private let darkBlue: Color = Color(hex: "#3D0100") // Dark Blue Background
    private let lightBlue: Color = Color(hex: "#85C1E9") // Light Blue for User Messages
    private let botMessageColor: Color = Color(hex: "#F2F3F4") // Grayish White for Bot Messages
    private let gradientColors: [Color] = [Color(hex: "#3D0100"), Color(hex: "#D10000")] // Gradient for Input

    var body: some View {
        NavigationView { // Embed the entire view inside a NavigationView
            VStack {
                
                // Chat Display Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages, id: \.self) { message in
                            if message.starts(with: "You: ") {
                                // User Message
                                Text(message.replacingOccurrences(of: "You: ", with: ""))
                                    .padding()
                                    .background(lightBlue)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            } else if message.starts(with: "Bot: ") {
                                // Bot Message
                                Text(message.replacingOccurrences(of: "Bot: ", with: ""))
                                    .padding()
                                    .background(botMessageColor)
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                // Error or Generic Message
                                Text(message)
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                }
                .background(darkBlue)

                // Input Area with Gradient
                HStack {
                    TextField("Type your message...", text: $inputText)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .disabled(isSending)

                    Button(action: sendMessage) {
                        Text("Send")
                            .padding()
                            .background(isSending || inputText.isEmpty ? Color.gray : darkBlue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(inputText.isEmpty || isSending)
                }
                .padding()
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(darkBlue.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Chat", displayMode: .inline) // Set the title of the navigation bar
            .navigationBarBackButtonHidden(false) // Ensure the back button is visible
        }
    }

    func sendMessage() {
        guard !inputText.isEmpty else { return }
        isSending = true
        let userMessage = inputText
        messages.append("You: \(userMessage)")
        inputText = ""

        Chatbot.shared.sendMessage(userMessage) { response, error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    messages.append("Error: \(error.localizedDescription)")
                } else if let response = response {
                    messages.append("Bot: \(response)")
                }
            }
        }
    }
}
