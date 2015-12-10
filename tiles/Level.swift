import Foundation

let numberOfColumns = 9
let numberOfRows = 9

class Level {
    private var cookies = Array2D<Cookie>(columns: numberOfColumns, rows: numberOfRows)
    private var tiles = Array2D<Tile>(columns: numberOfColumns, rows: numberOfRows)

    init(filename: String) {
        if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename){
            if let tilesArray: AnyObject = dictionary["tiles"] {
                for(row, rowArray) in (tilesArray as! [[Int]]).enumerate(){
                    let tileRow = numberOfRows - row - 1

                    for(column, value) in rowArray.enumerate() {
                        if value == 1{
                            tiles[column, tileRow] = Tile()
                        }
                    }
                }
            }
        }
    }

    func tileAtColumn(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < numberOfColumns)
        assert(row >= 0 && row < numberOfRows)
        return tiles[column, row]
    }

    func cookieAtColumn(column: Int, row: Int) -> Cookie? {
        assert(column >= 0 && column < numberOfColumns)
        assert(row >= 0 && row < numberOfRows)
        return cookies[column, row]
    }

    func shuffle() -> Set<Cookie> {
        return createInitialCookies()
    }

    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()

        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns{
                if tiles[column, row] != nil {
                    let cookieType = CookieType.random()
                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie

                    set.insert(cookie)
                }
            }
        }
        return set;
    }

    func performSwap(swap: Swap) {
        let columnA = swap.cookieA.column
        let rowA = swap.cookieA.row
        let columnB = swap.cookieB.column
        let rowB = swap.cookieB.row

        cookies[columnA, rowA] = swap.cookieB
        swap.cookieB.column = columnA
        swap.cookieB.row = rowA

        cookies[columnB, rowB] = swap.cookieA
        swap.cookieA.column = columnB
        swap.cookieA.row = rowB
    }
}