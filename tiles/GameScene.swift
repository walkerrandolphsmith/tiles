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

    var swipeFromColumn: Int?
    var swipeFromRow: Int?

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

        swipeFromColumn = nil
        swipeFromRow = nil
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
            if let _ = level.cookieAtColumn(column, row: row){
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
            else{
                vertDelt = 1
            }

            if horzDelta != 0 || vertDelt != 0 {
                trySwapHorizontal(horzDelta, vertical: vertDelt)
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
                print("swap \(fromCookie) with \(toCookie)")
            }
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        swipeFromColumn = nil
        swipeFromRow = nil
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded(touches!, withEvent: event)
    }
}
