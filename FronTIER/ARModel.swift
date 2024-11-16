import SwiftUI
import RealityKit
import ARKit

struct ARModel: View {
    @State private var selectedProduct: String? = nil
    @State private var showProductPicker = false
    @State private var refreshARView = false

    // Environment variable to dismiss the view
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            ARViewContainer(selectedProduct: $selectedProduct, refreshARView: $refreshARView)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Button(action: {
                        // Manually dismiss the view
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 40, height: 40)
                            Image(systemName: "arrow.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    Spacer()
                }

                Spacer()

                Button("Choose Product") { showProductPicker = true }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                Button("Remove Model") {
                    selectedProduct = nil
                    refreshARView.toggle()
                }
                .padding()
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showProductPicker) {
            ProductPicker(selectedProduct: $selectedProduct, refreshARView: $refreshARView)
        }
    }
}





// Product Picker Sheet
struct ProductPicker: View {
    @Binding var selectedProduct: String?
    @Binding var refreshARView: Bool

    let products = ["cup_saucer_set.usdz", "Extender.usdz", "guitar.usdz", "Router.usdz"] // Replace with actual file names

    var body: some View {
        NavigationView {
            List(products, id: \.self) { product in
                Button {
                    selectedProduct = product
                    refreshARView.toggle() // Force ARView update
                    print("Selected product: \(product)")
                } label: {
                    Text(product)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                }
            }
            .navigationTitle("Select a Product")
        }
    }
}

#Preview {
    ARModel()
}

