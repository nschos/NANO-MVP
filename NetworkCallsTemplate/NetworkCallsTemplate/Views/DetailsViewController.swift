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
    
    private var detailsPresenter: DetailsPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setDetailsPresenter(detailsPresenter: DetailsPresenter) {
        self.detailsPresenter = detailsPresenter
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        detailsPresenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! DetailsMovieCell
        
        let detailViewModel = detailsPresenter.makeDetailViewModel(for: indexPath.row)
        
        cell.posterView.image = UIImage(data: detailViewModel.imageCoverData ?? Data())
        cell.titleLabel.text = detailViewModel.title
        cell.descriptionLabel.text = detailViewModel.description
        cell.tagsLabel.text = detailViewModel.overview
        cell.ratingsLabel.text = detailViewModel.voteAverage
        
        return cell
    }
    
}

private extension DetailsPresenter {
    
    typealias DetailViewModel = (imageCoverData: Data?, title: String, description: String, overview: String, voteAverage: String)
    
    func makeDetailViewModel(for index: Int) -> DetailViewModel {
        let imageCoverData = getImageCoverData()
        let title = getTitle()
        let description = getDescription()
        let overview = getOverview()
        let voteAverage = getVoteAverage()
        
        let detailViewModel = DetailViewModel(imageCoverData: imageCoverData, 
                                              title: title,
                                              description: description,
                                              overview: overview,
                                              voteAverage: voteAverage)
        
        return detailViewModel
    }
    
}
