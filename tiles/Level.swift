import Foundation

let numberOfColumns = 9
let numberOfRows = 9

class Level {
    private var cookies = Array2D<Cookie>(columns: numberOfColumns, rows: numberOfRows)

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
                let cookieType = CookieType.random()

                let cookie = Cookie(column: column, row: row, cookieType: cookieType)
                cookies[column, row] = cookie

                set.insert(cookie)
            }
        }
        return set;
    }
}