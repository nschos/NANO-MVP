//
//  Service.swift
//  NetworkCallsTemplate
//
//  Created by Felipe Araujo on 28/06/23.
//

import Foundation

import UIKit


class MovieService: JSONDecoder{
    
    private var dictGenres: [Int: String] = [28:"Action", 12:"Adventure",16:"Animation",35:"Comedy",80:"Crime",99:"Documentary",18:"Drama", 10751 :"Family", 14  :"Fantasy", 36:"History",27:"Horror",10402:"Music",     9648:"Mystery",10749:"Romance",878:"Science Fiction", 10770:"TV Movie",53:"Thriller",    10752:"War", 37:"Western"]
    
    private var incompleteImageURL = "https://image.tmdb.org/t/p/w500/"
    
    private var nowURL = "https://api.themoviedb.org/3/movie/now_playing?language=en-US&page=1&api_key=70d908007f9009ecd412cca6ab70b158"
    
    private var popURL = "https://api.themoviedb.org/3/movie/popular?language=en-US&page=1&api_key=70d908007f9009ecd412cca6ab70b158"
    
    var rawDataPop: Data?
    var rawDataNow: Data?
    var tableDelegate: tableReload?
    var presenterDelegate: PresenterDelegate?
    
    var movieListPop: [Movie] = []
    var movieListNow: [Movie] = []
    
    func getGenresText(listId: [Int]) -> String{
        var list: [String] = []
        
        for id in listId{
            list.append(dictGenres[id]!)
        }
        
        let finalStr = list.joined(separator:", ")
        
        return finalStr
    }
    
    func fetchData(completion: @escaping () -> Void){
        
        let urlPop = URL(string: popURL)!
        let urlNow = URL(string: nowURL)!
        
        URLSession.shared.dataTask(with: urlPop) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else{ return }
            
            guard let data = data,
                  response.statusCode == 200,
                  error == nil
            else{
                print(error ?? "error")
                return
            }
            self.decodeData(data: data, movieType: .popular) {
                print("??")
                self.presenterDelegate?.updateValues()
            }
            
            
        }
        .resume()
        
        URLSession.shared.dataTask(with: urlNow) { (data, response, error) in
            guard let response = response as? HTTPURLResponse else{ return }
            
            guard let data = data,
                  response.statusCode == 200,
                  error == nil
            else{
                print(error ?? "error")
                return
            }
            
            self.decodeData(data: data, movieType: .nowPlaying) {
                self.presenterDelegate?.updateValues()
            }
            
        }
        .resume()
        
        completion()
    }
    
    func decodeData(data: Data, movieType: MovieCategory, closure: @escaping () -> Void){
        do{
            switch(movieType){
            case .nowPlaying:
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
            
                self.movieListNow = decodedResponse.results
            
            case .popular:
                let decodedResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                self.movieListPop = decodedResponse.results
            
            }
            
            DispatchQueue.main.async {
                closure()
            }
        }catch{
            print(error)
        }
    }
    
    func getImage(urlString: String, completionBlock: @escaping (UIImage, String) -> Void) {

        guard let url = URL(string: incompleteImageURL + urlString) else { fatalError() }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  error == nil,
                  let data = data
            else {
                print(error ?? "error")
                return
            }
            
            guard let image = UIImage(data: data) else { return }
            
            completionBlock(image, urlString)
        }
        .resume()
    }
    
}
