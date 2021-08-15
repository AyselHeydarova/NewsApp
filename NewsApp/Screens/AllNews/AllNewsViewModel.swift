//
//  AllNewsViewModel.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 12.08.21.
//

import UIKit
import CoreData

enum Category: String, CaseIterable {
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
}

enum Country: String, CaseIterable {
    case ru
    case tr
    case br
    case fr
    case jp
}

enum SortBy: String, CaseIterable {
    case relevancy
    case popularity
    case publishedAt
}


class AllNewsViewModel {

    var state = AllNewsState()
    var changeHandler: ((AllNewsState.Change) -> Void)?
    var articles: [Article] = []

    let networkRequest = NetworkRequest()
    var countries: [Country] = Country.allCases
    var categories: [Category] = Category.allCases
    var sortBy: [SortBy] = SortBy.allCases
    var sources: [Source] = [
        Source(id: "engadget", name: "Engadget"),
        Source(id: "wired", name: "Wired"),
        Source(id: "bbc-news", name: "BBC News"),
        Source(id: "techcrunch", name: "TechCrunch"),
        Source(id: "cnn", name: "CNN")
    ]
    

    func loadNews(search: String? = nil, filterSortType: FilterSortTypes, selectedType: String, page: Int) {
        changeHandler?(.loading)
        var endPoint: NewsEndpoints

        switch filterSortType {
        case .category, .country, .sources:
            endPoint = .topHeadlines(params: [
                .q: networkRequest.searchTerm,
                .page: "\(page)",
                filterSortType.rawValue: selectedType
            ])
        case .all, .from, .sortBy:
            endPoint = .everything(params:  [
                .q: networkRequest.searchTerm,
                .page: "\(page)",
                filterSortType.rawValue: selectedType
            ])
        }

        networkRequest.executeRequest(endPoint, page: page) { result in
            switch result {
            case .success(let news):
                if page == 1 {
                    self.articles = news.articles
                } else {
                    self.articles += news.articles
                }
                self.changeHandler?(.loaded(articles: news.articles))
            case .failure(let error):
                self.changeHandler?(.error(error: error))
            }
        }
    }

    func saveArticle(name: String, url: String) {
        
        guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "SavedArticle",
                                       in: managedContext)!

        let article = NSManagedObject(entity: entity,
                                      insertInto: managedContext)

        article.setValue(name, forKeyPath: "title")
        article.setValue(url, forKey: "url")

        do {
            try managedContext.save()
            self.changeHandler?(.articleSaved(title: article))
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}


