//
//  DetailsPresenter.swift
//  NetworkCallsTemplate
//
//  Created by Nathan Baptista Schostack on 19/03/24.
//

import Foundation

class DetailsPresenter {
    private let selectedMovie: Movie
    private let movieService = MovieService()
    
    init(selectedMovie: Movie) {
        self.selectedMovie = selectedMovie
    }
    
    func numberOfRows() ->  Int {
        return 1
    }
    
    func getTags() -> String {
        return movieService.getGenresText(listId: selectedMovie.genre_ids)
    }
    
    func getImageCoverData() -> Data? {
        return selectedMovie.imageCover
    }
    
    func getTitle() -> String {
        return selectedMovie.title
    }
    
    func getDescription() -> String {
        return selectedMovie.overview
    }
    
    func getOverview() -> String {
        return selectedMovie.overview
    }
    
    func getVoteAverage() -> String {
        return "\(selectedMovie.vote_average)"
    }
}
