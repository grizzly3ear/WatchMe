import Foundation
import Alamofire
import SwiftyJSON

class HttpRequestManager {
    
    let domain: String!
    
    init(_ domain: String) {
        self.domain = domain
    }
    
    func get(_ url: String) -> JSON {
        var json: JSON?
        Alamofire.request("\(domain!)/\(url)", method: .get).responseJSON { (response) in
            json = try? JSON(data: response.data!)
        }
        return json!
    }
    
    func post(_ url: String, _ body: Dictionary<String, Any>) {
        print("post")
        print("\(domain!)/\(url)")
        Alamofire.request("\(domain!)/\(url)", method: .post, parameters: body, encoding: JSONEncoding.default)
    }

}
