//
//  SBCollectionViewController.swift
//  drandroptableview
//
//  Created by Rohan Ramsay on 17/03/21.
//

import UIKit

class SBCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var data: [UIColor] = [.red, .white, .blue, .cyan, .green, .brown, .magenta, .gray, .systemTeal]
    let immovableDataIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @IBAction func buttonTapped(_ sender: Any) {
        navigationController?.pushViewController(CollectionViewController(), animated: true)
    }
}

extension SBCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = data[indexPath.item]
        return cell
    }
}

extension SBCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        indexPath.item == 1 ? false : true // return false to prevent gesture recogniser from starting
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionView.performBatchUpdates({
            let immovableItem = data[immovableDataIndex]
            data.insert(data.remove(at: sourceIndexPath.item), at: destinationIndexPath.item)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
            
            if let newIndex = data.firstIndex(of: immovableItem), newIndex != immovableDataIndex{
                data.insert(data.remove(at: newIndex), at: immovableDataIndex)
                //dont try to insert, delete, update -- will Crash!
            }
            
        }, completion: { finished in //to clean up for immovable index
            if finished {
                collectionView.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView,
    targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
    toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        //TO PREVENT moving to a specific location
        if originalIndexPath.item == immovableDataIndex {
            return originalIndexPath
        }
        
        if proposedIndexPath.item == immovableDataIndex {
            return originalIndexPath
        }
        
        return proposedIndexPath
    }
    
    //MARK: - Da Method
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}
