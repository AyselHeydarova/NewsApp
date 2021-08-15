//
//  AllNewsViewController.swift
//  NewsApp
//
//  Created by Aysel Heydarova on 11.08.21.
//

import CoreData
import UIKit

enum FilterSortTypes: String {
    case country
    case category
    case sources
    case from
    case sortBy
    case all
}

class AllNewsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var viewModel = AllNewsViewModel()
    var activityIndicator = UIActivityIndicatorView(style: .large)
    let searchController = UISearchController(searchResultsController: nil)
    var pageCount = 1
    var filterSortType: FilterSortTypes = .all
    var selectedType: String = ""
    var savedArticles: [NSManagedObject] = [] {
        didSet {
            setupTabBar()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        render(state: .idle)
    }

    private func setupUI() {
        title = "Latest News"
        setupTable()
        setupTabBar()
        setupNavigation()
        setupSearchController()
        configureRefreshControl()
        activityIndicator.startAnimating()
        activityIndicator.center = view.center
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(UINib(nibName: String(describing: NewsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: NewsTableViewCell.self))
        tableView.addSubview(activityIndicator)
    }

    private func configureRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl),
                                            for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchTextField.textColor = .white
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func setupTabBar() {
        tabBarController?.tabBar.tintColor = .black
        tabBarItem.image = UIImage(named: "home")?.withTintColor(.black, renderingMode: .alwaysTemplate)

        let savedArticlesVC = SavedArticlesTableViewController()
        savedArticlesVC.savedArticles = savedArticles
        let savedArticlesNavController = UINavigationController(rootViewController: savedArticlesVC)
        savedArticlesNavController.tabBarItem.image = UIImage(named: "Saved")
        savedArticlesNavController.tabBarItem.title = "Saved"

        tabBarController?.viewControllers = [UINavigationController(rootViewController: self), savedArticlesNavController]

    }

    private func setupNavigation() {
        let filterItem = UIBarButtonItem()
        let sortItem = UIBarButtonItem()

        sortItem.image = UIImage(named: "Sort")
        sortItem.tintColor = .black
        sortItem.menu = setupSortMenu()

        filterItem.image = UIImage(named: "Filter")
        filterItem.tintColor = .black
        filterItem.menu = setupFilterMenu()

        navigationItem.rightBarButtonItem = sortItem
        navigationItem.rightBarButtonItem?.width = 40
        navigationItem.leftBarButtonItem = filterItem
        navigationItem.leftBarButtonItem?.width = 40
    }

    private func setupFilterMenu() -> UIMenu {
        let countriesActions = createUIActionArray(from: viewModel.countries.map({$0.rawValue}), type: .country)
        let categoriesActions =  createUIActionArray(from: viewModel.categories.map({$0.rawValue}), type: .category)
        let sourcesActions =  createUIActionArray(from: viewModel.sources.map({$0.id ?? ""}), type: .sources)

        let countriesMenu = UIMenu(title: "Countries", image: nil, children: countriesActions)
        let categoriesMenu = UIMenu(title: "Categories", image: nil, children: categoriesActions)
        let sourcesMenu = UIMenu(title: "Sources", image: nil, children: sourcesActions)

        let menu = UIMenu(title: "Filter", children: [countriesMenu, categoriesMenu, sourcesMenu])
        return menu
    }

    private func setupSortMenu() -> UIMenu {
        let sortByActions =  createUIActionArray(from: viewModel.sortBy.map({$0.rawValue}), type: .sortBy)
        let menu =  UIMenu(title: "Sort By", children: sortByActions)
        return menu
    }

    private func createUIActionArray(from array: [String], type: FilterSortTypes) -> [UIAction] {
        array.map({ UIAction(title: $0,
                             image: nil,
                             identifier: nil,
                             discoverabilityTitle: nil,
                             attributes: .init(),
                             state: .on) { [self] action in
            filterSortType = type
            selectedType = action.title
            self.viewModel.loadNews(filterSortType: type, selectedType: action.title, page: pageCount)
        }})
    }

    private func render(state: AllNewsState.Change) {
        switch state {
        case .idle:
            setupUI()
            viewModel.loadNews(search: "Apple", filterSortType: .all, selectedType: "", page: pageCount)
            viewModel.changeHandler = { stateChange in
                self.render(state: stateChange)
            }
        case .loading:
            activityIndicator.startAnimating()
            tableView.tableFooterView = createSpinnerView()
        case .loaded(_):
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.setupNavigation()
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
            }
        case .error(let error):
            let alert = UIAlertController(title: "Error occured",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            show(alert, sender: self)
        case .articleSaved(title: let title):
            savedArticles.append(title)
        }
    }
}

extension AllNewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: String(describing: NewsTableViewCell.self), for: indexPath) as! NewsTableViewCell
        let article = viewModel.articles[indexPath.row]
        cell.selectionStyle = .none
        cell.saveButtonTapped = {
            self.viewModel.saveArticle(name: article.title, url: article.url)
        }
        cell.configure(imageURL: article.urlToImage ?? "",
                       title: article.title,
                       description: article.articleDescription ?? "",
                       source: article.source.name ?? "",
                       author: article.author ?? "")
        return cell
    }

    private func createSpinnerView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let articleUrl = viewModel.articles[indexPath.row].url
        let articleWebViewController = ArticleWebViewController(urlString: articleUrl)
        show(articleWebViewController, sender: self)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == viewModel.articles.count - 1 {
            pageCount += 1
            viewModel.loadNews(filterSortType: filterSortType,
                               selectedType: selectedType,
                               page: pageCount)
        }
    }
}

extension AllNewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.networkRequest.searchTerm = searchController.searchBar.text ?? ""
        pageCount = 1
        viewModel.loadNews(filterSortType: .all, selectedType: "", page: pageCount)
    }
}

