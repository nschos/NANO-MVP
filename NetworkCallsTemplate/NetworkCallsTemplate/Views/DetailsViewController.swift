//
//  DetailsViewController.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 25/05/23.
//

import UIKit

class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    static var cellID: String = "detailCell"
    
    var moviePresenter: MoviesPresenter!
    

    var section: Int = 0
    var rowNumber: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.moviePresenter.setViewDelegate(listMoviesViewDelegate: self)
        
        section = moviePresenter.getDetailsSection()
        rowNumber = moviePresenter.getDetailsRow()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DetailsViewController: UITableViewDataSource, ListMoviesViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! DetailsMovieCell
        
        moviePresenter.getImage(indexPath: indexPath, rowNumber: self.rowNumber, section: self.section) { image in
            if let correctImage = image {
                cell.posterView.image = correctImage
            }
        }
        cell.titleLabel.text = moviePresenter.getName(rowNumber: self.rowNumber, section: self.section)
        cell.tagsLabel.text = moviePresenter.getGenres(rowNumber: self.rowNumber, section: self.section)
        cell.ratingsLabel.text = "\(moviePresenter.getRating(rowNumber: self.rowNumber, section: self.section))"
        cell.descriptionLabel.text = moviePresenter.getDescription(rowNumber: self.rowNumber, section: self.section)
        
        return cell
    }
    
    func updateData() {
        self.tableView.reloadData()
    }
    
    func reloadTableViewAt(indexPath: IndexPath) {
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
