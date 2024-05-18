//
//  AppDelegate.swift
//  ARKit Face Tracking Tutorial
//  https://facelandmarks.com/blog/arkit-face-tracking
//
//  Created by Ryan Chiang on 5/18/24.
//

import SwiftUI
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = context.coordinator
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let device = renderer.device else {
                return nil
            }
            guard let faceAnchor = anchor as? ARFaceAnchor else {
                return nil
            }
            
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            

            node.geometry?.firstMaterial?.fillMode = .lines
            
            for x in 0..<faceAnchor.geometry.vertices.count {
                if x % 2 == 0 {
                    let text = SCNText(string: "\(x)", extrusionDepth: 1)
                    let textNode = SCNNode(geometry: text)
                    textNode.scale = SCNVector3(x: 0.00025, y: 0.00025, z: 0.00025)
                    textNode.name = "\(x)"
                    
                    // Set the text color to red
                    textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                    
                    // Position the text node at the corresponding vertex
                    let vertex = SCNVector3(faceAnchor.geometry.vertices[x])
                    textNode.position = vertex
                    
                    node.addChildNode(textNode)
                }
            }
            
            return node
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let faceGeometry = node.geometry as? ARSCNFaceGeometry
            else {
                return
            }
            
            faceGeometry.update(from: faceAnchor.geometry)
        
            for x in 0..<faceAnchor.geometry.vertices.count {
                if x % 2 == 0 {
                    let textNode = node.childNode(withName: "\(x)", recursively: false)
                    let vertex = SCNVector3(faceAnchor.geometry.vertices[x])
                    textNode?.position = vertex
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
