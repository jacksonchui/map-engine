//
//  ARController.swift
//  map-engine
//
//  Created by Lauren Go on 2019/04/18.
//  Copyright © 2019 go-lauren. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARController: UIViewController, ARSCNViewDelegate, ControlsDelegate {
    
    var sceneView: ARSCNView!
    var controls: Controls!
    var map: Map!
    var selectedPlane: Bool = false
    var currentMap: SCNNode!
    var character: SCNNode!
    var dimension: Float!
    var x, y: Int!
    var tiles: [[Graph.Tile]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map = Map(123456, 100, 50)
        
        self.view.backgroundColor = .white
        self.sceneView = ARSCNView()
        self.view.addSubview(sceneView)
        sceneView.frame = self.view.bounds

        sceneView.delegate = self
    
        sceneView.showsStatistics = true
        
        // Debugging Features
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin,
                                  ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        
        // Adding controls
        // TODO: find a good position
        self.controls = Controls(CGRect(x: 10 , y: self.view.frame.height - self.view.frame.width / 3.0 - 10, width: self.view.frame.width / 3.0, height: self.view.frame.width / 3.0))
        controls.delegate = self
        
        self.view.addSubview(controls)
        
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if (!selectedPlane) {

            guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
        
            plane.materials.first?.diffuse.contents = UIColor.red
        
            let planeNode = SCNNode(geometry: plane)
        
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
        
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if (!selectedPlane) {
            guard let planeAnchor = anchor as?  ARPlaneAnchor,
                let planeNode = node.childNodes.first,
                let plane = planeNode.geometry as? SCNPlane
                else { return }


            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            plane.width = width
            plane.height = height


            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x, y, z)
        }
    }
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARController.renderMap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func rotate(_ vector: simd_float3, _ angle: Float) -> simd_float3 {
        let rotMatrix = simd_float3x3(
            simd_float3( cos(angle), sin(angle), 0),
            simd_float3(-sin(angle), cos(angle), 0),
            simd_float3( 0,          0,          1))
        return rotMatrix * vector
    }
    
    func moved(_ direction: Controls.Movement) {
        if (!selectedPlane) { return }
        if let cameraNode: SCNNode = sceneView.pointOfView {
            var movementDirection: simd_float4
            switch(direction) {
                case Controls.Movement.Up:
                    movementDirection = simd_float4(0, 1, 0, 1)
                case Controls.Movement.Down:
                    movementDirection = simd_float4(0, -1, 0, 1)
                case Controls.Movement.Right:
                    movementDirection = simd_float4(1, 0, 0, 1)
                case Controls.Movement.Left:
                    movementDirection = simd_float4(-1, 0, 0, 1)
            }
            // get direction camera is facing in global coordinates
            var worldDirection: simd_float4 = simd_float4x4(cameraNode.transform) * movementDirection
            // we assume our planes are horizontal
//            worldDirection.z = 0
            //get direction in respect to plane
            var localDirection: simd_float3 = simd_float3(sceneView.scene.rootNode.convertVector(SCNVector3(worldDirection.x, worldDirection.y, worldDirection.z), to: currentMap))
            //normalize local vector
            localDirection.z = 0
            localDirection = simd_normalize(localDirection)
            var forwardDirection: Int = -1
            // up = 0, left = 1, right = 2,
            for i in 0..<4 {
                if (dot(localDirection, rotate(simd_float3(0, 1, 0), Float(i) * Float.pi / 2.0)) > sqrt(2.0) / 2) {
                    forwardDirection = i
                    break
                }
            }
            map.moved(forwardDirection)
        }
    }
    
//    func moved(_ direction: Int) {
//        switch (direction) {
//            case 0:
//                moved(0, 1)
//            case 1:
//                moved(-1, 0)
//            case 2:
//                moved(0, -1)
//            case 3:
//                moved(1, 0)
//            default:
//                break
//            
//        }
//    }
    
    @objc func renderMap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        guard let result = sceneView.hitTest(tapLocation, options: nil).first else { return }
        
        let tappedNode: SCNNode = result.node
            if let geometry = tappedNode.geometry as? SCNPlane {
                let (min_coord, max_coord) = tappedNode.boundingBox
                
                //2. Get It's Z Coordinate
                let zPosition = tappedNode.position.z
                
                //3. Get The Width & Height Of The Node
                let widthOfNode: CGFloat = CGFloat(max_coord.x - min_coord.x)
                let heightOfNode: CGFloat = CGFloat(max_coord.y - min_coord.y)
                
                //4. Get The Corners Of The Node
                let topLeftCorner = SCNVector3(min_coord.x, max_coord.y, zPosition)
                let bottomLeftCorner = SCNVector3(min_coord.x, min_coord.y, zPosition)
//                let topRightCorner = SCNVector3(max_coord.x, max_coord.y, zPosition)
//                let bottomRightCorner = SCNVector3(max_coord.x, min_coord.y, zPosition)
                print(topLeftCorner)
                let dimension: CGFloat = min(widthOfNode / CGFloat(map.g.w) , heightOfNode / CGFloat(map.g.h))
                self.dimension = Float(dimension)
                
                tappedNode.addChildNode(map)
                map.scale = SCNVector3(self.dimension, self.dimension, self.dimension)
                map.position = SCNVector3(0, 0, 0)
                
                geometry.materials.first?.diffuse.contents = UIColor.clear

                currentMap = tappedNode
                selectedPlane = true
            }
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

