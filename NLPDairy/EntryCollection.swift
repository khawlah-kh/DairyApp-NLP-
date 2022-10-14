
import Foundation

class EntryCollection {

    var entries: [String]?
    
    init() {
        let entriesURL = Bundle.main.url(forResource: "Entries", withExtension: "plist")!
        self.entries = NSArray(contentsOf: entriesURL) as? [String]
    }

}
