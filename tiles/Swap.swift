struct Swap : Hashable {
    let cookieA: Cookie
    let cookieB: Cookie

    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
}

func ==(lhs: Swap, rhs:Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB || lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}