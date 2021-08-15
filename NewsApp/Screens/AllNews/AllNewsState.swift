//
//  AllNewsState.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 12.08.21.
//

import CoreData

struct AllNewsState {
    enum Change {
        case idle
        case error(error: Error)
        case loading
        case loaded(articles: [Article])
        case articleSaved(title: NSManagedObject)
    }
}
