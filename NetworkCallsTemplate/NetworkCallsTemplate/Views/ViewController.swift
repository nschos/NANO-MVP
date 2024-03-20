//
//  ViewController.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 24/05/23.
//

import UIKit

//MARK: - ViewController
class ViewController: UIViewController {
    
    static let cellID: String = "smallMovieCell"
    static let segueID: String = "toDetails"
    
    @IBOutlet weak var tableView: UITableView!
    
    private var moviePresenter = MoviesPresenter()
    
    //MARK: View loading methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moviePresenter.setViewDelegate(listMoviesViewDelegate: self)
        moviePresenter.fetchData()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Self.segueID,
           let presenter = sender as? MoviesPresenter {
            let destination = segue.destination as! DetailsViewController
            // let detailsPresenter = presenter.makeDetailsPresenter(for: index)
//            destination.setDetailsPresenter(detailsPresenter: detailsPresenter)

        }
    }
}

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentSection = indexPath.section
        
        moviePresenter.prepareForSegue(section: currentSection, rowNumber: indexPath.row)
        self.performSegue(withIdentifier: Self.segueID, sender: moviePresenter)
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return moviePresenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return moviePresenter.getSectionName(sectionNumber: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        var content = header.defaultContentConfiguration()
        
        content.text = moviePresenter.getSectionName(sectionNumber: section)
        content.textProperties.font = .preferredFont(forTextStyle: .headline)
        content.textProperties.color = .label
        
        header.contentConfiguration = content
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return moviePresenter.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentSection = indexPath.section
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! SmallMovieCell
        
        moviePresenter.getImage(indexPath: indexPath, rowNumber: indexPath.row, section: currentSection) { image in
            if let correctImage = image {
                cell.posterView.image = correctImage
            }
        }
        cell.titleLabel.text = moviePresenter.getName(rowNumber: indexPath.row, section: currentSection)
        cell.descriptionLabel.text = moviePresenter.getDescription(rowNumber: indexPath.row, section: currentSection)
        cell.ratingLabel.text = "\(moviePresenter.getRating(rowNumber: indexPath.row, section: currentSection))"
        return cell
    }
}

extension ViewController: ListMoviesViewDelegate{
    func updateData() {
        self.tableView.reloadData()
    }
    
    func reloadTableViewAt(indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
