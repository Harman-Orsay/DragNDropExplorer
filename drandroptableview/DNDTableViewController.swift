//
//  DNDTableViewController.swift
//  DragnDropExplorer
//
//  Created by Rohan Ramsay on 17/03/21.
//

import UIKit


class DNDTableViewController: UIViewController {
    
    @IBOutlet weak var operationSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [10, 20, 30, 40, 50, 60, 70]
    
    var operation = Operation.add {
        didSet{
            tableView.isEditing = false
            tableView.reloadData()
            tableView.isEditing = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.isEditing = true
        operation = operationSwitch.isOn ? .subtract : .add
    }

    @IBAction func operationToggled(_ sender: Any) {
        operation = operationSwitch.isOn ? .subtract : .add
    }
    
}

extension DNDTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CELL")
        }
        cell?.textLabel?.text = "\(data[indexPath.row])"
        return cell!
    }
    
    //ONLY USED FOR SIDE EFFECT - + / - ICON
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    //ONLY USED FOR SIDE EFFECT - DRAG ICON
    //Does not do anything to drag & drop gesture!!!
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    //NO USE!
    //Drag & drop takes precedent -- this method will not be called when reordering
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else {return}
        data[destinationIndexPath.row] = operation.operate(destination: data[destinationIndexPath.row], source: data[sourceIndexPath.row])
    }
    
    //uncomment to enable delete button
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//    }
    
}

extension DNDTableViewController: UITableViewDelegate {
    
    //ONLY USED FOR SIDE EFFECT - + / - ICON
    //return .none & return false in shouldIndent -- to hide delete icon when you want to just move!
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        operation == .add ? .insert : .delete
    }
    
    //ONLY USED FOR SIDE EFFECT - + / - ICON
    //return false to hide icon but you want to move rows
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        operation == .add ? true : true
    }
}

//MARK: - Drag n Drop

extension DNDTableViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider()) //u dont Have to pass data -- within same table sourceIndexPath (passed automatically should be enough!)
        return [dragItem]
    }
}

extension DNDTableViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath, let sourceIndexPath = coordinator.items.first?.sourceIndexPath else { return }
        
        //situational logic
        guard destinationIndexPath.row < data.count && destinationIndexPath.row != sourceIndexPath.row else {return}
            
        tableView.performBatchUpdates({
            data[destinationIndexPath.row] = operation.operate(destination: data[destinationIndexPath.row], source: data[sourceIndexPath.row])
        }, completion: { finished in
            tableView.reloadData()
        })
    }
    
    
    //ONLY USED FOR SIDE EFFECT - insert into destination -- makes the destination row highlighted!
    //optional for ui-ux
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        
        let dropoperation: UIDropOperation  = operation == .add ? .copy : .move
        return UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
    }
    //IOS BUG - the proposal + icon for .add is shown outside the tableview's bounds -- basrely visible
}
