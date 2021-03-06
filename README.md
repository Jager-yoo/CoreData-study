# CoreData-study

## π± κΈ°λ₯ μμ°

- CoreData μ μ₯, μ­μ 
- νμ΄λΈλ·° Refresh κΈ°λ₯ with Delegation Pattern

https://user-images.githubusercontent.com/71127966/152670214-2a92fe72-c17c-4be2-a3fe-8bbc18824b94.mov

<br>

## 1οΈβ£ XCDataModel, Entity, Model νλ‘νΌν° μμ±

- `JokeModel.xcdatamodeld` νμΌ μμ±
- Entities μ΄λ¦μ "Joke"
- Attributes 3κ° μ€μ 
- Editor ν­μ CreateNSManagedObject Subclass λ₯Ό λλ¬, Manual νκ² Entity(μ½μ΄λ°μ΄ν°μμ μ¬μ©νκΈ° μν λͺ¨λΈ)κ° νμ©νλ νλ‘νΌν° μμ±
- Model μ΄ νμ©νλ νλ‘νΌν° μμ±

<p align="center"><img src="https://user-images.githubusercontent.com/71127966/152667838-cebffc9e-63f6-4e0f-aa60-5a9d3b61194b.png" width="70%"></p>

<br>

```swift
// Entity κ° νμ©νλ Joke ν΄λμ€μ νλ‘νΌν° μμ±
import CoreData

@objc(Joke)
public class Joke: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Joke> {
        return NSFetchRequest<Joke>(entityName: "Joke")
    }

    @NSManaged public var body: String?
    @NSManaged public var category: String?
    @NSManaged public var id: UUID?
}

extension Joke : Identifiable {

}

// Model μ΄ νμ©νλ ν΄λμ€μ νλ‘νΌν° μμ±
struct JokeMessage {

    let content: String
    let category: Category
    let id: UUID
    
    enum Category: String {
        
        case buzzWord
        case dadJoke
    }
}
```

<br>

## 2οΈβ£ Core Data Stack μ Singleton μΌλ‘ κ΅¬ν

> You use an NSPersistentContainer instance to set up the model, context, and store coordinator simultaneously.

- μ±κΈν€μ λ§λ€ λ, container.viewContext κ° μλ, `container.newBackgroundContext()` μ¬μ©ν μ΄μ λ λ©μΈ ν(μ€λ λ)κ° μλ λ³λμ ν(μ€λ λ)μμ CoreData μ€λ²ν€λλ₯Ό μ²λ¦¬νκΈ° μν¨
- NSPersistentContainer νμμ μΈμ€ν΄μ€λ₯Ό λ§λ€ λ name νλΌλ―Έν°λ‘λ Entity μ΄λ¦(Joke)μ΄ μλλΌ, XCDataModel νμΌ μ΄λ¦(JokeModel)μ΄ λ€μ΄κ°μΌ ν¨
- `CoreData` νλ μμν¬ μμ Foundation μ΄ ν¬ν¨λμ΄ μκΈ° λλ¬Έμ μ€λ³΅μΌλ‘ import ν  νμ μμ

### π μ°Έκ³  λ¬Έμ
- [Setting Up a Core Data Stack](https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack)
- [Core Data Stack](https://developer.apple.com/documentation/coredata/core_data_stack)
- [newBackgroundContext()](https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640581-newbackgroundcontext)

```swift
import CoreData // CoreData μμ Foundation ν¬ν¨λμ΄μμ!

class CoreDataManager {
    
    static let shared = container.newBackgroundContext()
    private static let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JokeModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private init() { }
}
```

<br>

## 3οΈβ£ CoreData μ μ₯

- μλ‘μ΄ κ°μ CoreData μ λ£μ΄μ€ λ€, `hasChanges` νλ‘νΌν°λ‘ λ³κ²½μ¬ν­μ΄ μλμ§ μ²΄ν¬
- λ³κ²½μ¬ν­μ΄ μλ€λ©΄, μ±κΈν€μμ `save()` λ©μλλ₯Ό νΈμΆνμ¬ λ³κ²½μ¬ν­ μ μ₯
  - μ΄λ, save() λ©μλλ `throws` κ°λ₯νλ―λ‘ do-try-catch μμΈμ²λ¦¬ νμ

```swift
func saveContext(content: String, category: JokeMessage.Category) {
    // 1. entity κ°μ Έμ¨λ€.
    let entity = NSEntityDescription.entity(forEntityName: "Joke", in: CoreDataManager.shared)
    guard let entity = entity else {
        print("β entity μ nil μ‘νλ€!")
        return
    }
    
    // 2. NSManagedObject λ§λ λ€.
    let joke = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared)
    
    // 3. NSManagedObject κ°μ μΈννλ€.
    let newJoke = JokeMessage(content: content, category: category, id: UUID())
    
    joke.setValue(newJoke.id, forKey: "id")
    joke.setValue(newJoke.content, forKey: "body")
    joke.setValue(newJoke.category.rawValue, forKey: "category")
    
    // 4. NSManagedObjectContext μ μ₯νλ€.
    if CoreDataManager.shared.hasChanges {
        do {
            try CoreDataManager.shared.save()
            print("π μ¬λ―Έλ μ‘°ν¬ μ μ₯λ¨!")
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    } else {
        print("β context μ λ³κ²½μ΄ μλ€!")
        return
    }
}
```

<br>

## 4οΈβ£ CoreData κ°μ Έμμ νμ΄λΈλ·°λ‘ λ³΄μ¬μ£ΌκΈ°

- NSFetchRequest<Joke>(entityName: "Joke") νμμ κ°λ `request` μμ±
- NSManagedObjectContext νμμ κ°λ μ±κΈν€(shared)μμ `fetch()` λ©μλλ₯Ό νΈμΆν΄ λ°μ΄ν°λ₯Ό λΆλ¬μ΄
- (μ ν) Array νμμΌλ‘ λ°μ λ°μ΄ν°λ₯Ό `νμ΄λΈλ·°` ννλ‘ λ³΄μ¬μ€ λ, μ΅κ·Όμ μ μ₯ν λ΄μ©μ΄ μμ λ°°μΉλλλ‘ νκΈ° μν΄, `reversed()` μ²λ¦¬νκ³  λ§μ½ `nil`μ΄ μ‘νλ€λ©΄ λΉ λ°°μ΄μ΄ λ¦¬ν΄λλλ‘ κ΅¬ν

```swift
// CoreData μ μ μ₯λ λ°μ΄ν° μ λΆλ₯Ό κ°μ Έμ€λ λ©μλ
private func fetchAllJoke() -> [Joke] {
    let request = Joke.fetchRequest()
    let fetchedData = try? CoreDataManager.shared.fetch(request)
    return fetchedData?.reversed() ?? [] // μ΅μ  μ‘°ν¬κ° μλ‘ μ¬λΌμ€λλ‘, μμ λ€μ§μ΄μ λ΄λ³΄λ΄κΈ°
}

// νμ΄λΈλ·°μ numberOfRowsInSection λ©μλ
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchAllJoke().count
}

// νμ΄λΈλ·°μ cellForRowAt λ©μλ
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
    var content = cell.defaultContentConfiguration()
    
    let eachJokeData = fetchAllJoke()[indexPath.row]
    content.text = eachJokeData.body
    
    cell.contentConfiguration = content
    return cell
}
```

<br>

## 5οΈβ£ CoreData μ­μ 

- μ­μ ν  indexPath μ ν΄λΉνλ object μμ²΄λ₯Ό λκ²¨μ μ±κΈν€μ `delete` λ©μλλ‘ μ­μ ν  μ μμ§λ§, μλμ μΌλ‘ `id` μ‘°νλ₯Ό ν΅ν΄ μ­μ  κΈ°λ₯ κ΅¬ν
  - μ­μ ν  indexPath μμΉν object μ `id` νλ‘νΌν° μ‘°ν
  - UUID νμμ id μ `NSPredicate`λ₯Ό μ΄μ©ν΄μ μ­μ ν  object λ₯Ό μ°Ύμλ
  - μ±κΈν€(shared)μμ `delete()` λ©μλλ₯Ό νΈμΆν΄ object μ­μ  λ° μ μ₯(save)

```swift
// CoreData μμ NSPredicate μ‘°κ±΄μ ν΄λΉνλ λ°μ΄ν°λ§ νΉμ ν΄μ κ°μ Έμ€λ λ©μλ
private func fetchSpecificJoke(id: UUID) -> Joke? {
    let request = Joke.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    let fetchedData = try? CoreDataManager.shared.fetch(request)
    return fetchedData?.first
}

// νμ΄λΈλ·°μμ swipe λ₯Ό ν΅ν΄ λ°μ΄ν°λ₯Ό μ­μ νλ κΈ°λ₯
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        // Delete the row from the data source
        deleteJoke(at: indexPath) // λ°λ‘ μλμμ μ μν λ©μλ
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

private func deleteJoke(at indexPath: IndexPath) {
    let eachJokeData = fetchAllJoke()[indexPath.row]
    guard let deleteTargetID = eachJokeData.id else {
        print("β μ­μ ν  object μ ID λͺ» μ°Ύμ!")
        return
    }
    
    // Modelμ id κ°μ νμ©ν΄ CoreDataμ ν΄λΉνλ κ°μ²΄λ₯Ό λΆλ¬μ΅λλ€.
    guard let deleteTarget = fetchSpecificJoke(id: deleteTargetID) else {
        print("β μ­μ ν  object λͺ» μ°Ύμ!")
        return
    }
    
    // λΆλ¬μ¨ λ°μ΄ν°λ₯Ό μ­μ νκ³ , contextλ₯Ό ν΅ν΄ λ³κ²½μ¬ν­μ μ μ₯ν©λλ€.
    do {
        CoreDataManager.shared.delete(deleteTarget)
        // μ­μ νμΌλ©΄ μ μ₯κΉμ§ ν΄μ€μΌ, μ±μ μ’λ£νλ€ λ€μ μΌ°μ λμλ λ°μλ¨!
        try CoreDataManager.shared.save()
        print("π object μ­μ  ν μ μ₯ μλ£!")
    } catch {
        print("β μ­μ  ν μ μ₯ μ€ν¨!")
    }
}
```

<br>

## 6οΈβ£ Modal νλ©΄μμ CoreData μ μ₯νλ©΄ νμ΄λΈλ·°κ° Refresh λλ κΈ°λ₯

- Modal λ·°μ»¨κ³Ό νμ΄λΈλ·°μ»¨μ λΆλ¦¬λμ΄ μμΌλ―λ‘, νμ΄λΈλ·°μ»¨μ Refresh νλ κΈ°λ₯μ `νλ‘ν μ½λ‘ μΆμν`
- `Delegation Pattern` -> Modal λ·°μ»¨μ Refreshable νλ‘ν μ½μ μ±νν `delegate` νλ‘νΌν°λ₯Ό κ°μ§
- νμ΄λΈλ·°μ»¨μ `prepare for segue` λ©μλλ₯Ό ν΅ν΄ Modal λ·°μ»¨μ delegate νλ‘νΌν°μ `μμ‘΄μ± μ£Όμ`
- Modal νλ©΄μ΄ dismiss λ  λ `completion νΈλ€λ¬`λ₯Ό ν΅ν΄ delegate νλ‘νΌν°μ refresh() λ©μλ νΈμΆ

```swift
// Refreshable νλ‘ν μ½ μΆμν -> refresh() λ©μλ λ΄λΆμμ tableView.reloadData() νΈμΆ
protocol Refreshable: AnyObject {
    
    func refresh()
}

// Modal λ·°μ»¨μ delegate νλ‘νΌν°λ₯Ό weak μ°Έμ‘°λ‘ κ°μ§
weak var delegate: Refreshable? {
    didSet {
        print("π delegate μ£Όμ μλ£!")
    }
} 

// νμ΄λΈλ·°μ»¨μ prepare λ©μλλ₯Ό ν΅ν΄ Modal λ·°μ»¨μ μμ‘΄μ± μ£Όμ
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let nextVC = segue.destination as? ModalViewController {
        nextVC.delegate = self
    }
}

// Modal νλ©΄μ [μ μ₯νκΈ°] λ²νΌμ΄ λλ¦¬λ©΄, Modal dismiss λκ³  delegate νλ‘νΌν° ν΅ν΄μ refresh λ©μλ νΈμΆ
@IBAction func saveJokeButtonTapped(_ sender: UIButton) {
    // μλ‘μ΄ Joke λ₯Ό CoreData μ μ μ₯νλ λ©μλ μμΉ
    self.dismiss(animated: true) {
        self.delegate?.refresh()
    }
}
```
