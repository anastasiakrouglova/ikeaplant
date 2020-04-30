//  ViewController.swift
//  IKEAplant
//
//  Created by Nastya Krouglova on 28/03/2019.
//  Copyright © 2019 Nastya Krouglova. All rights reserved.

import UIKit
import ARKit
import SceneKit
import SwiftyJSON
import Lottie

class ViewController: UIViewController {
    
    // MARK: IBOULETS and variables
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var searchingLabel: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    var yellowPlane: YellowPlane?
    var plantenTeller: Int = 0;
    var gettedId: Int=0;
    var plants:AllPlants?
    
    private var screenCenter: CGPoint!
    private var modelNode: SCNNode!
    private var originalRotation: SCNVector3?
    private var selectedNode: SCNNode?
    
    let session = ARSession()
    let sessionConfiguration: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        return config
    }()
    
    @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
        // See if we tapped on a plane where a model can be placed
        let results = sceneView.hitTest(screenCenter, types: .existingPlane)
        guard let transform = results.first?.worldTransform else { return }
        
        // Find the position to place the model
        let position = float3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        
        // Create a copy of the model set its position/rotation
        let newNode = modelNode.flattenedClone()
        newNode.simdPosition = position
        plantenTeller += 1;
        
        if(plantenTeller > 0) {
            let originalObject = modelNode
            originalObject?.opacity = 0;
        }
        // Add the model to the scene
        sceneView.scene.rootNode.addChildNode(newNode)
    }
    
    @objc private func viewPanned(_ gesture: UIPanGestureRecognizer) {
        // Find the location in the view
        let location = gesture.location(in: sceneView)
        
        switch gesture.state {
        case .began:
            // Choose the node to move
            selectedNode = node(at: location)
        case .changed:
            // Move the node based on the real world translation
            guard let result = sceneView.hitTest(location, types: .existingPlane).first else { return }
            
            let transform = result.worldTransform
            let newPosition = float3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            selectedNode?.simdPosition = newPosition
        default:
            // Remove the reference to the node
            selectedNode = nil
        }
    }
    
    @objc private func viewRotated(_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        guard let node = node(at: location) else { return }
        
        switch gesture.state {
        case .began:
            originalRotation = node.eulerAngles
        case .changed:
            guard var originalRotation = originalRotation else { return }
            originalRotation.y -= Float(gesture.rotation)
            node.eulerAngles = originalRotation
        default:
            originalRotation = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenCenter = view.center
    
        // Update 60 frames per second (recommended by apple)
        sceneView.preferredFramesPerSecond = 60
        
        startAnimation();
        addPlantToSceneView()
        configureLighting()
        addTapGestureToSceneView()
        trackGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Pause ARKit white the view is gone
        sceneView.session.pause()
        
        super.viewWillDisappear(animated)
    }
    
    func setUpSceneView(){
        // Make sure that ARKit is supported
        if ARWorldTrackingConfiguration.isSupported {
            sceneView.delegate = self;
            sceneView.session.run(sessionConfiguration, options:
                [.removeExistingAnchors, .resetTracking])
            
        } else {
            print("Sorry, your device doesn't support ARKit")
        }
    }
    
    func configureLighting(){
        // Use default lighting so that our plants are illuminated
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
    }
    
    func addTapGestureToSceneView(){
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
    sceneView.addGestureRecognizer(tapGesture)
    }
    
    func addPlantToSceneView(){
        guard let modelScene = SCNScene(named: "\(gettedId).scn") else {
            print("Couldn't find the model")
            return  }
        
            modelNode = modelScene.rootNode
            modelNode.scale = SCNVector3(0.01, 0.01, 0.01)
            modelNode.transform = SCNMatrix4Rotate(modelNode.transform, Float.pi / 2.0, 1.0, 0.0, 0.0)
    }
    
    func trackGestures(){
        // Track pans on the screen
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPanned))
        sceneView.addGestureRecognizer(panGesture)
        
        // Track rotation gestures on the screen
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(viewRotated))
        sceneView.addGestureRecognizer(rotationGesture)
    }
    
    private func node(at position: CGPoint) -> SCNNode? {
        return sceneView.hitTest(position, options: nil)
            .first(where: { $0.node !== yellowPlane && $0.node !== modelNode})?
            .node
    }
    
    // Loading json
    func loadJSON(){
        let url = Bundle.main.url(forResource: "plants", withExtension: "json")
        
        if let path = url{
            do {
                let data = try Data(contentsOf: path)
                let result = try JSON(data: data)
                parseJSON(json: result)
            } catch{
                print("ERROR: JSON DATA CAN NOT BE LOADED")
            }
        } else {
            print("ERROR: PATH TO JSON IS NOT CORRECT")
        }
    }
    
    func parseJSON(json: JSON){
        var tempList:[Plant] = [];
        for (_,subJSON) in json["plants"]{
            let item: Plant = Plant(id: subJSON["id"].intValue, plantName: subJSON["plantName"].stringValue, price: subJSON["price"].stringValue,temperature: subJSON["temperature"].stringValue, plantable: subJSON["plantable"].boolValue, height: subJSON["height"].stringValue, number: subJSON["number"].stringValue, country: subJSON["country"].stringValue)
            tempList.append(item)
        }
        plants = AllPlants(plantList: json["plantList"].stringValue, list: tempList)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func startAnimation(){
        let animation = Animation.named("plantAnimation")
        animationView.animation = animation
        
        animationView.play(fromProgress: 0, toProgress: 0.2, loopMode: LottieLoopMode.autoReverse,
                           completion: { (finished) in
                            if finished {
                                print("Animation Complete")
                            } else {
                                print("Animation cancelled")
                            }
        })
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Hide the label (make sure we're on the main thread)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.searchingLabel.alpha = 0.0
                self.animationView.alpha = 0.0
                }, completion: { _ in
                    self.searchingLabel.isHidden = true
                    self.animationView.isHidden = true;
                })
        }

        // If we have already created the focal node we should not do it again
        guard yellowPlane == nil else {return}
        
        // Create a new focal node
        let node = YellowPlane();
        node.addChildNode(modelNode);
        
        // Add it to the root of our current scene
        sceneView.scene.rootNode.addChildNode(node)

        // Store the focal node
        self.yellowPlane = node;
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // If we haven't established a focal node yet do not update
        guard let yellowPlane = yellowPlane else { return }
        
        // Determine if we hit a plane in the scene
        let hit = sceneView.hitTest(screenCenter, types: .existingPlane)
        
        // Find the position of the first plane we hit
        guard let positionColumn =
            hit.first?.worldTransform.columns.3 else {return}
        
        // Update the position of the node
        yellowPlane.position = SCNVector3(x: positionColumn.x, y: positionColumn.y, z: positionColumn.z)
    }
}

class YellowPlane: SCNNode {
    let size: CGFloat = 0.1
    let segmentWidth: CGFloat = 0.004
    
    private let colorMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        return material
    }()
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func createSegment(width: CGFloat, height: CGFloat) -> SCNNode {
        let segment = SCNPlane(width: width, height: height)
        segment.materials = [colorMaterial]
        
        return SCNNode(geometry: segment)
    }
    
    private func addHorizontalSegment(dx: Float) {
        let segmentNode = createSegment(width: segmentWidth,  height: size)
        segmentNode.position.x += dx
        
        addChildNode(segmentNode)
    }
    
    private func addVerticalSegment(dy: Float) {
        let segmentNode = createSegment(width: size, height: segmentWidth)
        segmentNode.position.y += dy
        
        addChildNode(segmentNode)
    }
    
    private func setup() {
        let dist = Float(size) / 2.0
        addHorizontalSegment(dx: dist)
        addHorizontalSegment(dx: -dist)
        addVerticalSegment(dy: dist)
        addVerticalSegment(dy: -dist)
        
        //rotate the node so the square is flat against the floor
        transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
    }
}
