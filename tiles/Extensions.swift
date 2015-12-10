import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource("Levels/" + filename, ofType: "json") {
            do {
                var data: NSData?
                data = try NSData(contentsOfFile: path, options: NSDataReadingOptions())

                if let data = data {
                    let dictionary: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                        return dictionary
                    }
                    else {
                        return nil
                    }
                }
                else{
                    return nil
                }
            }
            catch {
                return nil
            }
        }
        else{
            return nil
        }
    }
}