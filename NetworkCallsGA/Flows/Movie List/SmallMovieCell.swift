//
//  SmallMovieCell.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 24/05/23.
//

import UIKit

class SmallMovieCell: UITableViewCell {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    static let cellID: String = "smallMovieCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.posterView.layer.masksToBounds = true
        self.posterView.contentMode = .scaleAspectFill
        self.posterView.layer.cornerRadius = 12
    }
    
    func configure(with movie: Movie) {
        self.posterView.image = movie.imageCover
        self.titleLabel.text = movie.title
        self.descriptionLabel.text = movie.overview
        self.ratingLabel.text = "\(movie.voteAverage)"
    }
}
