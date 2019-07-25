import SwiftUI
import Combine
import CoreData

class TodoStore: NSObject, BindableObject {
    
    
    // MARK: Private Properties
    private let persistenceManager = PersistenceManager()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Todo> = {
        print("Creating frc")
        let fetchRequest: NSFetchRequest<Todo> = Todo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        let fetchedResultsControlelr = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.persistenceManager.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsControlelr.delegate = self
        print("Returning frc")
        return fetchedResultsControlelr
    }()
    
    private var todos: [Todo] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    // MARK: Public Properties
    
    // This method of separting todos into inProgress and completed probably isn't the best. If we were building a sectioned table view we would probably use the section name key path on the fetched results controller but this is just to get something working quickly.
    public var inProgressTodos: [Todo] {
        return self.todos.filter { !$0.isComplete }
    }
    
    //public var inProgressTodos: [Todo] = []
    
    public var completedTodos: [Todo] {
        return self.todos.filter { $0.isComplete }
    }
    
    let willChange = PassthroughSubject<TodoStore, Never>()
    
    // MARK: Object Lifecycle
    
    override init() {
        super.init()
        fetchTodos()
    }
    
    // MARK: Public Methods
    
    public func create(description: String) {
        Todo.create(description: description, in: persistenceManager.managedObjectContext)
        print("Created new todo item")
        saveChanges()
    }
    
    public func deleteCompletedTodo(at indexes: IndexSet) {
        for index in indexes {
            self.persistenceManager.managedObjectContext.delete(completedTodos[index])
        }
        
        saveChanges()
    }
    
    public func deleteInProgressTodo(at indexes: IndexSet) {
        for index in indexes {
            self.persistenceManager.managedObjectContext.delete(inProgressTodos[index])
        }
        
        saveChanges()
    }
    
    public func toggleIsImportant(_ todo: Todo?) {
        guard let todo = todo else { return }
        todo.isImportant = !todo.isImportant
        saveChanges()
    }
    
    public func toggleIsComplete(_ todo: Todo?) {
        guard let todo = todo else { return }
        todo.isComplete = !todo.isComplete
        saveChanges()
    }
    
    // MARK: Private Methods
    
    private func fetchTodos() {
        print("Fetching todos")
        do {
            try fetchedResultsController.performFetch()
            print("Sections count: \(fetchedResultsController.sections?.count ?? -1)")
        } catch {
            fatalError("failed to fetch todos: \(error)")
        }
        print("Fetching todos done")
    }
    
    private func saveChanges() {
        guard persistenceManager.managedObjectContext.hasChanges else { return }
        do {
            try persistenceManager.managedObjectContext.save()
        } catch { fatalError("failed to save chanegs: \(error)") }
    }
}


// MARK: TodoStore + NSFetchedResultsControllerDelegate
extension TodoStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Controller did change content")
        willChange.send(self)
    }
}
