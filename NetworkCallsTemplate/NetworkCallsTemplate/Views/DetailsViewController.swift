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
    
    var movie: Movie!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! DetailsMovieCell
        
        cell.posterView.image = UIImage(data:self.movie.imageCover!)
        cell.titleLabel.text = self.movie.title
        cell.tagsLabel.text = MovieService().getGenresText(listId: self.movie.genre_ids)
        cell.ratingsLabel.text = "\(self.movie.vote_average)"
        cell.descriptionLabel.text = self.movie.overview
        
        return cell
    }
}
