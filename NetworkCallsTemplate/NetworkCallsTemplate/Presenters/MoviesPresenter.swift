//
//  MoviesPresenter.swift
//  NetworkCallsTemplate
//
//  Created by Felipe Araujo on 19/03/24.
//

import Foundation
import UIKit

protocol ListMoviesViewDelegate: NSObject{
    func updateData()
    func reloadTableViewAt(indexPath: IndexPath)
}

protocol PresenterDelegate{
    func updateValues()
}


class MoviesPresenter: PresenterDelegate {
    
    private var movieService =  MovieService()
    weak private var listMoviesViewDelegate: ListMoviesViewDelegate?
    
    
    private var popular = [Movie]()
    private var nowPlaying = [Movie]()
    
    private var detailsSection = 0
    private var detailsRowNumber = 0
    
    init() {
        self.movieService.presenterDelegate = self
    }
    
    func setViewDelegate(listMoviesViewDelegate: ListMoviesViewDelegate?){
        self.listMoviesViewDelegate = listMoviesViewDelegate
    }
    
    func getDetailsSection() -> Int{
        return detailsSection
    }
    
    func viewDidLoad(){
        movieService.fetchData {
            
        }
    }
    
    func getDetailsRow() -> Int{
        return detailsRowNumber
    }
    
    func prepareForSegue(section: Int, rowNumber: Int){
        self.detailsSection = section
        self.detailsRowNumber = rowNumber
    }
    
    func getName(rowNumber: Int, section: Int) -> String {
        if section == 0 {
            return nowPlaying[rowNumber].title
        }else{
            return popular[rowNumber].title
        }
    }
    
    func getNumberOfRowsInSection(section: Int) -> Int{
        if section == 0{
            return self.nowPlaying.count
        }else{
            return self.popular.count
        }
    }

    func getDescription(rowNumber: Int, section: Int) -> String{
        if section == 0 {
            return nowPlaying[rowNumber].overview
        }else{
            return popular[rowNumber].overview
        }
    }
    
    func getGenres(rowNumber: Int, section: Int) -> String{
        if section == 0{
            return movieService.getGenresText(listId: self.nowPlaying[rowNumber].genre_ids)
        }else{
            return movieService.getGenresText(listId: self.popular[rowNumber].genre_ids)
        }
    }
    
    func getImage(indexPath: IndexPath, rowNumber: Int, section: Int, completion: @escaping (UIImage?) -> Void){
        if section == 0 {
            if let imageData = self.nowPlaying[rowNumber].imageCover {
                completion(UIImage(data: imageData))
            }
            else {
            
                movieService.getImage(urlString: self.nowPlaying[rowNumber].poster_path) { image, urlString in
    
                    guard let characterIndex = self.nowPlaying.firstIndex(where: { $0.poster_path == urlString }) else { return }
                    
                    self.nowPlaying[characterIndex].imageCover = image.jpegData(compressionQuality: 1)
                    
                    DispatchQueue.main.async {
                        self.listMoviesViewDelegate?.reloadTableViewAt(indexPath: indexPath)
                    }
                }
            }
        }else{
            if let imageData = self.popular[rowNumber].imageCover {
                completion(UIImage(data: imageData))
            }
            else {
            
                movieService.getImage(urlString: self.popular[rowNumber].poster_path) { image, urlString in
    
                    guard let characterIndex = self.popular.firstIndex(where: { $0.poster_path == urlString }) else { return }
                    
                    self.popular[characterIndex].imageCover = image.jpegData(compressionQuality: 1)
                    
                    DispatchQueue.main.async {
                        self.listMoviesViewDelegate?.reloadTableViewAt(indexPath: indexPath)
                    }
                }
            }
        }
    }
    
    func getRating(rowNumber: Int, section: Int) -> Double{
        if section == 0 {
            return nowPlaying[rowNumber].vote_average
        }else{
            return popular[rowNumber].vote_average
        }
    }
    
    func getSectionName(sectionNumber: Int) -> String{
        if sectionNumber == 0 {
            return "Now Playing"
        }else{
            return "Popular"
        }
    }
    
    func getNumberOfSections() -> Int {
        return 2
    }
    
    func makeDetailsPresenter(section: Int, rowNumber: Int) -> DetailsPresenter {
        
        let selectedMovie = section == 0 ? nowPlaying[rowNumber] : popular[rowNumber]
        
        let detailsPresenter = DetailsPresenter(selectedMovie: selectedMovie)
        
        return detailsPresenter
    }
    
    func fetchData(){
        movieService.fetchData {
            //self.listMoviesViewDelegate?.updateData()
        }
    }
    
    func updateValues() {
        self.popular = movieService.movieListPop
        self.nowPlaying = movieService.movieListNow
        self.listMoviesViewDelegate?.updateData()
    }
    
    
}
