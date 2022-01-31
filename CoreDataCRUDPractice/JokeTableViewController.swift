//
//  TableViewController.swift
//  CoreDataCRUDPractice
//
//  Created by 유재호 on 2022/01/24.
//

import UIKit
import CoreData

protocol Refreshable: AnyObject {
    
    func refresh()
}

class JokeTableViewController: UITableViewController {
    
    private func fetchJokeData() -> [Joke] {
        // NSFetchRequest 는 '쿼리'다. 만들어서 누군가에게 던져야 한다.
        // 수박이 오늘 중요한 거 2가지 있다고 -> managedObjectContext, managedObjectModel
        // 모델에 명령을 내리는 주체가 Context. context 를 통해 데이터를 읽어와야 한다.
        let request = Joke.fetchRequest()
        let fetchedData = try? CoreDataManager.shared.fetch(request)
        return fetchedData?.reversed() ?? [] // 최신 조크가 위로 올라오도록, 순서 뒤집어서 내보내기
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchJokeData().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        let eachJokeData = fetchJokeData()[indexPath.row]
        
        content.text = eachJokeData.body
        
        switch eachJokeData.category {
        case JokeMessage.Category.buzzWord.rawValue:
            content.secondaryAttributedText = NSAttributedString(
                string: "유행어",
                attributes: [.foregroundColor: UIColor.systemRed]
            )
        case JokeMessage.Category.dadJoke.rawValue:
            content.secondaryAttributedText = NSAttributedString(
                string: "아재개그",
                attributes: [.foregroundColor: UIColor.systemBlue]
            )
        default:
            content.secondaryText = "undefined"
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
    }
    
    @objc private func handleRefreshControl() {
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVC = segue.destination as? ModalViewController {
            nextVC.delegate = self
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let eachJokeData = fetchJokeData()[indexPath.row]
            
            // 삭제하는 조크의 id 를 기준으로 삭제하는 건 어떻게 하지?
            // let deleteTargetID = eachJokeData.id
            
            // 삭제했으면 저장까지 해줘야, 앱을 종료했다 다시 켰을 때에도 반영됨!
            do {
                CoreDataManager.shared.delete(eachJokeData)
                try CoreDataManager.shared.save()
                print("🔑 object 삭제 후 저장 완료!")
            } catch {
                print("❌ 삭제 후 저장 실패!")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension JokeTableViewController: Refreshable {
    
    func refresh() {
        handleRefreshControl()
    }
}
