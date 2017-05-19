//
//  BattleshipController.swift
//  RxDemo
//
//  Created by James Klitzke on 12/12/16.
//  Copyright © 2016 James Klitzke. All rights reserved.
//

import Foundation
import RxSwift

/* RX Cheats
 private func setupCartObserver() {
 //1
 ShoppingCart.sharedCart.chocolates.asObservable()
 .subscribe(onNext: { //2
 chocolates in
 self.cartButton.title = "\(chocolates.count) \u{1f36b}"
 })
 
 
 */

class BattleshipViewModel {
    
    let player1Assets = PlayerAssets()
    let player2Assets  = PlayerAssets()
    
    var didPlayer1Win : Variable<Bool> = Variable(false)
    
    let attackCoordinate : Variable<(Column, Int)>
    
    let isPlayerOnesTurn : Variable<Bool>
    var currentPlayerAssets : PlayerAssets
    
    let player1ShipsObservable : Observable<[Ship]>
    let player2ShipsObservable : Observable<[Ship]>

    
    let disposeBag = DisposeBag()
    
    static let sharedInstance = BattleshipViewModel()

    init() {
        
        let initCoord = (Column.A, 0)
        currentPlayerAssets = player1Assets
        
        attackCoordinate = Variable(initCoord)
        isPlayerOnesTurn = Variable(true)
        
        player1ShipsObservable = Observable.just(Array(player1Assets.shipFleet.values))
        player2ShipsObservable = Observable.just(Array(player2Assets.shipFleet.values))

        
        
        isPlayerOnesTurn
            .asObservable()
            .subscribe(onNext: {
                [unowned self] isPlayerOnesTurn in
                self.currentPlayerAssets = (isPlayerOnesTurn) ? self.player1Assets : self.player2Assets
            }).addDisposableTo(disposeBag)
        
        attackCoordinate
            .asObservable()
            .subscribe(onNext: {
                [unowned self] myattkCoord in
                print(myattkCoord)
                //update board state with result
                let result = self.checkForHit(myattkCoord)
                self.currentPlayerAssets.playerBoard[myattkCoord.0.rawValue][myattkCoord.1] = result ? .hit : .miss
                
            })
            .addDisposableTo(disposeBag)

        
        let shipsObservable = [player1Assets.shipFleet[.battleship]!.isSunk.asObservable(),
                               player1Assets.shipFleet[.submarine]!.isSunk.asObservable()]
        
        let didPlayer1Lose = Observable
            .combineLatest(shipsObservable) {
                $0[0] && $0[1]
        }
        
        didPlayer1Lose
            .asObservable()
            .subscribe(onNext: {
                updatedValue in
                if updatedValue {
                    print("Player 1 lost!")
                }
        }).addDisposableTo(disposeBag)
    }
    
    func shipDescription(player : Player, shipType : ShipType) -> String {
        
        let playerAssets = (player == .player1) ? player1Assets : player2Assets
        
        guard let shipModel = playerAssets.shipFleet[shipType] else { return "NOTHING" }
        
        return "Ship: \(shipModel.shipType) current HP: \(shipModel.hitPoints.value)"
    }
    
    func checkForHit(_ coordinates: (Column, Int)) -> Bool {
        
        let unsunkenShips = currentPlayerAssets.shipFleet.filter({ return !$0.value.isSunk.value})
        
        for (shipType, ship) in unsunkenShips {

            //Only register hits on A column for Demo purposes
            guard coordinates.0 == .A else { return false }
            
            switch shipType {
            case .submarine, .battleship:
                    ship.hitPoints.value -= 1
                    return true
            default:
                return false

            }
            
//            if coordinates.0 == ship.startPosition?.0 &&
//                coordinates.1 >= ship.startPosition!.1 &&
//                coordinates.1 <= ship.endPosition!.1 {
//                ship.hitPoints.value -= 1
//                
//                return true
//            }
//            else if coordinates.1 == ship.startPosition?.1 &&
//                coordinates.0.rawValue >= ship.startPosition!.0.rawValue &&
//                coordinates.0.rawValue <= ship.endPosition!.0.rawValue {
//                ship.hitPoints.value -= 1
//                return true
//            }
        }
        
        
        return false
    }

    
    enum Player {
        case player1
        case player2
    }
}

class PlayerAssets {

    let playerRow = [CellState](repeating:.empty, count: 10)
    var playerBoard : [[CellState]]
    
    let shipFleet : [ShipType : Ship] = [.battleship : Ship(.battleship), .submarine : Ship(.submarine), .carrier : Ship(.carrier),
                     .cruiser : Ship(.cruiser), .frigate : Ship(.frigate)]
    
    init() {
        playerBoard = [[CellState]](repeating: playerRow, count: 10)
        
        shipFleet[.battleship]?.startPosition = (.A, 0)
        shipFleet[.battleship]?.endPosition = (.A, 5)
        
//        shipFleet[1].startPosition = (Column.D, 0)
//        shipFleet[1].endPosition = (Column.I, 0)
//
//        shipFleet[2].startPosition = (Column.A, 5)
//        shipFleet[2].endPosition = (Column.A, 9)
//
//        shipFleet[3].startPosition = (Column.B, 6)
//        shipFleet[3].endPosition = (Column.B, 9)
//
//        shipFleet[4].startPosition = (Column.G, 3)
//        shipFleet[4].endPosition = (Column.I, 3)
    }
    
}

struct Coordinate {
    let column : Column
    let row : Int
}

enum Column : Int {
    case A = 0
    case B = 1
    case C = 2
    case D = 3
    case E = 4
    case F = 5
    case G = 6
    case H = 7
    case I = 8
    case J = 9
}

enum CellState {
    case empty
    case miss
    case hit
}

enum ShipType {
    case battleship
    case submarine
    case carrier
    case cruiser
    case frigate
}

class Ship {
    
    let shipType : ShipType
    var isSunk : Variable<Bool> = Variable(false)

    let hitPoints : Variable<Int>
    let maxHitPoints : Int
    
    let disposeBag = DisposeBag()
    
    var startPosition : (Column, Int) = (.A, 0)
    var endPosition : (Column, Int) = (.A, 0)
    
    init(_ type: ShipType) {
        shipType = type
        
        switch shipType {
        case .battleship:
            hitPoints = Variable(2)
            maxHitPoints = 2
        case .carrier:
            hitPoints = Variable(2)
            maxHitPoints = 2

        case .cruiser:
            hitPoints = Variable(2)
            maxHitPoints = 2

        case .submarine:
            hitPoints = Variable(1)
            maxHitPoints = 1

        case .frigate:
            hitPoints = Variable(1)
            maxHitPoints = 1

        }
        
        hitPoints
            .asObservable()
            .subscribe(onNext: {
                [unowned self] hitPoints in
                guard hitPoints != self.maxHitPoints else { return }
                print("\(self.shipType) was hit!  New HP= \(hitPoints)")
                self.isSunk.value = hitPoints == 0
                
            })
            .addDisposableTo(disposeBag)

        
    }
    
    
}
