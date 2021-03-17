//
//  ViewController.swift
//  drandroptableview
//
//  Created by Rohan Ramsay on 12/03/21.
//

import UIKit

enum Operation {
    case add
    case subtract
    
    func operate(destination: Int, source: Int) -> Int {
        switch self{
        case .add: return destination + source
        case .subtract: return destination - source
        }
    }
}

class TableViewController: UIViewController {
    
    @IBOutlet weak var operationSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    
    var data = [10, 20, 30, 40, 50, 60, 70] {
        didSet {
            tableView.reloadData()
        }
    }
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
        tableView.tableFooterView = UIView()
        tableView.isEditing = true
        operation = operationSwitch.isOn ? .subtract : .add
    }

    @IBAction func operationToggled(_ sender: Any) {
        operation = operationSwitch.isOn ? .subtract : .add
    }
    
}

extension TableViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else {return}
        data[destinationIndexPath.row] = operation.operate(destination: data[destinationIndexPath.row], source: data[sourceIndexPath.row])
    }
    
    //uncomment to enable delete button
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//    }
    
}

extension TableViewController: UITableViewDelegate {
    
    //return .none & return false in shouldIndent -- to hide delete icon when you want to just move!
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        operation == .add ? .insert : .delete
    }
    
    //return false to hide delete icon but you want to move rows
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
