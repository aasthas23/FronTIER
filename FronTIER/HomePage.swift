//
//  HomePage.swift
//  FronTIER
//
//  Created by Z on 11/16/24.
//

import SwiftUI
import Foundation

func loadCSV(fileName: String) -> [[String: String]]? {
    // Get the file path from the main bundle
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
        print("File not found in the bundle")
        return nil
    }

    do {
        // Load the file's content into a string
        let content = try String(contentsOfFile: filePath)
        
        // Split the content into rows
        let rows = content.components(separatedBy: "\n").filter { !$0.isEmpty }

        // Extract the header row
        guard let header = rows.first?.components(separatedBy: ",") else {
            print("Header row not found in the CSV")
            return nil
        }

        // Parse the rows into dictionaries
        var results: [[String: String]] = []
        for row in rows.dropFirst() {
            let values = row.components(separatedBy: ",")
            //print("Values:, \(values)")
            if values.count == header.count {
                let dictionary = Dictionary(uniqueKeysWithValues: zip(header, values))
                results.append(dictionary)
            }
        }

        return results
    } catch {
        print("Error reading the CSV file: (error)")
        return nil
    }
}

struct HomePage: View {
    //var user: String
    
    
    @State private var animateGradient: Bool = false
    @State private var fillPercentage: CGFloat = 0 // Controls the fill
    
    @State private var customerData: [[String: String]] = [] // Store parsed CSV data
    @State private var acctID = ""
    @State private var extenders = 0
    @State private var wiredDevices = 0
    @State private var wirelessDevices = 0
    @State private var networkSpeed = ""
    @State private var recommendation1 = ""
    @State private var recommendation2 = ""
    @State private var recommendation3 = ""
    
    private let redColor: Color = Color(hex: "#3D0100")
    private let whiteColor: Color = Color(hex: "#D10000")
    
    let users = ["Axgrav05", "Srivatt18", "Zoralah", "Aasthas23"]
    
    var body: some View {
        ScrollView { // Add ScrollView to make the content scrollable
            VStack {
                NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "#DFE0DC"), lineWidth: 3)
                            .frame(width: 50, height: 50)
                            .contentShape(Circle())
                        
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(hex: "#DFE0DC"))
                    }
                }
            }
            
            .padding(.leading, -160)
            
            VStack(spacing: 20) {
                Text("Welcome, \(globalUser)")
                    .bold()
                    //.padding(.top, 45)
                    //.fontDesign(.serif)
                    .foregroundStyle(Color(hex: "#FCFCFC"))
                    .font(.system(size: 50))
                ZStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: 0.5)  // Fill based on the percentage
                            .stroke(Color(hex: "#FCFCFC"), lineWidth: 30) // Fill the circle with the hex color
                            .rotationEffect(.degrees(180)) // Rotate to start from the top
                            //.animation(.easeInOut(duration: 2), value: fillPercentage) // Animate the fill
                            .frame(width: 240, height: 240) // Define the size of the circle
                            .shadow(color: .black, radius: 2, x: 0, y: 0) // Apply shadow
                            //.offset(y: -5)
                        Circle()
                            .trim(from: 0, to: self.fillPercentage)  // Fill based on the percentage
                            .stroke(Color(hex: "#D10000"), lineWidth: 10) // Fill the circle with the hex color
                            .rotationEffect(.degrees(180)) // Rotate to start from the top
                            .animation(.easeInOut(duration: 2), value: fillPercentage) // Animate the fill
                            .frame(width: 240, height: 240) // Define the size of the circle
                            //.shadow(color: .black, radius: 2, x: 0, y: 0) // Apply shadow
                            .offset(y: -3)
                        
                        Text("\(networkSpeed)") // CHANGE THIS TO DRAW FROM DATABASE
                            .bold()
                            //.padding(.top, 45)
                            .foregroundStyle(Color(hex: "#FCFCFC"))
                            .font(.system(size: 40))
                            .padding(.top, -60)
                    }
                    .onAppear { // CHANGE THIS TO DRAW FROM DATABASE
                        // Start the animation once the view appears
                        self.fillPercentage = 0.5 // Change this to 1 to fill the circle
                    }
                    
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "#212227")) // Fill the rectangle with the hex color
                                .frame(width: 125, height: 100) // Define the size of the rectangle
                                .cornerRadius(10)
                                .shadow(color: .black, radius: 5, x: 0, y: 5) // Apply shadow
                            Text("Extenders:")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 24))
                                .padding(.top, -45)
                            Text("\(extenders)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 40))
                                .padding(.top, 30)
                        }
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "#212227")) // Fill the rectangle with the hex color
                                .frame(width: 125, height: 100) // Define the size of the rectangle
                                .cornerRadius(10)
                                .padding(.leading, 5)
                                .shadow(color: .black, radius: 5, x: 0, y: 5) // Apply shadow
                            Text("Wireless:")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 24))
                                .padding(.leading, 5)
                                .padding(.top, -45)
                            Text("\(wirelessDevices)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 40))
                                .padding(.leading, 5)
                                .padding(.top, 30)
                        }
                        ZStack {
                            Rectangle()
                                .fill(Color(hex: "#212227")) // Fill the rectangle with the hex color
                                .frame(width: 125, height: 100) // Define the size of the rectangle
                                .cornerRadius(10)
                                .padding(.leading, 5)
                                .shadow(color: .black, radius: 5, x: 0, y: 5) // Apply shadow
                            Text("Wired:")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 24))
                                .padding(.leading, 5)
                                .padding(.top, -45)
                            Text("\(wiredDevices)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 40))
                                .padding(.leading, 5)
                                .padding(.top, 30)
                        }
                    }
                    .padding(.top, 175)
                }
                
                ZStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 10) {
                            let recommendations = [recommendation1, recommendation2, recommendation3]
                            ForEach(0..<recommendations.count, id: \.self) { index in
                                VStack(spacing: 10) {
                                    Text("Recommended Product \(index + 1):")
                                        .foregroundColor(Color(hex: "#212227")) // Text color
                                        .bold()
                                        .font(.system(size: 30))
                                        .frame(width: 365, height: 50)
                                        .background(Color(hex: "#FCFCFC"))
                                        .cornerRadius(8)
                                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                                    
                                    Text(recommendations[index])
                                        .foregroundColor(Color(hex: "#212227")) // Text color
                                        .bold()
                                        .font(.system(size: 30))
                                        .frame(width: 365, height: 275)
                                        .background(Color(hex: "#FCFCFC"))
                                        .cornerRadius(8)
                                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }

                    .frame(width: 400, height: 350) // Fit ScrollView inside the Rectangle
                    .background(Color(hex: "#212227")) // Background color for the ScrollView
                    .cornerRadius(10)
                    .shadow(color: .black, radius: 5, x: 0, y: 0) // Apply shadow
                }

                HStack {
                    // "Question?" Button
                    NavigationLink(destination: ChatbotUI().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Rectangle()
                                .frame(width: 275, height: 50) // Button size
                                .background(Color(hex: "#212227"))
                                .cornerRadius(10) // Rounded corners for the button
                                .shadow(color: .black, radius: 5, x: 0, y: 5) // Apply shadow
                            
                            Text("Question?")
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures text fits
                                .foregroundColor(Color(hex: "#FCFCFC")) // Text color
                                .bold()
                                .font(.system(size: 30))
                        }
                    }

                    // Spacer to add distance between the two buttons
                    Spacer()
                        .frame(width: 20) // Adjust the spacing between buttons

                    // AR Button
                    NavigationLink(destination: ARModel().navigationBarBackButtonHidden(true)) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#212227")) // Fill the circle with the hex color
                                .frame(width: 60, height: 60) // Define the size of the circle
                                .shadow(color: .black, radius: 2, x: 0, y: 5) // Apply shadow

                            Image(systemName: "arkit")
                                .foregroundColor(Color(hex: "#FCFCFC"))
                                .font(.system(size: 30))
                        }
                    }
                }
                .padding(.horizontal, 30) // Add padding to the entire HStack to center it

                .padding(.leading, -50)
                
            }
            .padding() // Add padding inside the ScrollView
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.black)
        .multilineTextAlignment(.center)
        .background(
            LinearGradient(
                colors: animateGradient ? [whiteColor, redColor] : [redColor, whiteColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
            .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            animateGradient = true
            
            loadData() // Load CSV data
            
            if let userIndex = users.firstIndex(of: globalUser) {
                let firstCustomer = customerData[userIndex]// Assume you want the first customer's data
                acctID = firstCustomer["acct_id"] ?? "Unknown"
                //globalUser = acctID
                extenders = Int(firstCustomer["extenders"] ?? "0") ?? 0
                wiredDevices = Int(firstCustomer["wired_clients_count"] ?? "0") ?? 0
                wirelessDevices = Int(firstCustomer["wireless_clients_count"] ?? "0") ?? 0
                networkSpeed = firstCustomer["network_speed"] ?? "Unknown"
                recommendation1 = firstCustomer["Recommendation 1"] ?? "Unknown"
                recommendation2 = firstCustomer["Recommendation 2"] ?? "Unknown"
                recommendation3 = firstCustomer["Recommendation 3\r"] ?? "Unknown"
            }
        }
    }
    
    func loadData() {
        if let data = loadCSV(fileName: "current_customers") {
            customerData = data
        } else {
            print("Failed to load CSV data.")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex)
        
        if hex.hasPrefix("#") {
            scanner.currentIndex = hex.index(after: hex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue >> 16) & 0xFF) / 255.0
        let g = Double((rgbValue >> 8) & 0xFF) / 255.0
        let b = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
