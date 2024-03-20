//
//  DetailsPresenter.swift
//  NetworkCallsTemplate
//
//  Created by Nathan Baptista Schostack on 19/03/24.
//

import Foundation

class DetailsPresenter {
    private let selectedMovie: Movie
    
    init(selectedMovie: Movie) {
        self.selectedMovie = selectedMovie
    }
    
    func numberOfRows() ->  Int {
        return 1
    }
    
    func getImageCoverData() -> Data? {
        return selectedMovie.imageCover
    }
    
    func getTitle() -> String {
        return selectedMovie.title
    }
    
    func getDescription() -> String {
        return selectedMovie.description
    }
    
    func getOverview() -> String {
        return selectedMovie.overview
    }
    
    func getVoteAverage() -> String {
        return "\(selectedMovie.vote_average)"
    }
}
