//
//  Movie.swift
//  TableViewGA
//
//  Created by Marina De Pazzi on 25/05/23.
//

import Foundation
import UIKit

struct Movie: CustomStringConvertible {
    
    var id: Int
    var title: String
    var overview: String
    var voteAverage: Double
    var posterPath: String
    
    var imageCover: UIImage?
    
    var description: String {
        return "\(self.id)" + " - " + self.title
    }
}
