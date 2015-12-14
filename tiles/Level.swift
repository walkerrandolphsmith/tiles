import Foundation

let numberOfColumns = 9
let numberOfRows = 9

class Level {
    private var cookies = Array2D<Cookie>(columns: numberOfColumns, rows: numberOfRows)
    private var tiles = Array2D<Tile>(columns: numberOfColumns, rows: numberOfRows)
    private var possibleSwaps = Set<Swap>()

    var targetScore = 0
    var maximumMoves = 0

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
                targetScore = dictionary["targetScore"] as! Int
                maximumMoves = dictionary["moves"] as! Int
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

    private func detectHorizontalMathces() -> Set<Chain> {
        var set = Set<Chain>()

        for row in 0..<numberOfRows {
            for var column = 0; column < numberOfColumns - 2 ; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType

                    if cookies[column + 1, row]?.cookieType == matchType && cookies[column + 2, row]?.cookieType == matchType {

                        let chain = Chain(chainType: .Horizontal)

                        repeat {
                            chain.addCookie(cookies[column, row]!)
                            ++column
                        }
                        while column < numberOfColumns && cookies[column, row]?.cookieType == matchType

                        set.insert(chain)
                        continue
                    }
                }
                ++column
            }
        }
        return set
    }

    private func detechVerticalMathces() -> Set<Chain> {
        var set = Set<Chain>()

        for column in 0..<numberOfColumns {
            for var row = 0; row < numberOfRows - 2; {
                if let cookie = cookies[column, row] {
                    let matchType = cookie.cookieType

                    if cookies[column, row + 1]?.cookieType == matchType &&
                        cookies[column, row + 2]?.cookieType == matchType {

                        let chain = Chain(chainType: .Vertical)

                        repeat {
                            chain.addCookie(cookies[column, row]!)
                            ++row
                        }
                        while row < numberOfRows && cookies[column, row]?.cookieType == matchType

                        set.insert(chain)
                        continue
                    }
                }
                ++row
            }
        }
        return set
    }

    func removeMatches() -> Set<Chain> {
        let horizontalChains = detectHorizontalMathces()
        let verticalChains = detechVerticalMathces()

        removeCookies(horizontalChains)
        removeCookies(verticalChains)

        calculateScores(horizontalChains)
        calculateScores(verticalChains)

        return horizontalChains.union(verticalChains)
    }

    private func removeCookies(chains: Set<Chain>) {
        for chain in chains {
            for cookie in chain.cookies {
                cookies[cookie.column, cookie.row] = nil
            }
        }
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

    func fillHoles() -> [[Cookie]] {
        var columns = [[Cookie]]()

        for column in 0..<numberOfColumns {
            var array = [Cookie]()

            for row in 0..<numberOfRows {

                if tiles[column, row] != nil && cookies[column, row] == nil {
                    for lookup in (row + 1)..<numberOfRows {
                        if let cookie = cookies[column, lookup]{
                            cookies[column, lookup] = nil
                            cookies[column, row] = cookie
                            cookie.row = row
                            array.append(cookie)
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }

    func topUpCookies() -> [[Cookie]] {
        var columns = [[Cookie]]()
        var cookieType: CookieType = .Unknown

        for column in 0..<numberOfColumns {
            var array = [Cookie]()

            for var row = numberOfRows - 1; row >= 0 && cookies[column, row] == nil; --row {
                if tiles[column, row] != nil {
                    var newCookieType: CookieType
                    repeat {
                        newCookieType = CookieType.random()
                    }
                    while newCookieType == cookieType
                    cookieType = newCookieType

                    let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                    cookies[column, row] = cookie
                    array.append(cookie)
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }

    private func calculateScores(chains: Set<Chain>) {
        for chain in chains {
            chain.score = 60 * (chain.length - 2)
        }
    }
}