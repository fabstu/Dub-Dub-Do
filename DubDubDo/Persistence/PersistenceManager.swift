import Foundation
import CoreData

class PersistenceManager {
    lazy var managedObjectContext: NSManagedObjectContext = { self.persistentContainer.viewContext }()
    
    lazy var persistentContainer: NSPersistentContainer  = {
        print("Loading container")
        let container = NSPersistentContainer(name: "Todo")
        container.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                fatalError("error: \(error.localizedDescription)")
            }
        }
        print("Container loaded")
        return container
    }()
}
