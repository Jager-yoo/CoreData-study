//
//  ViewController.swift
//  CoreDataCRUDPractice
//
//  Created by μ μ¬νΈ on 2022/01/24.
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
            print("π delegate μ£Όμ μλ£!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        // TODO: ν€λ³΄λ show, hide λμνκΈ°
    }
    
    @IBAction private func saveJokeButtonTapped(_ sender: UIButton) {
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
    
    private func saveContext(content: String, category: Joke.Category) {
        // 1. entity κ°μ Έμ¨λ€.
        let entity = NSEntityDescription.entity(forEntityName: "Joke", in: CoreDataManager.shared)
        guard let entity = entity else {
            print("β entity μ nil μ‘νλ€!")
            return
        }
        
        // 2. NSManagedObject λ§λ λ€.
        let newJoke = NSManagedObject(entity: entity, insertInto: CoreDataManager.shared)
        
        // 3. NSManagedObject κ°μ μΈννλ€.
        newJoke.setValue(UUID(), forKey: "id")
        newJoke.setValue(content, forKey: "body")
        newJoke.setValue(category.rawValue, forKey: "category")
        
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
}
