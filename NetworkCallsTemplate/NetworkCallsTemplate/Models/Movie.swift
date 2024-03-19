//
//  Movie.swift
//  NetworkCallsTemplate
//
//  Created by Felipe Araujo on 19/03/24.
//

import Foundation

protocol tableReload{
    func willReload()
}

enum MovieCategory{
    case popular
    case nowPlaying
}

struct MovieResponse: Decodable{
    var results: [Movie]
}

struct Movie: CustomStringConvertible, Decodable {
    
    var id: Int
    var title: String
    var overview: String
    var vote_average: Double
    var poster_path: String
    var genre_ids: [Int]
    
    var imageCover: Data?
    
    var description: String {
        return "\(self.id)" + " - " + self.title
    }
}
