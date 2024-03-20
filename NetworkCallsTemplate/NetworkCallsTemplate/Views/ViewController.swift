//
//  ViewController.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 24/05/23.
//

import UIKit

//MARK: - ViewController
class ViewController: UIViewController {
    //MARK: TableView Sections
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
    
    //MARK: Outlets and Variables setup
    static let cellID: String = "smallMovieCell"
    static let segueID: String = "toDetails"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var sections: [Section] = Section.allCases
    private var nowPlaying: [Movie] = []
    private var popular: [Movie] = []
    private var movieService = MovieService()
    
    //MARK: View loading methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieService.tableDelegate = self
        
        movieService.fetchData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //MARK: Refresh UI
    private func reloadData() {
        DispatchQueue.main.async {
            self.nowPlaying = self.movieService.movieListNow
            self.popular = self.movieService.movieListPop
            self.tableView.reloadData()
        }
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.segueID,
           let movie = sender as? Movie {
            let destination = segue.destination as! DetailsViewController
            // let detailsPresenter = presenter.makeDetailsPresenter(for: index)
//            destination.setDetailsPresenter(detailsPresenter: detailsPresenter)
        }
    }
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate, tableReload {
    func willReload() {
        
        self.reloadData()
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
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].value
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        
        content.text = self.sections[section].value
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.textProperties.color = .label
        
        header.contentConfiguration = content
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentSection = self.sections[section]
        
        switch currentSection {
            case .nowPlaying:
                return self.nowPlaying.count
            case .popular:
                return self.popular.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = self.sections[indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! SmallMovieCell
        switch currentSection {
            case .nowPlaying:
            if let imageData = self.nowPlaying[indexPath.row].imageCover {
                cell.posterView.image = UIImage(data: imageData)
            }
            else {
            
                movieService.getImage(urlString: self.nowPlaying[indexPath.row].poster_path) { image, urlString in
    
                    guard let characterIndex = self.nowPlaying.firstIndex(where: { $0.poster_path == urlString }) else { return }
                    
                    self.nowPlaying[characterIndex].imageCover = image.jpegData(compressionQuality: 1)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }

                cell.titleLabel.text = self.nowPlaying[indexPath.row].title
                cell.descriptionLabel.text = self.nowPlaying[indexPath.row].overview
                cell.ratingLabel.text = "\(self.nowPlaying[indexPath.row].vote_average)"
                
                return cell
            case .popular:
            if let imageData = self.popular[indexPath.row].imageCover {
                cell.posterView.image = UIImage(data: imageData)
            }
            else {
            
                movieService.getImage(urlString: self.popular[indexPath.row].poster_path) { image, urlString in
    
                    guard let characterIndex = self.popular.firstIndex(where: { $0.poster_path == urlString }) else { return }
                    
                    self.popular[characterIndex].imageCover = image.jpegData(compressionQuality: 1)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
                cell.titleLabel.text = self.popular[indexPath.row].title
                cell.descriptionLabel.text = self.popular[indexPath.row].overview
                cell.ratingLabel.text = "\(self.popular[indexPath.row].vote_average)"
                
                return cell
        }
    }
}

// Na outra branch

// Presenter deles

//func makeDetailsPresenter(for index: Int) -> DetailsPresenter {
//
//      let selectedMovie = service.movies[index]
//
//      let detailsPresenter = DetailsPresenter(selectedMovie: selectedMovie)
//
//      return detailsPresenter
//
//}
