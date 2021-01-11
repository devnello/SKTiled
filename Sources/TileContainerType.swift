//
//  TileContainerType.swift
//  SKTiled
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

import SpriteKit


/// Protocol describing an object that interacts with a two-dimensional tile array. The only place this is used is in the parsing stage.
protocol TileContainerType: TiledObjectType, DebugDrawableType {
    
    /// Internal two-dimensional array.
    var tiles: Array2D<SKTile> { get set }
    
    /// Set the layer data.
    ///
    /// - Parameters:
    ///   - data: array of tile ids.
    func setLayerData(_ data: [UInt32]) -> Bool
    
    /// Builds a tile at the given coordinate from a global tile id.
    ///
    /// - Parameters:
    ///   - coord: tile coordinate.
    ///   - globalID: tile global id.
    func buildTileAt(coord: simd_int2, globalID: UInt32) -> SKTile?
    
    /// Returns a tile at the given coordinates.
    ///
    /// - Parameters:
    ///   - x: tile x-coordinate.
    ///   - y: tile y-coordinate.
    func tileAt(_ x: Int, _ y: Int) -> SKTile?
}



extension SKTileLayerChunk: TileContainerType {}
extension SKTileLayer: TileContainerType {}