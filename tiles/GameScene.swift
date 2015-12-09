//
//  GameScene.swift
//  tiles
//
//  Created by Walker Smith on 12/7/15.
//  Copyright (c) 2015 Walker Smith. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    required init?(coder aDecoder : NSCoder){
        fatalError("INit(coder) is not used in this app")
    }

    var level: Level!

    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()

    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let background = SKSpriteNode(imageNamed: "Background")
        addChild(background)
        addChild(gameLayer)

        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(numberOfColumns) / 2,
            y: -TileHeight * CGFloat(numberOfRows) / 2
        )

        cookiesLayer.position = layerPosition
        gameLayer.addChild(cookiesLayer)
    }

    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }

    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * TileWidth + TileWidth / 2,
            y: CGFloat(row) * TileHeight + TileHeight / 2
        )
    }
}
