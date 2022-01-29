//
//  ViewController.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/01/24.
//

import UIKit
import CoreData

class ModalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var saveJokeButton: UIButton!
    weak var delegate: Refreshable? {
        didSet {
            print("💉 delegate 주입 완료!")
        }
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JokeModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    @IBAction func saveJokeButtonTapped(_ sender: UIButton) {
        var jokeCategory: JokeMessage.Category
        
        if segmentedControl.selectedSegmentIndex == .zero {
            jokeCategory = .buzzWord
        } else {
            jokeCategory = .dadJoke
        }
        
        saveContext(content: textField.text!, category: jokeCategory)
        self.dismiss(animated: true) {
            self.delegate?.refresh()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }
    
    func saveContext(content: String, category: JokeMessage.Category) {
        // 1. NSManagedObjectContext 가져온다.
        // 변경사항이 당연히 없다. viewContext 가져오기만 하고, 딱히 해준 게 없기 때문.
        let context = container.viewContext
        
        // 2. entity 가져온다.
        let entity = NSEntityDescription.entity(forEntityName: "Joke", in: context)
        guard let entity = entity else {
            print("❌ entity 에 nil 잡혔다!")
            return
        }
        
        // 3. NSManagedObject 만든다.
        let joke = NSManagedObject(entity: entity, insertInto: context)
        
        // 4. NSManagedObject 값을 세팅한다.
        let newJoke = JokeMessage(content: content, category: category, id: UUID())
        
        joke.setValue(newJoke.id, forKey: "id")
        joke.setValue(newJoke.content, forKey: "body")
        joke.setValue(newJoke.category.rawValue, forKey: "category")
        
        // 5. NSManagedObjectContext 저장한다.
        if context.hasChanges {
            do {
                try context.save()
                print("💚 재미난 조크 저장됨!")
            } catch let error as NSError {
                print("Error: \(error), \(error.userInfo)")
            }
        } else {
            print("❌ context 에 변경이 없다!")
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveJokeButtonTapped(saveJokeButton)
        return true
    }
}
