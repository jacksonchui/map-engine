import Foundation
import RealmSwift

@objcMembers class DungeonConfiguration: Object {
    
    dynamic var name: String = ""
    dynamic var icon: String = "Chinese Nightlife"
    dynamic var texture: String = "Bananas"
    dynamic var floors: Int = 10
    dynamic var bagLimit: Int = 50
    dynamic var width: Int = 100
    dynamic var height: Int = 50
    dynamic var createdByUser: Bool = false
}
