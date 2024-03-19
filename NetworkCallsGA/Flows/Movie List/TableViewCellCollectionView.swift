//
//  TableViewCellCollectionView.swift
//  NetworkCallsGA
//
//  Created by Marina De Pazzi on 30/06/23.
//

import UIKit

protocol TableViewCellCollectionViewDelegate: AnyObject {
    func didSelectItemAt(indexPath: IndexPath)
}

class TableViewCellCollectionView: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    static var cellID = "tableCellCollectionView"
    
    weak var delegate: TableViewCellCollectionViewDelegate?
    
    var nowPlaying = [Movie]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        self.selectionStyle = .none
    }
}

extension TableViewCellCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didSelectItemAt(indexPath: indexPath)
    }
}

//MARK: - UICollectionViewDataSource
extension TableViewCellCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nowPlaying.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CompactMovieCellCollectionViewCell.cellID, for: indexPath) as! CompactMovieCellCollectionViewCell
        
        let movie = self.nowPlaying[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}
