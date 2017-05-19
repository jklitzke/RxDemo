//
//  ViewController.swift
//  RxDemo
//
//  Created by James Klitzke on 12/9/16.
//  Copyright © 2016 James Klitzke. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var currentPlayerLabel: UILabel!
    @IBOutlet weak var columnTextField: UITextField!
    @IBOutlet weak var rowTextField: UITextField!
    @IBOutlet weak var fireButton: UIButton!
    
    @IBOutlet weak var battleshipTableView: UITableView!
    
    let cellIdentifier = "battleShipCell"
    lazy var battleShipController = BattleshipViewModel.sharedInstance

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupCellConfiguration()
        
//        battleShipController.isPlayerOnesTurn.value = true
//        battleShipController.attackCoordinate.value = (.A, 0)
//
//        battleShipController.isPlayerOnesTurn.value = false
//        battleShipController.attackCoordinate.value = (.G, 3)
//
//        battleShipController.isPlayerOnesTurn.value = true
//        battleShipController.attackCoordinate.value = (.A, 3)
//
//        battleShipController.isPlayerOnesTurn.value = false
//        battleShipController.attackCoordinate.value = (.H, 3)
//
//        battleShipController.isPlayerOnesTurn.value = true
//        battleShipController.attackCoordinate.value = (.A, 4)
//        
//        battleShipController.isPlayerOnesTurn.value = false
//        battleShipController.attackCoordinate.value = (.I, 3)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupCellConfiguration() {
        

        let player1ShipsObservable = Observable.just(Array(battleShipController.player1Assets.shipFleet.values) + Array(battleShipController.player2Assets.shipFleet.values))

        player1ShipsObservable
            .bindTo(battleshipTableView
                .rx
                .items(cellIdentifier: cellIdentifier)) {
                    [unowned self] (row, ship, cell) in
                        cell.textLabel?.text = "Player 1"
                        cell.detailTextLabel?.text = self.battleShipController.shipDescription(player: .player1, shipType: ship.shipType)
        }.addDisposableTo(disposeBag)

//        let player2ShipsObservable = Observable.just(Array(battleShipController.player2Assets.shipFleet.values))
//        
//        player2ShipsObservable
//            .bindTo(battleshipTableView
//                .rx
//                .items(cellIdentifier: cellIdentifier)) {
//                    [unowned self] (row, ship, cell) in
//                    cell.textLabel?.text = "Player 2"
//                    cell.detailTextLabel?.text = self.battleShipController.shipDescription(player: .player1, shipType: ship.shipType)
//            }.addDisposableTo(disposeBag)
//
        
    }
 

}

