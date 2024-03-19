//
//  MovieService.swift
//  NetworkCallsGA
//
//  Created by Marina De Pazzi on 02/06/23.
//

import Foundation
import Combine
import UIKit

//MARK: - MovieService
struct MovieService {
    //MARK: Movie Types
    enum MoviePlaylist: String {
        case popular = "popular"
        case nowPlaying = "now_playing"
    }
    //MARK: Poster Sizes
    enum PosterSize: String {
        case w92 = "92"
        case w154 = "154"
        case w185 = "185"
        case w342 = "342"
        case w500 = "500"
        case w780 = "780"
        case original = "original"
    }
    typealias MovieJSON = [String: Any]
}

//MARK: - Fetch Movies
extension MovieService {
    //MARK: Fetch Movies with completion Handler
    @available(*, deprecated, message: "fetchMovies(fromPlaylist: ) available with concurrent API")
    func fetchMovies(fromPlaylist type: MoviePlaylist = .popular, withCompletionBlock completionBlock: @escaping ([Movie], Error?) -> Void ) {
        let url = self.buildAPIUrlFor(movieCategory: type.rawValue, atPage: 1)
        let dispatchSempahore = DispatchSemaphore(value: 0)
        
        var movies: [Movie] = []
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error ) in
            guard let response = response as? HTTPURLResponse,
            response.statusCode == 200,
                  let data = data,
            error == nil else {
                completionBlock([], NSError(domain: "Request Error: \(String(describing: error))", code: 0))
                dispatchSempahore.signal()
                return
            }
            
            guard let decodedMovies = decodeWithProtocols(data) else {
                completionBlock([], NSError(domain: "Request Error: \(String(describing: error))", code: 0))
                dispatchSempahore.signal()
                return
            }
            
            movies = decodedMovies
            dispatchSempahore.signal()
        })
        .resume()
        
        dispatchSempahore.wait()
        
        var moviesWithImages: [Movie] = []
        let dispatchGroup = DispatchGroup()
        let imageSemaphore = DispatchSemaphore(value: 1)
        
        for movie in movies {
            let url = self.buildPosterURLFor(posterPath: movie.posterPath)
            dispatchGroup.enter()
            
            self.fetchMoviePoster(with: url, completionBlock: { image in
                let movieWithImage = Movie(id: movie.id, title: movie.title, overview: movie.overview, voteAverage: movie.voteAverage, posterPath: movie.posterPath, imageCover: image)
                imageSemaphore.wait()
                moviesWithImages.append(movieWithImage)
                imageSemaphore.signal()
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            completionBlock(moviesWithImages, nil)
        }
    }
    
    //MARK: Fetch Movies with concurrent API
    func fetchMovies(fromPlaylist type: MoviePlaylist = .popular) async -> [Movie] {
        let url = self.buildAPIUrlFor(movieCategory: type.rawValue, atPage: 1)
        let serverResponse = try? await URLSession.shared.data(for: URLRequest(url: url))
        
        guard let serverResponse = serverResponse else { return [] }
        let data = serverResponse.0
        
        do {
            return try JSONDecoder().decode(MovieResponse.self, from: data).results
        } catch {
            return []
        }
    }
    
    //MARK: Fetch Movies with Combine API
    func fetchMovies(fromPlaylist type: MoviePlaylist = .popular, atPage page: Int = 1) -> AnyPublisher<[Movie], Error> {
        let url = self.buildAPIUrlFor(movieCategory: type.rawValue, atPage: page)
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .decode(type: MovieResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .mapError({ $0 as Error })
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

//MARK: - Fetch Movie Posters
extension MovieService {
    //MARK: Fetch Movie poster with completion handler
    func fetchMoviePoster(with url: URL, completionBlock: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else { completionBlock(nil); return }
            let image = UIImage(data: data)
            completionBlock(image)
        }
    }
    
    //MARK: Fetch Movie poster with Combine API
    func fetchMoviePosterFor(posterPath: String, withSize size: PosterSize = .w500) -> AnyPublisher<Data, Error> {
        let url = self.buildPosterURLFor(posterPath: posterPath)
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(\.data)
            .mapError({ $0 as Error })
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

//MARK: - URL formatting
extension MovieService {
    private func buildAPIUrlFor(movieCategory: String, atPage page: Int) -> URL {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieCategory)?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=\(page)"
        guard let url = URL(string: urlString) else {
            //in case something happens, return a default first page of popular movies
            return URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=29e140b5aab9879b19e9118a0af356c9&language=en-US&page=1")!
        }
        
        return url
    }
    
    private func buildPosterURLFor(posterPath: String, withSize size: PosterSize = .w500) -> URL {
        let urlString = "https://image.tmdb.org/t/p/\(size)\(posterPath)"
        guard let url = URL(string: urlString) else {
            //in case something happens, return a default poster size of 500
            return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")!
        }
        
        return url
    }
}

//MARK: - Decoding
extension MovieService {
    private func decodeWithProtocols(_ data: Data) -> [Movie]? {
        do {
            return try JSONDecoder().decode(MovieResponse.self, from: data).results
        } catch {
            print(error)
            return nil
        }
    }
    
    private func decodeRoots(data: Data) -> [Movie]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? MovieJSON
            guard let movies = json?["results"] as? [MovieJSON] else { return nil }
            var auxMovies: [Movie] = []
            
            for movie in movies {
                guard let id = movie["id"] as? Int,
                      let title = movie["title"] as? String,
                      let overview = movie["overview"] as? String,
                      let voteAverage = movie["vote_average"] as? Double,
                      let posterPath = movie["poster_path"] as? String
                else { continue }

                let auxMovie = Movie(id: id, title: title, overview: overview, voteAverage: voteAverage, posterPath: posterPath)
                auxMovies.append(auxMovie)
            }
            
            return auxMovies
        }
        catch {
            return nil
        }
    }
}

