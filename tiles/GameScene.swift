import SpriteKit

class GameScene: SKScene {
    required init?(coder aDecoder : NSCoder){
        fatalError("INit(coder) is not used in this app")
    }
    var swipeHandler: ((Swap) -> ())?
    var level: Level!

    let TileWidth: CGFloat = 32.0
    let TileHeight: CGFloat = 36.0
    
    let gameLayer = SKNode()
    let cookiesLayer = SKNode()
    let tilesLayer = SKNode()

    var swipeFromColumn: Int?
    var swipeFromRow: Int?

    var selectionSprite = SKSpriteNode()

    let swapSound = SKAction.playSoundFileNamed("Sounds/Chomp.wav", waitForCompletion: false)
    let invalidSwapSound = SKAction.playSoundFileNamed("Sounds/Error.wav", waitForCompletion: false)
    let matchSound = SKAction.playSoundFileNamed("Sounds/Match.wav", waitForCompletion: false)
    let fallingCookieSound = SKAction.playSoundFileNamed("Sounds/Match.wav", waitForCompletion: false)
    let addCookieSound = SKAction.playSoundFileNamed("Sounds/Match.wav", waitForCompletion: false)

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

        tilesLayer.position = layerPosition
        cookiesLayer.position = layerPosition

        gameLayer.addChild(tilesLayer)
        gameLayer.addChild(cookiesLayer)

        swipeFromColumn = nil
        swipeFromRow = nil
        SKLabelNode(fontNamed: "GillSans-BoldItalic")
    }

    func addTiles() {
        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                if let _ = level.tileAtColumn(column, row: row){
                    let tileNode = SKSpriteNode(imageNamed: "Tile")
                    tileNode.position = pointForColumn(column, row: row)
                    tilesLayer.addChild(tileNode)
                }
            }
        }
    }

    func addSpritesForCookies(cookies: Set<Cookie>) {
        for cookie in cookies {
            let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
            sprite.position = pointForColumn(cookie.column, row: cookie.row)
            cookiesLayer.addChild(sprite)
            cookie.sprite = sprite
        }
    }

    func showSelectionIndicatorForCookie(cookie: Cookie) {
        if selectionSprite.parent != nil {
            selectionSprite.removeFromParent()
        }

        if let sprite = cookie.sprite {
            let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
            selectionSprite.size = texture.size()
            selectionSprite.runAction(SKAction.setTexture(texture))

            sprite.addChild(selectionSprite)
            selectionSprite.alpha = 1.0
        }
    }

    func hideSelectionIndicator() {
        selectionSprite.runAction(SKAction.sequence([
            SKAction.fadeOutWithDuration(0.3),
            SKAction.removeFromParent()
        ]))
    }

    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * TileWidth + TileWidth / 2,
            y: CGFloat(row) * TileHeight + TileHeight / 2
        )
    }

    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0
            && point.x < CGFloat(numberOfColumns) * TileWidth
            && point.y >= 0
            && point.y < CGFloat(numberOfRows) * TileHeight {

            return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
        }
        else {
            return(false, 0, 0)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let location = touch?.locationInNode(cookiesLayer)

        let(success, column, row) = convertPoint(location!)
        if success {
            if let cookie = level.cookieAtColumn(column, row: row){
                showSelectionIndicatorForCookie(cookie)
                swipeFromColumn = column
                swipeFromRow = row
            }
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if swipeFromColumn == nil { return }

        let touch = touches.first
        let location = touch?.locationInNode(cookiesLayer)

        let (success, column, row) = convertPoint(location!)
        if success {
            var horzDelta = 0, vertDelt = 0
            if column < swipeFromColumn! {
                horzDelta = -1
            }
            else if column > swipeFromColumn! {
                horzDelta = 1
            }
            else if row < swipeFromRow! {
                vertDelt = -1
            }
            else if row > swipeFromRow! {
                vertDelt = 1
            }

            if horzDelta != 0 || vertDelt != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelt)
                hideSelectionIndicator()
                swipeFromColumn = nil
            }
        }
    }

    func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {
        let toColumn = swipeFromColumn! + horzDelta
        let toRow = swipeFromRow! + vertDelta

        if toColumn < 0 || toColumn >= numberOfColumns { return }
        if toRow < 0 || toRow >= numberOfRows { return }

        if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
            if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!){
                if let handler = swipeHandler {
                    let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
                    handler(swap)
                }
            }
        }
    }

    func animateSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!

        spriteA.zPosition = 100
        spriteB.zPosition = 90

        let Duration: NSTimeInterval = 0.3

        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut
        spriteA.runAction(moveA, completion: completion)

        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut
        spriteB.runAction(moveB)

        runAction(swapSound)
    }

    func animateInvalidSwap(swap: Swap, completion: () -> ()) {
        let spriteA = swap.cookieA.sprite!
        let spriteB = swap.cookieB.sprite!

        spriteA.zPosition = 100
        spriteB.zPosition = 90

        let Duration: NSTimeInterval = 0.2

        let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
        moveA.timingMode = .EaseOut

        let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
        moveB.timingMode = .EaseOut

        spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
        spriteB.runAction(SKAction.sequence([moveB, moveA]))
        runAction(invalidSwapSound)
    }

    func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
        for chain in chains {
            animateScoreForChain(chain)
            for cookie in chain.cookies {
                if let sprite = cookie.sprite {
                    if sprite.actionForKey("removing") == nil {
                        let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
                        scaleAction.timingMode = .EaseOut
                        sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]), withKey: "removing")
                    }
                }
            }
        }
        runAction(matchSound)
        runAction(SKAction.waitForDuration(0.3), completion: completion)
    }

    func animateFallingCookie(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0
        for array in columns {
            for (idx, cookie) in array.enumerate() {
                let newPosition = pointForColumn(cookie.column, row: cookie.row)

                let delay = 0.05 + 0.15 * NSTimeInterval(idx)

                let sprite = cookie.sprite!
                let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)

                longestDuration = max(longestDuration, duration + delay)

                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.runAction(SKAction.sequence([
                    SKAction.waitForDuration(delay),
                    SKAction.group([moveAction, fallingCookieSound])
                ]))
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }

    func animateNewCookies(columns: [[Cookie]], completion: () -> ()) {
        var longestDuration: NSTimeInterval = 0

        for array in columns {
            let startRow = array[0].row + 1

            for(idx, cookie) in array.enumerate() {
                let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
                sprite.position = pointForColumn(cookie.column, row: startRow)
                cookiesLayer.addChild(sprite)
                cookie.sprite = sprite

                let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
                let duration = NSTimeInterval(startRow - cookie.row) * 0.1

                longestDuration = max(longestDuration, duration + delay)
                let newPosition = pointForColumn(cookie.column, row: cookie.row)
                let moveAction = SKAction.moveTo(newPosition, duration: duration)
                moveAction.timingMode = .EaseOut
                sprite.alpha = 0
                sprite.runAction(SKAction.sequence([
                    SKAction.waitForDuration(delay),
                    SKAction.group([
                        SKAction.fadeInWithDuration(0.05),
                        moveAction,
                        addCookieSound
                    ])
                ]))
            }
        }
        runAction(SKAction.waitForDuration(longestDuration), completion: completion)
    }

    func animateScoreForChain(chain: Chain) {
        let firstSprite = chain.firstCookie().sprite!
        let lastSprite = chain.lastCookie().sprite!
        let centerPosition = CGPoint(
            x: (firstSprite.position.x + lastSprite.position.x) / 2,
            y: (firstSprite.position.y + lastSprite.position.y) / 2 - 8
        )

        let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
        scoreLabel.fontSize = 16
        scoreLabel.text = String(format: "%ld", chain.score)
        scoreLabel.position = centerPosition
        scoreLabel.zPosition = 300
        cookiesLayer.addChild(scoreLabel)

        let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
        moveAction.timingMode = .EaseOut
        scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil

        if selectionSprite.parent != nil && swipeFromColumn != nil {
            hideSelectionIndicator()
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
}
