//
//  DetailsViewController.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 25/05/23.
//

import UIKit

//MARK: - DetailsViewController
class DetailsViewController: UIViewController {
    
    //MARK: - Properties and Outlets
    @IBOutlet weak var tableView: UITableView!
    
    private static var cellID: String = "detailCell"
    
    var movie: Movie!

    //MARK: View Loading Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

//MARK: - UITableViewDelegate
extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UITableViewDataSource
extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! DetailsMovieCell
        
        cell.posterView.image = self.movie.imageCover
        cell.titleLabel.text = self.movie.title
        cell.tagsLabel.text = self.movie.overview
        cell.ratingsLabel.text = "\(self.movie.voteAverage)"
        cell.descriptionLabel.text = self.movie.overview
        
        return cell
    }
}
