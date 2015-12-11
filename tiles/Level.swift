import Foundation

let numberOfColumns = 9
let numberOfRows = 9

class Level {
    private var cookies = Array2D<Cookie>(columns: numberOfColumns, rows: numberOfRows)
    private var tiles = Array2D<Tile>(columns: numberOfColumns, rows: numberOfRows)
    private var possibleSwaps = Set<Swap>()

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
        var set: Set<Cookie>
        repeat {
            set = createInitialCookies()
            detectPossibleSwaps()
        }
        while possibleSwaps.count == 0

        return set
    }

    private func createInitialCookies() -> Set<Cookie> {
        var set = Set<Cookie>()

        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns{
                if tiles[column, row] != nil {
                    var cookieType : CookieType
                    repeat {
                        cookieType = CookieType.random()
                    }
                    while (column >= 2 &&
                        cookies[column - 1, row]?.cookieType == cookieType &&
                        cookies[column - 2, row]?.cookieType == cookieType)
                        || (row >= 2 &&
                        cookies[column, row - 1]?.cookieType == cookieType &&
                        cookies[column, row - 2]?.cookieType == cookieType)

                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie

                    set.insert(cookie)
                }
            }
        }
        return set;
    }

    func isPossibleSwap(swap: Swap) -> Bool {
        return possibleSwaps.contains(swap)
    }

    func detectPossibleSwaps() {
        var set = Set<Swap>()

        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                if let cookie = cookies[column, row] {

                    if column < numberOfColumns - 1 {
                        if let other = cookies[column + 1, row]{
                            cookies[column, row] = other
                            cookies[column + 1, row] = cookie

                            if hasChainAtColumn(column + 1, row: row) || hasChainAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }

                            cookies[column, row] = cookie
                            cookies[column + 1, row] = other
                        }
                    }

                    if row < numberOfColumns - 1 {
                        if let other = cookies[column, row + 1] {
                            cookies[column, row] = other
                            cookies[column, row + 1] = cookie

                            if hasChainAtColumn(column, row: row + 1) || hasChainAtColumn(column, row: row) {
                                set.insert(Swap(cookieA: cookie, cookieB: other))
                            }

                            cookies[column, row] = cookie
                            cookies[column, row + 1] = other
                        }
                    }

                }
            }
        }
        possibleSwaps = set
    }

    private func hasChainAtColumn(column: Int, row: Int) -> Bool {
        let cookieType = cookies[column, row]!.cookieType
        
        var horzLength = 1
        for var i = column - 1; i >= 0 && cookies[i, row]?.cookieType == cookieType;
            --i, ++horzLength { }
        for var i = column + 1; i < numberOfColumns && cookies[i, row]?.cookieType == cookieType;
            ++i, ++horzLength { }
        if horzLength >= 3 { return true }
        
        var vertLength = 1
        for var i = row - 1; i >= 0 && cookies[column, i]?.cookieType == cookieType;
            --i, ++vertLength { }
        for var i = row + 1; i < numberOfRows && cookies[column, i]?.cookieType == cookieType;
            ++i, ++vertLength { }
        return vertLength >= 3
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