//
//  WavyHeader.swift
//  FronTIER
//
//  Created by Z on 11/17/24.
//


import SwiftUI

struct WavyHeader: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Start at the top-left corner
        path.move(to: CGPoint(x: 0, y: 0))

        // Draw a straight line to the top-right corner
        path.addLine(to: CGPoint(x: rect.width, y: 0))

        // Draw the wave curve
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height),
            control1: CGPoint(x: rect.width * 0.75, y: rect.height * 1.5),
            control2: CGPoint(x: rect.width * 0.25, y: rect.height * 0.5)
        )

        // Close the path
        path.closeSubpath()

        return path
    }
}

struct WavyHeader_Previews: PreviewProvider {
    static var previews: some View {
        WavyHeader()
            .fill(Color.green) // Preview with green color
            .frame(height: 150)
            .padding()
    }
}
