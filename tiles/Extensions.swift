import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary? {

        let bundle = NSBundle.mainBundle()

        if let path = bundle.pathForResource("Levels/" + filename, ofType: "json")
        {
            do{
                if let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions()) as NSData!
                {
                    do{
                        if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as? NSDictionary
                        {
                            return jsonResult as? Dictionary
                        }
                        else{
                            print("json data not read")
                        }
                    }
                    catch{
                        return nil
                    }
                }
                else{
                    print("contents of file not read")
                }
            }
            catch{
                return nil
            }
        }
        else{
            print("invalid path")
        }
        return nil
    }
}