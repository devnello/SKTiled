//
//  TiledDemoDelegate.swift
//  SKTiled Demo - macOS
//
//  Copyright © 2020 Michael Fessenden. all rights reserved.
//	Web: https://github.com/mfessenden
//	Email: michael.fessenden@gmail.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.

import Cocoa
import SpriteKit


typealias NodeList = ThreadSafeArray<SKNode>


/// Manages demo scene geometry for macOS demo.
public class TiledDemoDelegate: NSObject, Loggable {
        
    /// Currently focused nodes.
    var currentNodes = NodeList()
    
    /// Receive camera updates from camera.
    @objc public var receiveCameraUpdates: Bool = true
    
    /// The current demo camera zoom level.
    public var currentCameraZoom: CGFloat = 1
    
    /// Default singleton instance.
    static var `default`: TiledDemoDelegate {
        return defaultDemoDelegate
    }
    
    // MARK: - Init
    
    /// Default initializer.
    public override init() {
        super.init()
        setupNotifications()
    }
    
    deinit {
        // remove notifications
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Map.FocusCoordinateChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Demo.NodesRightClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Demo.SceneWillUnload, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Demo.FlushScene, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Demo.NodeSelectionChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Globals.Updated, object: nil)
    }
    
    /// Reset the delegate.
    func reset() {
        // reset focused nodes
        defer {
            currentNodes.removeAll()
        }
        currentNodes.forEach { node in
            node.highlightNode(with: .clear)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(focusedCoordinateChanged), name: Notification.Name.Map.FocusCoordinateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillUnloadAction), name: Notification.Name.Demo.SceneWillUnload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneWillUnloadAction), name: Notification.Name.Demo.FlushScene, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nodeSelectionChanged), name: Notification.Name.Demo.NodeSelectionChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mouseRightClickAction), name: Notification.Name.Demo.MouseRightClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(globalsUpdatedAction), name: Notification.Name.Globals.Updated, object: nil)
    }
       
    // MARK: - Handlers
        
    /// Handles the `Notification.Name.Map.FocusCoordinateChanged` callback.
    ///
    ///   - expects a user dictionary value of ["old": simd_int2]
    ///
    /// - Parameter notification: event notification.
    @objc func focusedCoordinateChanged(notification: Notification) {
        guard let mapFocusedCoordinate = notification.object as? simd_int2,
              let userInfo = notification.userInfo as? [String: Any],
              let oldCoordinate = userInfo["old"] as? simd_int2,
              let isValidCoord = userInfo["valid"] as? Bool else {
            return
        }
        
        let delta = oldCoordinate.delta(to: mapFocusedCoordinate)
        self.log("map focus coordinate changed, \(mapFocusedCoordinate.coordDescription) -> \(oldCoordinate.coordDescription) ( \(delta))", level: .debug)
    }
    
    /// Handles the `Notification.Name.Demo.AboutToLoadScene` callback.
    ///
    ///   - expects a user dictionary value of ["url": `URL`]
    ///
    /// - Parameter notification: event notification.
    @objc func sceneWillUnloadAction(notification: Notification) {
        self.log("resetting demo delegate...", level: .debug)
        self.reset()
    }
    
    /// Handles the `Notification.Name.Demo.NodeSelectionChanged` callback.
    ///
    ///   userInfo: ["nodes": `[SKNode]`]
    ///
    /// - Parameter notification: event notification.
    @objc func nodeSelectionChanged(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let selectedNodes = userInfo["nodes"] as? [SKNode] else {
            return
        }
        
        currentNodes.removeAll()
        
        for node in selectedNodes {
            var highlightColor = TiledGlobals.default.debug.objectHighlightColor
            currentNodes.append(node)
            if let tiledNode = node as? TiledGeometryType {
                if let tile = tiledNode as? SKTile {
                    highlightColor = tile.highlightColor
                }

                node.highlightNode(with: highlightColor)
            }
        }
    }
    
    /// Handles the `Notification.Name.Demo.MouseRightClicked` callback. This is the action that clears the current node highlights.
    ///
    /// - Parameter notification: event notification.
    @objc func mouseRightClickAction(notification: Notification) {
        reset()
    }
    
    /// Handles the `Notification.Name.Globals.Updated` callback. Changes selected nodes' highlight color.
    ///
    ///   userInfo: ["tileColor": `SKColor`, "objectColor": `SKColor`]
    ///
    /// - Parameter notification: event notification.
    @objc func globalsUpdatedAction(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else {
            return
        }
        
        if let objectColor = userInfo["objectColor"] as? SKColor {
            currentNodes.forEach { node in
                node.highlightNode(with: objectColor)
            }
        }
        
        
        
        if let tileColor = userInfo["tileColor"] as? SKColor {
            currentNodes.forEach { node in
                node.highlightNode(with: tileColor)
            }
        }
    }
}



/// Singleton instance
let defaultDemoDelegate = TiledDemoDelegate()



// MARK: - Extensions

extension TiledDemoDelegate: TiledSceneCameraDelegate {
    
    @objc public func cameraZoomChanged(newZoom: CGFloat) {
        let oldZoom = currentCameraZoom
        currentCameraZoom = newZoom
    }
}
