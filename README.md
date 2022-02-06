# CoreData-study

## 1️⃣ XCDataModel, Entity, Model 프로퍼티 생성

- `JokeModel.xcdatamodeld` 파일 생성
- Entities 이름은 "Joke"
- Attributes 3개 설정
- Editor 탭의 CreateNSManagedObject Subclass 를 눌러, Manual 하게 Entity(코어데이터에서 사용하기 위한 모델)가 활용하는 프로퍼티 생성
- Model 이 활용하는 프로퍼티 생성

<p align="center"><img src="https://user-images.githubusercontent.com/71127966/152667838-cebffc9e-63f6-4e0f-aa60-5a9d3b61194b.png" width="70%"></p>

<br>

```swift
// Entity 가 활용하는 Joke 클래스와 프로퍼티 생성
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

// Model 이 활용하는 클래스와 프로퍼티 생성
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

## 2️⃣ Core Data Stack 을 Singleton 으로 구현

> You use an NSPersistentContainer instance to set up the model, context, and store coordinator simultaneously.

- 싱글톤을 만들 때, container.viewContext 가 아닌, `container.newBackgroundContext()` 사용한 이유는 메인 큐(스레드)가 아닌 별도의 큐(스레드)에서 CoreData 오버헤드를 처리하기 위함
- NSPersistentContainer 타입의 인스턴스를 만들 때 name 파라미터로는 Entity 이름(Joke)이 아니라, XCDataModel 파일 이름(JokeModel)이 들어가야 함
- `CoreData` 프레임워크 안에 Foundation 이 포함되어 있기 때문에 중복으로 import 할 필요 없음

### 📄 참고 문서
- [Setting Up a Core Data Stack](https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack)
- [Core Data Stack](https://developer.apple.com/documentation/coredata/core_data_stack)
- [newBackgroundContext()](https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640581-newbackgroundcontext)

```swift
import CoreData // CoreData 안에 Foundation 포함되어있음!

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

## 3️⃣ CoreData 저장

- 새로운 값을 CoreData 에 넣어준 뒤, `hasChanges` 프로퍼티로 변경사항이 있는지 체크
- 변경사항이 있다면, 싱글톤에서 `save()` 메서드를 호출하여 변경사항 저장
  - 이때, save() 메서드는 `throws` 가능하므로 do-try-catch 예외처리 필요

```swift
func saveContext(content: String, category: JokeMessage.Category) {
    // 1. entity 가져온다.
    let entity = NSEntityDescription.entity(forEntityName: "Joke", in: CoreDataManager.shared)
    guard let entity = entity else {
        print("❌ entity 에 nil 잡혔다!")
        return
    }
    
    // 2. NSManagedObject 만든다.
    let joke = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared)
    
    // 3. NSManagedObject 값을 세팅한다.
    let newJoke = JokeMessage(content: content, category: category, id: UUID())
    
    joke.setValue(newJoke.id, forKey: "id")
    joke.setValue(newJoke.content, forKey: "body")
    joke.setValue(newJoke.category.rawValue, forKey: "category")
    
    // 4. NSManagedObjectContext 저장한다.
    if CoreDataManager.shared.hasChanges {
        do {
            try CoreDataManager.shared.save()
            print("💚 재미난 조크 저장됨!")
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    } else {
        print("❌ context 에 변경이 없다!")
        return
    }
}
```

<br>

## 4️⃣ CoreData 가져와서 테이블뷰로 보여주기

- NSFetchRequest<Joke>(entityName: "Joke") 타입을 갖는 `request` 생성
- NSManagedObjectContext 타입을 갖는 싱글톤(shared)에서 `fetch()` 메서드를 호출해 데이터를 불러옴
- (선택) Array 타입으로 받은 데이터를 `테이블뷰` 형태로 보여줄 때, 최근에 저장한 내용이 위에 배치되도록 하기 위해, `reversed()` 처리하고 만약 `nil`이 잡힌다면 빈 배열이 리턴되도록 구현

```swift
// CoreData 에 저장된 데이터 전부를 가져오는 메서드
private func fetchAllJoke() -> [Joke] {
    let request = Joke.fetchRequest()
    let fetchedData = try? CoreDataManager.shared.fetch(request)
    return fetchedData?.reversed() ?? [] // 최신 조크가 위로 올라오도록, 순서 뒤집어서 내보내기
}

// 테이블뷰의 numberOfRowsInSection 메서드
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchAllJoke().count
}

// 테이블뷰의 cellForRowAt 메서드
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

## 5️⃣ CoreData 삭제

- 삭제할 indexPath 에 해당하는 object 자체를 넘겨서 싱글톤의 `delete` 메서드로 삭제할 수 있지만, 의도적으로 `id` 조회를 통해 삭제 기능 구현
  - 삭제할 indexPath 위치한 object 의 `id` 프로퍼티 조회
  - UUID 타입의 id 와 `NSPredicate`를 이용해서 삭제할 object 를 찾아냄
  - 싱글톤(shared)에서 `delete()` 메서드를 호출해 object 삭제 및 저장(save)

```swift
// CoreData 에서 NSPredicate 조건에 해당하는 데이터만 특정해서 가져오는 메서드
private func fetchSpecificJoke(id: UUID) -> Joke? {
    let request = Joke.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    let fetchedData = try? CoreDataManager.shared.fetch(request)
    return fetchedData?.first
}

// 테이블뷰에서 swipe 를 통해 데이터를 삭제하는 기능
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        // Delete the row from the data source
        deleteJoke(at: indexPath) // 바로 아래에서 정의한 메서드
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

private func deleteJoke(at indexPath: IndexPath) {
    let eachJokeData = fetchAllJoke()[indexPath.row]
    guard let deleteTargetID = eachJokeData.id else {
        print("❌ 삭제할 object 의 ID 못 찾음!")
        return
    }
    
    // Model의 id 값을 활용해 CoreData에 해당하는 객체를 불러옵니다.
    guard let deleteTarget = fetchSpecificJoke(id: deleteTargetID) else {
        print("❌ 삭제할 object 못 찾음!")
        return
    }
    
    // 불러온 데이터를 삭제하고, context를 통해 변경사항을 저장합니다.
    do {
        CoreDataManager.shared.delete(deleteTarget)
        // 삭제했으면 저장까지 해줘야, 앱을 종료했다 다시 켰을 때에도 반영됨!
        try CoreDataManager.shared.save()
        print("🔑 object 삭제 후 저장 완료!")
    } catch {
        print("❌ 삭제 후 저장 실패!")
    }
}
```

<br>

## 6️⃣ Modal 화면에서 CoreData 저장하면 테이블뷰가 Refresh 되는 기능

- Modal 뷰컨과 테이블뷰컨은 분리되어 있으므로, 테이블뷰컨을 Refresh 하는 기능을 `프로토콜로 추상화`
- `Delegation Pattern` -> Modal 뷰컨은 Refreshable 프로토콜을 채택한 `delegate` 프로퍼티를 가짐
- 테이블뷰컨의 `prepare for segue` 메서드를 통해 Modal 뷰컨의 delegate 프로퍼티에 `의존성 주입`
- Modal 화면이 dismiss 될 때 `completion 핸들러`를 통해 delegate 프로퍼티의 refresh() 메서드 호출

```swift
// Refreshable 프로토콜 추상화 -> refresh() 메서드 내부에서 tableView.reloadData() 호출
protocol Refreshable: AnyObject {
    
    func refresh()
}

// Modal 뷰컨은 delegate 프로퍼티를 weak 참조로 가짐
weak var delegate: Refreshable? {
    didSet {
        print("💉 delegate 주입 완료!")
    }
} 

// 테이블뷰컨의 prepare 메서드를 통해 Modal 뷰컨에 의존성 주입
override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let nextVC = segue.destination as? ModalViewController {
        nextVC.delegate = self
    }
}

// Modal 화면의 [저장하기] 버튼이 눌리면, Modal dismiss 되고 delegate 프로퍼티 통해서 refresh 메서드 호출
@IBAction func saveJokeButtonTapped(_ sender: UIButton) {
    // 새로운 Joke 를 CoreData 에 저장하는 메서드 위치
    self.dismiss(animated: true) {
        self.delegate?.refresh()
    }
}
```
