////
////  SignInPage.swift
////  FronTIER
////
////  Created by Z on 11/17/24.
////
//
//
//import SwiftUI
//
//var globalUser: String = ""
//
//struct SignInPage: View {
//    @State private var animateGradient: Bool = false
//    @State private var username: String = "" // State variable for TextField binding
//    @State private var showAlert: Bool = false // Alert state for submit action
//    @State private var alertMessage: String = "" // Custom alert message
//    @State private var navigateToHome: Bool = false // State for navigation
//    
//    private let redColor: Color = Color(hex: "#3D0100")
//    private let whiteColor: Color = Color(hex: "#D10000")
//    private let raisinBlack: Color = Color(hex: "#212227")
//    private let lightGrey: Color = Color(hex: "#3B3D47") // Raisin Black color
//    
//    var body: some View {
//        ZStack {
//            // Animated gradient background
//            LinearGradient(
//                colors: animateGradient ? [whiteColor, redColor] : [redColor, whiteColor],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
//            .edgesIgnoringSafeArea(.all)
//            
//            VStack(spacing: 0) {
//                // Header with WavyHeader and Logo
//                ZStack {
//                    WavyHeader()
//                        .fill(raisinBlack) // Apply Raisin Black color
//                        .frame(height: 750) // Wavy header height
//                        .edgesIgnoringSafeArea(.top)
//                    
//                    // Logo with adjustable size
//                    Image("logo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 350, height: 705) // Adjust the logo size here
//                        .padding(.top, -100) // Adjust padding as needed
//                }
//                
//                // TextField Section
//                TextField("Login Using Frontier User ID", text: $username)
//                    .padding()
//                    .foregroundColor(.white)
//                    .background(lightGrey.opacity(0.6)) // Semi-transparent background
//                    .cornerRadius(35) // Rounded corners for semi-circle effect
//                    .frame(width: 330) // Adjust width
//                    .overlay(
//                        Group {
//                            if username.isEmpty {
//                                Text("Login Using Frontier User ID...")
//                                    .foregroundColor(.white.opacity(0.5)) // Placeholder text color
//                                    .padding(.leading, 20)
//                            }
//                        },
//                        alignment: .leading
//                    )
//                    .padding(.top, -300) // Space below the wavy header
//                
//                // Submit Button
//                Button(action: {
//                    validateUsername()
//                }) {
//                    Text("Submit")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(width: 150, height: 50) // Match design dimensions
//                        .background(raisinBlack)
//                        .cornerRadius(20) // Rounded corners
//                        .opacity(0.8)
//                }
//                .alert(isPresented: $showAlert) {
//                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//                }
//                .padding(.top, 30) // Space between TextField and button
//                
//                // Navigation to HomePage
//                NavigationLink(destination: HomePage().navigationBarBackButtonHidden(true), isActive: $navigateToHome) {
//                    EmptyView()
//                }
//                
//                Spacer() // Push content upward
//            }
//        }
//        .onAppear {
//            animateGradient = true
//        }
//    }
//    
//    // Function to validate username
//    private func validateUsername() {
//        globalUser = username
//        guard let filePath = Bundle.main.path(forResource: "usernames", ofType: "csv") else {
//            alertMessage = "Usernames file not found."
//            showAlert = true
//            return
//        }
//        
//        do {
//            let content = try String(contentsOfFile: filePath)
//            let usernames = content.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//            
//            if usernames.contains(username) {
//                navigateToHome = true
//            } else {
//                alertMessage = "Invalid username. Please try again."
//                showAlert = true
//            }
//        } catch {
//            alertMessage = "Failed to load usernames."
//            showAlert = true
//        }
//    }
//}
//
////extension Color {
////    init(hex: String) {
////        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
////        let scanner = Scanner(string: hex)
////        
////        if hex.hasPrefix("#") {
////            scanner.currentIndex = hex.index(after: hex.startIndex)
////        }
////        
////        var rgbValue: UInt64 = 0
////        scanner.scanHexInt64(&rgbValue)
////        
////        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
////        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
////        let b = Double(rgbValue & 0xFF) / 255.0
////        
////        self.init(red: r, green: g, blue: b)
////    }
////}
//
//struct SignInPage_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SignInPage()
//        }
//    }
//}
