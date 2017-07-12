//
//  GameViewController.swift
//  SKTiled
//
//  Created by Michael Fessenden on 3/21/16.
//  Copyright (c) 2016 Michael Fessenden. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController {

    @IBOutlet weak var mapInfoLabel: UILabel!
    @IBOutlet weak var tileInfoLabel: UILabel!
    @IBOutlet weak var propertiesInfoLabel: UILabel!
    
    var demoFiles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load demo files from a propertly list
        demoFiles = loadDemoFiles("DemoFiles")

        let currentFilename = demoFiles.first!

        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true

        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        setupDebuggingLabels()
        
        /* create the game scene */
        let scene = SKTiledDemoScene(size: self.view.bounds.size)

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill

        //set up notification for scene to load the next file
        NotificationCenter.default.addObserver(self, selector: #selector(loadNextScene), name: NSNotification.Name(rawValue: "loadNextScene"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadPreviousScene), name: NSNotification.Name(rawValue: "loadPreviousScene"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDebugLabels), name: NSNotification.Name(rawValue: "updateDebugLabels"), object: nil)
        
        skView.presentScene(scene)
        scene.setup(tmxFile: currentFilename)
    }
    
    /**
     Set up the debugging labels.
     */
    func setupDebuggingLabels() {
        mapInfoLabel.text = "Map: "
        tileInfoLabel.text = "Tile: "
        propertiesInfoLabel.text = "Properties:"
    }
    
    /**
     Action called when `fit to view` button is pressed.
     
     - parameter sender: `Any` ui button.
     */
    @IBAction func fitButtonPressed(_ sender: Any) {
        guard let view = self.view as? SKView,
                let scene = view.scene as? SKTiledScene else { return }

        if let cameraNode = scene.cameraNode {
            cameraNode.fitToView(newSize: view.bounds.size)
        }
    }
    
    /**
     Action called when `show grid` button is pressed.
     
     - parameter sender: `Any` ui button.
     */
    @IBAction func gridButtonPressed(_ sender: Any) {
        guard let view = self.view as? SKView,
            let scene = view.scene as? SKTiledScene else { return }

        if let tilemap = scene.tilemap {
            tilemap.baseLayer.debugDrawOptions = (tilemap.baseLayer.debugDrawOptions != []) ? [] : [.demo]
        }
    }

    /**
     Action called when `show objects` button is pressed.
     
     - parameter sender: `Any` ui button.
     */
    @IBAction func objectsButtonPressed(_ sender: Any) {
        guard let view = self.view as? SKView,
            let scene = view.scene as? SKTiledScene else { return }

        if let tilemap = scene.tilemap {
            // if objects are shown...
            if let tilemap = scene.tilemap {
                tilemap.showObjects = !tilemap.showObjects
            }
        }
    }
    
    /**
     Action called when `next` button is pressed.
     
     - parameter sender: `Any` ui button.
     */
    @IBAction func nextButtonPressed(_ sender: Any) {
        loadNextScene()
    }
    
    /**
     Reload the current scene.
     
     - parameter interval: `TimeInterval` transition duration.
     */
    func reloadScene(_ interval: TimeInterval=0.4) {
        guard let view = self.view as? SKView else { return }
        
        var debugOptions: DebugDrawOptions = []
        var liveMode = false
        var showOverlay = true
        
        var currentFilename: String! = nil
        if let currentScene = view.scene as? SKTiledDemoScene {
            if let cameraNode = currentScene.cameraNode {
                showOverlay = cameraNode.showOverlay
            }
            
            liveMode = currentScene.liveMode
            if let tilemap = currentScene.tilemap {
                debugOptions = tilemap.debugDrawOptions
                currentFilename = tilemap.filename!
            }
            
            currentScene.removeFromParent()
            currentScene.removeAllActions()
        }
        
        view.presentScene(nil)
        
        let nextScene = SKTiledDemoScene(size: view.bounds.size)
        nextScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: interval)
        view.presentScene(nextScene, transition: transition)
        
        nextScene.setup(tmxFile: currentFilename)
        nextScene.liveMode = liveMode
        nextScene.cameraNode?.showOverlay = showOverlay
        nextScene.tilemap?.debugDrawOptions = debugOptions
    }
    
    /**
     Load the next tilemap scene.

     - parameter interval: `TimeInterval` transition duration.
     */
    func loadNextScene(_ interval: TimeInterval=0.4) {
        guard let view = self.view as? SKView else { return }
        
        var debugDrawOptions: DebugDrawOptions = []
        var showOverlay = true
        
        var currentFilename = demoFiles.first!
        if let currentScene = view.scene as? SKTiledDemoScene {
            if let cameraNode = currentScene.cameraNode {
                showOverlay = cameraNode.showOverlay
            }

            if let tilemap = currentScene.tilemap {
                debugDrawOptions = tilemap.debugDrawOptions
                currentFilename = tilemap.name!
            }

            currentScene.removeFromParent()
            currentScene.removeAllActions()
        }

        view.presentScene(nil)

        var nextFilename = demoFiles.first!
        if let index = demoFiles.index(of: currentFilename) , index + 1 < demoFiles.count {
            nextFilename = demoFiles[index + 1]
        }
        
        let nextScene = SKTiledDemoScene(size: view.bounds.size)
        nextScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: interval)
        
        view.presentScene(nextScene, transition: transition)
        nextScene.setup(tmxFile: nextFilename)
        nextScene.cameraNode?.showOverlay = showOverlay
        nextScene.tilemap?.debugDrawOptions = debugDrawOptions
    }

    /**
     Load the previous tilemap scene.

     - parameter interval: `TimeInterval` transition duration.
     */
    func loadPreviousScene(_ interval: TimeInterval=0.4) {
        guard let view = self.view as? SKView else { return }

        var debugDrawOptions: DebugDrawOptions = []
        var showOverlay = true
        
        var currentFilename = demoFiles.first!
        if let currentScene = view.scene as? SKTiledDemoScene {
            if let cameraNode = currentScene.cameraNode {
                showOverlay = cameraNode.showOverlay
            }
            
            if let tilemap = currentScene.tilemap {
                debugDrawOptions = tilemap.debugDrawOptions
                currentFilename = tilemap.filename!
            }
            
            currentScene.removeFromParent()
            currentScene.removeAllActions()
        }

        view.presentScene(nil)

        var nextFilename = demoFiles.last!
        if let index = demoFiles.index(of: currentFilename), index > 0, index - 1 < demoFiles.count {
            nextFilename = demoFiles[index - 1]
        }

        let nextScene = SKTiledDemoScene(size: view.bounds.size)
        nextScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: interval)
        view.presentScene(nextScene, transition: transition)
        
        nextScene.setup(tmxFile: nextFilename)
        nextScene.cameraNode?.showOverlay = showOverlay
        nextScene.tilemap?.debugDrawOptions = debugDrawOptions
    }

    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    /**
     Load TMX files from the property list.

     - returns: `[String]` array of tiled file names.
     */
    fileprivate func loadDemoFiles(_ filename: String) -> [String] {
        var result: [String] = []
        if let fileList = Bundle.main.path(forResource: filename, ofType: "plist"){
            if let data = NSArray(contentsOfFile: fileList) as? [String] {
                result = data
            }
        }
        return result
    }
    
    /**
     Update the debugging labels with scene information.
     
     - parameter notification: `Notification` notification.
     */
    func updateDebugLabels(notification: Notification) {
        if let mapInfo = notification.userInfo!["mapInfo"] {
            mapInfoLabel.text = mapInfo as? String
        }
        
        if let tileInfo = notification.userInfo!["tileInfo"] {
            tileInfoLabel.text = tileInfo as? String
        }
        
        if let propertiesInfo = notification.userInfo!["propertiesInfo"] {
            propertiesInfoLabel.text = propertiesInfo as? String
        }
    }
}
