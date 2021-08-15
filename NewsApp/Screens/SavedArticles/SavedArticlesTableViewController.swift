//
//  SavedArticlesTableViewController.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 13.08.21.
//

import UIKit
import CoreData

class SavedArticlesTableViewController: UITableViewController {

    var savedArticles: [NSManagedObject] = []
    var managedContext: NSManagedObjectContext = NSManagedObjectContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved Articles"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: String(describing: TitleTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: TitleTableViewCell.self))
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
          return
      }

      managedContext =
        appDelegate.persistentContainer.viewContext

      let fetchRequest =
        NSFetchRequest<NSManagedObject>(entityName: "SavedArticle")

      do {
        savedArticles = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        savedArticles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: TitleTableViewCell.self), for: indexPath) as! TitleTableViewCell
        let article = savedArticles[indexPath.row]
        cell.titleLabel.text = article.value(forKeyPath: "title") as? String
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedContext.delete(savedArticles[indexPath.row])
            savedArticles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleUrl = savedArticles[indexPath.row].value(forKeyPath: "url")
        guard let url = articleUrl else { return }
        let articleWebViewController = ArticleWebViewController(urlString: String(describing: url))

        navigationController?.pushViewController(articleWebViewController, animated: true)
    }

}
