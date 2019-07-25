import Foundation
import SwiftUI

extension String {
    var myCount: Int {
        return self.count
    }
}

struct TodoListView : View {
    
    @State var selectedTodo: Todo? = nil
    
    @State var newTodo: String = ""
    @EnvironmentObject var todoStore: TodoStore
    
    @State var showingSheet = false
    
    var body: some View {
        
        NavigationView {
            List {
                // The various cell types could be extracted.
                Section(header: Text("Add")) {
                    AddView(newTodo: $newTodo)
                }
                
                Section(header: Text("In Progress")) {
                    InProgressView(selectedTodo: $selectedTodo, showingSheet: $showingSheet)
                }
                
                Section(header: Text("Completed")) {
                    ForEach(todoStore.completedTodos) { todo in
                        Text(todo.todoDescription).strikethrough()
                    }.onDelete(perform: self.todoStore.deleteCompletedTodo(at:))
                }
            }
            .listStyle(.grouped)
                .navigationBarTitle(Text("Todos"))
                .navigationBarItems(trailing: EditButton())
        }
        .actionSheet($showingSheet,
                     ActionSheet(
                        title: Text("Todo Actions"),
                        message: nil,
                        buttons: [
                            ActionSheet.Button.default(Text((self.selectedTodo?.isImportant ?? false) ? "Unflag" : "Flag")) {
                                self.todoStore.toggleIsImportant(self.selectedTodo)
                                self.showingSheet.toggle()
                                
                            }, ActionSheet.Button.default(Text("Mark as \((self.selectedTodo?.isComplete ?? false) ? "Incomplete" : "Complete")")) {
                                
                                self.todoStore.toggleIsComplete(self.selectedTodo)
                                self.showingSheet.toggle()
                                
                            }, ActionSheet.Button.cancel({
                                self.showingSheet.toggle()
                            })
                        ]
            )
        )
    }
}

struct AddView: View {
    @Binding var newTodo: String
    @EnvironmentObject var todoStore: TodoStore
    
    var body: some View {
        HStack {
            TextField($newTodo, placeholder: Text("Buy Groceries..."))
            
            if self.$newTodo.wrappedValue.myCount > 0 {
                Button(action: {
                    self.todoStore.create(description: self.newTodo)
                    self.newTodo = ""
                }) {
                    Image(systemName: "plus.circle.fill").foregroundColor(Color.green).imageScale(.large)
                }.animation(.linear(duration: 0.2))
            }
        }
    }
}

struct InProgressView: View {
    @EnvironmentObject var store: TodoStore
    
    @Binding var selectedTodo: Todo?
    @Binding var showingSheet: Bool
    
    var body: some View {
        ForEach(store.inProgressTodos) { todo in
            //Text(todo.todoDescription)
            HStack{
                TodoInProgressCell(todo: todo, selectedTodo: self.$selectedTodo, showingSheet: self.$showingSheet)
            }
        }.onDelete(perform: self.store.deleteInProgressTodo(at:))
    }
}


struct TodoInProgressCell: View {
    var todo: Todo
    @Binding var selectedTodo: Todo?
    @Binding var showingSheet: Bool
    
    @EnvironmentObject var todoStore: TodoStore
    
    var body: some View {
        Button(action: {
            self.selectedTodo = self.todo
            self.showingSheet = true
        }) {
            HStack {
                Text(todo.todoDescription).foregroundColor(.black)
                
                Spacer()
                todo.isImportant ? Image(systemName: "exclamationmark.triangle.fill").foregroundColor(Color.red).imageScale(.large) : nil
            }
        }
    }
}

#if DEBUG
struct TodoListView_Previews : PreviewProvider {
    static var previews: some View {
        TodoListView().environmentObject(TodoStore())
    }
}
#endif
