//
//  ViewController.swift
//  IntroToARKit
//
//  Created by Ikmal Azman on 09/01/2022.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    //MARK: - Variables
    var sceneNodeItems = [SCNNode]()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - 2
        // Set the view's delegate
        sceneView.delegate = self
        // Enable auto lighting to brighten the scene
        sceneView.autoenablesDefaultLighting = true
        // Enable debugging in scene
        sceneView.debugOptions = [.showFeaturePoints]
        
        //MARK: - 3
        //        // Create box geometry, and set its property
        //        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        //        // Assign only one of the box material content
        //        box.firstMaterial?.diffuse.contents = UIColor.blue
        //        // Create a node for box
        //        let boxNode = SCNNode(geometry: box)
        //        // Position the node in based on specified coordinate
        //        boxNode.position = SCNVector3(x: 0, y: 0, z: -0.5)
        //        // Add node to root of sceneView
        //        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //MARK: - 1
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Set plane detection configuration
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //MARK: - 3
        // Pause the view's session
        sceneView.session.pause()
    }
    //MARK: - 6
    //MARK: - Actions
    @IBAction func trashTapped(_ sender: UIBarButtonItem) {
        // Remove every node from parent
        for item in sceneNodeItems {
            item.removeFromParentNode()
        }
        // Emptied node array
        sceneNodeItems = []
    }
}

//MARK: - ARSCNViewDelegate
extension ViewController : ARSCNViewDelegate {
    
    //MARK: - 4
    // Allow to create plane
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Determine if anchor detected was ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            print("Could not found any plane anchor")
            return
        }
        // Create a new plane and set it size based on plane detected
        let horizontalPlane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        // Create material for horizontal plane
        let colorMaterial = SCNMaterial()
        // Assign content with UIColor
        colorMaterial.diffuse.contents = UIColor(white: 1, alpha: 0.5)
        // Add meterial to plane
        horizontalPlane.materials = [colorMaterial]
        
        // Create a new node for horizontal plane
        let planeNode = SCNNode(geometry: horizontalPlane)
        // Specify the node position
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        // Rotate the plane in X axis, by default SceneKit plane is in vertical
        planeNode.eulerAngles.x = -.pi / 2
        // Adding node as a child node, allow to display on scene of detected plane
        node.addChildNode(planeNode)
        
        // Add plane node to array
        sceneNodeItems.append(planeNode)
    }
}
//MARK: - UITouch Events
extension ViewController {
    //MARK: - 5
    // Allow to detect touch on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the first touch on the screen
        guard let touch = touches.first else {
            print("Could not get the first touch")
            return
        }
        // Get the location of the touch (2D Coordinate) from the sceneView
        let touchLocation = touch.location(in: sceneView)
        // Make a query to convert 2D to 3D coordinate
        guard let raycastQuery = sceneView.raycastQuery(from: touchLocation,
                                                        allowing: .estimatedPlane,
                                                        alignment: .horizontal) else {
            print("Could not make raycast query to convert 2D ro 3D coordiate")
            return
        }
        // Return results from query
        let queryResults = sceneView.session.raycast(raycastQuery)
        // Get the first item in query results
        guard let result = queryResults.first else {return}
        // Create a scene for the 3D model from assets
        let houseScene = SCNScene(named: "art.scnassets/skytower.scn")!
        // Create and get the first node in 3D model
        let houseNode = houseScene.rootNode.childNodes.first!
        // Position the node based on user touch location
        houseNode.position = SCNVector3(x: result.worldTransform.columns.3.x,
                                        y: result.worldTransform.columns.3.y,
                                        z: result.worldTransform.columns.3.z)
        
        // Add house node to rootnode of the scene to display the model in your world
        sceneView.scene.rootNode.addChildNode(houseNode)
        
        
        // Add house node to array
        sceneNodeItems.append(houseNode)
    }
}
