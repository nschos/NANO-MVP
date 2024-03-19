//
//  CompactMovieCellCollectionViewCell.swift
//  NetworkCallsGA
//
//  Created by Marina De Pazzi on 30/06/23.
//

import UIKit

class CompactMovieCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var compactMoviePosterView: CompactMoviePosterView!
    
    private var isHeightCalculated: Bool = false
    static var cellID = "compactMovieCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.compactMoviePosterView.imagePosterView.layer.cornerRadius = 12
    }
    
    func configure(with movie: Movie) {
        self.compactMoviePosterView.imagePosterView.image = movie.imageCover
        self.compactMoviePosterView.titleLabel.text = movie.title
        self.compactMoviePosterView.ratingLabel.text = movie.voteAverage.description
    }
    
}
