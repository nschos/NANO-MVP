//
//  SmallMoviePosterView.swift
//  NetworkCallsGA
//
//  Created by Marina De Pazzi on 29/06/23.
//

import UIKit

class SmallMoviePosterView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imagePosterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("SmallMoviePosterView", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
    }

}
