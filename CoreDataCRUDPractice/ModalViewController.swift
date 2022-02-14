//
//  ViewController.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/01/24.
//

import UIKit
import CoreData

extension ModalViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveJokeButtonTapped(saveJokeButton)
        return true
    }
}

class ModalViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var saveJokeButton: UIButton!
    weak var delegate: Refreshable? {
        didSet {
            print("💉 delegate 주입 완료!")
        }
    }
    
    @IBAction func saveJokeButtonTapped(_ sender: UIButton) {
        var jokeCategory: Joke.Category
        
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
    
    func saveContext(content: String, category: Joke.Category) {
        // 1. entity 가져온다.
        let entity = NSEntityDescription.entity(forEntityName: "Joke", in: CoreDataManager.shared)
        guard let entity = entity else {
            print("❌ entity 에 nil 잡혔다!")
            return
        }
        
        // 2. NSManagedObject 만든다.
        let newJoke = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared)
        
        // 3. NSManagedObject 값을 세팅한다.
        newJoke.setValue(UUID(), forKey: "id")
        newJoke.setValue(content, forKey: "body")
        newJoke.setValue(category.rawValue, forKey: "category")
        
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
}
