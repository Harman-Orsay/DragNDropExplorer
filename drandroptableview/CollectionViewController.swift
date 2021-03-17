//
//  CollectionViewController.swift
//  drandroptableview
//
//  Created by Rohan Ramsay on 16/03/21.
//

import UIKit

class CollectionViewController: UIViewController {

    //MARK: - Ignore
    
    var topCollectionView: UICollectionView!
    var bottomCollectionView: UICollectionView!
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Bottom collectionView supports Move - \nie Reorder\n" +
                     "Top collectionView only supports Drop - \nie Copy into\n" +
                     "You can Drag an item from Bottom collectionView & Drop into Top one - \nie Copy Paste"
        label.numberOfLines = 0
        return label
    }()
    
    let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "TOP ONE"
        return label
    }()
    
    let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "BOTTOM ONE (duh)"
        return label
    }()
    
    var topData: [UIColor] = [.red, .black, .blue, .cyan, .green]
    var bottomData: [UIColor] = [.yellow, .purple, .systemPink, .orange, .magenta]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup(collectionView: &topCollectionView)
        setup(collectionView: &bottomCollectionView)
        view.addSubview(topCollectionView)
        view.addSubview(bottomCollectionView)
        view.addSubview(topLabel)
        view.addSubview(bottomLabel)
        view.addSubview(descriptionLabel)
        topCollectionView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        descriptionLabel.bottomAnchor.constraint(equalTo: topLabel.topAnchor, constant: -8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        bottomLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        bottomLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true

        topCollectionView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8).isActive = true
        bottomCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomLabel.topAnchor.constraint(equalTo: topCollectionView.bottomAnchor, constant: -16).isActive = true
        bottomCollectionView.topAnchor.constraint(equalTo: bottomLabel.bottomAnchor, constant: 8).isActive = true
        topCollectionView.heightAnchor.constraint(equalTo: bottomCollectionView.heightAnchor, multiplier: 1).isActive = true
        topCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        topCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -8).isActive = true
        bottomCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant:  8).isActive = true
        bottomCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
    }
    
    func setup(collectionView: inout UICollectionView?) {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let totalWidth = view.frame.width
        let margin: CGFloat = 10
        let cellsPerRow: CGFloat = 4
        let totalMargin: CGFloat = margin * (cellsPerRow - 1)
        let availableWidth = totalWidth - 16 - totalMargin
        let cellWidth = availableWidth / cellsPerRow
        let cellHeight = cellWidth * 9/16
        flowLayout.minimumLineSpacing = margin
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView?.collectionViewLayout = flowLayout
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.dataSource = self
        collectionView?.dragDelegate = self
        collectionView?.dragInteractionEnabled = true
        collectionView?.dropDelegate = self
        collectionView?.backgroundColor = .white
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === topCollectionView ? topData.count : bottomData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = collectionView === topCollectionView ? topData[indexPath.row] : bottomData[indexPath.row]
        return cell
    }
}

//MARK: - CollectionView Drag & Drop

extension CollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if collectionView === topCollectionView {return []}
        let item = bottomData[indexPath.row]
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension CollectionViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationPath = indexPath
        } else {
            if collectionView === topCollectionView {
                destinationPath = IndexPath(row: topData.count, section: 0)
            } else {
                return
            }
        }
        
        guard let droppedItem = coordinator.items.first else { return }
            
        if coordinator.proposal.operation == .move {
            guard let sourceIndexPath = droppedItem.sourceIndexPath else {return}
            collectionView.performBatchUpdates({
                let color =  bottomData.remove(at: sourceIndexPath.row)
                bottomData.insert(color, at: destinationPath.row)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationPath])
            }, completion: nil)
            coordinator.drop(droppedItem.dragItem, toItemAt: destinationPath)
        }
        
        if  coordinator.proposal.operation == .copy {
            guard let droppedColor = droppedItem.dragItem.localObject as? UIColor else { return }
                collectionView.performBatchUpdates({
                    topData.insert(droppedColor, at: destinationPath.row)
                    collectionView.insertItems(at: [destinationPath])
                }, completion: nil)
                
            coordinator.drop(droppedItem.dragItem, toItemAt: destinationPath)

            }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        else {
            return UICollectionViewDropProposal(operation: .copy)
        }
    }
}

