//
//  MovieListViewController.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 24/05/23.
//

import UIKit
import Combine

//MARK: - MovieListViewController
class MovieListViewController: UIViewController {
    //MARK: UITableView Sections
    enum Section: Int, CaseIterable {
        case nowPlaying
        case popular
        
        var value: String {
            switch self {
                case .nowPlaying:
                    return "Now Playing"
                case .popular:
                    return "Popular"
            }
        }
    }
    
    //MARK: Properties and Outlets
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var footerRefreshControl: UIView = {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
    }()

    private static let segueID: String = "toDetails"
    
    private let service: MovieService = MovieService()
    
    private var sections: [Section] = Section.allCases
    private var nowPlaying: [Movie] = []
    private var popular: [Movie] = []
    
    private var currentPage: Int = 1
    private var isPaginating: Bool = false
    
    private var subscriptions = Set<AnyCancellable>()
    
    //MARK: View Loading Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setRefreshControl()
        
        //MARK: - @escaping closures
//        self.service.fetchMovies(fromPlaylist: .nowPlaying, withCompletionBlock: { [weak self] (movies, error) in
//            if error == nil {
//                self?.nowPlaying = movies
//            }
//
//            self?.reloadData()
//        })
//
//        self.service.fetchMovies(fromPlaylist: .popular, withCompletionBlock: { [weak self] (movies, error) in
//            if error == nil {
//                self?.popular = movies
//            }
//
//            self?.reloadData()
//        })
        
        //MARK: - Async
        
        Task.init(priority: .userInitiated, operation: {
            self.nowPlaying = await self.service.fetchMovies(fromPlaylist: .nowPlaying)
            self.popular = await self.service.fetchMovies(fromPlaylist: .popular)
            self.reloadData()
        })
        
        //MARK: - Combine
        //self.fetchAllMovies()
    }
    
    //MARK: - View Code views setups
    private func setRefreshControl() {
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func fetchPagination(page: Int) {
        self.isPaginating = true
        self.service.fetchMovies(fromPlaylist: .popular, atPage: page)
            .flatMap({ movies in
                movies.publisher//.setFailureType(to: Error.self)
            })
            .flatMap({ movie in
                return self.service.fetchMoviePosterFor(posterPath: movie.posterPath)
                    .map({ data in
                        var newMovie = movie
                        newMovie.imageCover = UIImage(data: data)
                        return newMovie
                    })
                    .catch { _ in Just(movie) }
            })
            .collect()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                    case .failure(let error):
                        self?.isPaginating = false
                        print(error)
                    case .finished:
                        self?.isPaginating = false
                        return
                }
            }, receiveValue: { [weak self] popular in
                self?.popular.append(contentsOf: popular)
                self?.tableView.tableFooterView = nil
                self?.isPaginating = false
                self?.currentPage+=1
                self?.reloadData()
            })
            .store(in: &subscriptions)
    }
    
    private func fetchAllMovies() {
        self.service.fetchMovies(fromPlaylist: .popular)
            .flatMap({ movies in
                movies.publisher//.setFailureType(to: Error.self)
            })
            .flatMap({ movie in
                return self.service.fetchMoviePosterFor(posterPath: movie.posterPath)
                    .map({ data in
                        var newMovie = movie
                        newMovie.imageCover = UIImage(data: data)
                        return newMovie
                    })
                    .catch { _ in Just(movie) }//If any publisher fails a midst pipeline, everything eles fails
            })
            .collect()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        return
                }
            }, receiveValue: { popular in
                self.popular = popular
                self.reloadData()
            })
            .store(in: &subscriptions)
        
        self.service.fetchMovies(fromPlaylist: .nowPlaying)
            .flatMap({ movies in
                movies.publisher.setFailureType(to: Error.self)
            })
            .flatMap({ movie in
                return self.service.fetchMoviePosterFor(posterPath: movie.posterPath)
                    .map({ data in
                        var newMovie = movie
                        newMovie.imageCover = UIImage(data: data)
                        return newMovie
                    })
            })
            .collect()
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        return
                }
            }, receiveValue: { nowPlaying in
                self.nowPlaying = nowPlaying
                self.reloadData()
            })
            .store(in: &subscriptions)
        
        //In case you want to make 2 asynchronous calls at the same time
//        popular
//            .zip(nowPlaying)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                    case .failure(let error):
//                        print(error)
//                    case .finished:
//                        return
//                }
//            }, receiveValue: { popular, nowPlaying in
//                self.popular = popular
//                self.nowPlaying = nowPlaying
//                self.reloadData()
//            })
//            .store(in: &subscriptions)
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Selectors
    @objc
    private func refresh(sender: UIRefreshControl) {
        self.fetchAllMovies()
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.segueID,
           let movie = sender as? Movie {
            let destination = segue.destination as! DetailsViewController
            
            destination.movie = movie
        }
    }
}

//MARK: - UITableViewDelegate
extension MovieListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        
        content.text = self.sections[section].value
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.textProperties.color = .label
        
        header.contentConfiguration = content
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentSection = self.sections[indexPath.section]
        
        switch currentSection {
            case .nowPlaying:
                self.performSegue(withIdentifier: Self.segueID, sender: self.nowPlaying[indexPath.row])
            case .popular:
                self.performSegue(withIdentifier: Self.segueID, sender: self.popular[indexPath.row])
        }
    }
}

//MARK: - UITableViewDataSource
extension MovieListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].value
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = self.sections[section]
        
        switch currentSection {
            case .nowPlaying:
                return 1
            case .popular:
                return self.popular.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = self.sections[indexPath.section]
        
        switch currentSection {
            case .nowPlaying:
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellCollectionView.cellID, for: indexPath) as! TableViewCellCollectionView
                cell.delegate = self
                cell.nowPlaying = self.nowPlaying
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
                
                return cell
            case .popular:
                let cell = tableView.dequeueReusableCell(withIdentifier: SmallMovieCell.cellID, for: indexPath) as! SmallMovieCell
                
                let movie = self.popular[indexPath.row]
                cell.configure(with: movie)
                
                return cell
        }
    }
}

//MARK: - UIScrollViewDelegate
extension MovieListViewController: UIScrollViewDelegate {
    
    enum K {
        static let tableViewEndMargin = 100.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if !self.isPaginating {
            if position > (self.tableView.contentSize.height-K.tableViewEndMargin-scrollView.frame.size.height) {
                self.tableView.tableFooterView = self.footerRefreshControl
                fetchPagination(page: self.currentPage)
            }
        }
    }
}

extension MovieListViewController: TableViewCellCollectionViewDelegate {
    func didSelectItemAt(indexPath: IndexPath) {
        self.performSegue(withIdentifier: Self.segueID, sender: self.nowPlaying[indexPath.row])
    }
}
