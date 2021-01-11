//
//  InfiniteMapTests.swift
//  SKTiledTests
//
//  Created by Michael Fessenden.
//
//  Web: https://github.com/mfessenden
//  Email: michael.fessenden@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
import SpriteKit
@testable import SKTiled


// Tile map instance used for this test.
var testInfiniteTilemap: SKTilemap?
let infiniteTestTilemapName = "test-infinite"


/// Test infinite map functions.
class InfiniteMapTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        if (testInfiniteTilemap == nil) {
            if let tilemapUrl = TestController.default.getResource(named: infiniteTestTilemapName, withExtension: "tmx") {
                testInfiniteTilemap = SKTilemap.load(tmxFile: tilemapUrl.path, loggingLevel: .none)
            }
        }
    }
    
    
    
    /// Test to determine that coordinate conversion between tile layer and a child chunk will return the expected value.
    ///
    ///   Tests the `SKTileLayerChunk.coordinateForLayer(coord:)` method.
    func testCoordinateConversionFromLayerToChunk() {
        
    }
    
    /// Test to determine that
    func testQueryingTilesFromChunks() {
        let layerNameToQuery = "Objects"
        let expectedChunkCount = 5
        
        
        let coordToQuery1 = simd_int2(10, -11)
        let propertyName1 = "pointValue"
        let expectedPropertyValue1 = "2100"
        
        
        let coordToQuery2 = simd_int2(-12, -9)
        let propertyName2 = "itemType"
        let expectedPropertyValue2 = "food"
        
        
        
        guard let tilemap = testInfiniteTilemap else {
            XCTFail("⭑ failed to load tilemap `\(infiniteTestTilemapName)`")
            return
        }
        
        guard let objectsLayer = tilemap.getLayers(named: layerNameToQuery).first as? SKTileLayer else {
            XCTFail("⭑ could not access layer '\(layerNameToQuery)' -> '\(infiniteTestTilemapName)'")
            return
        }
        
        
        guard let tile1 = objectsLayer.tileAt(coord: coordToQuery1) else {
            XCTFail("⭑ could not find tile at '\(coordToQuery1.coordDescription)'.")
            return
        }
        
        guard let tilesetPropertyValue1 = tile1.tileData.properties[propertyName1] else {
            XCTFail("⭑ tile id \(tile1.tileData.globalID) does not have a property '\(propertyName1)'.")
            return
        }
        
        
        XCTAssertEqual(objectsLayer.chunks.count, expectedChunkCount, "⭑ layer chunk count is '\(objectsLayer.chunks.count)', expected: `\(expectedChunkCount)`.")
        XCTAssertEqual(tilesetPropertyValue1, expectedPropertyValue1, "⭑ tile data property '\(propertyName1)' has an incorrect value '\(tilesetPropertyValue1)', expected: `\(expectedPropertyValue1)`.")
        
        
        guard let tile2 = objectsLayer.tileAt(coord: coordToQuery2) else {
            XCTFail("⭑ could not find tile at '\(coordToQuery2.coordDescription)'.")
            return
        }
        
        guard let tilesetPropertyValue2 = tile2.tileData.properties[propertyName2] else {
            XCTFail("⭑ tile id \(tile2.tileData.globalID) does not have a property '\(propertyName2)'.")
            return
        }
        
        
        
        
        XCTAssertEqual(tilesetPropertyValue2, expectedPropertyValue2, "⭑ tile data property '\(propertyName2)' has an incorrect value '\(tilesetPropertyValue2)', expected: `\(expectedPropertyValue2)`.")
        
    }
}
