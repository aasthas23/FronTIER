import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedProduct: String?
    @Binding var refreshARView: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins]
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        if refreshARView {
            uiView.scene.anchors.removeAll()
        }

        if let productName = selectedProduct {
            uiView.scene.anchors.removeAll()
            do {
                let productEntity = try ModelEntity.load(named: productName)
                let anchor = AnchorEntity(plane: .horizontal)
                productEntity.scale = [0.0075, 0.0075, 0.0075]
                anchor.addChild(productEntity)
                uiView.scene.addAnchor(anchor)
            } catch {
                print("Failed to load model: \(productName)")
            }
        }
    }
}
