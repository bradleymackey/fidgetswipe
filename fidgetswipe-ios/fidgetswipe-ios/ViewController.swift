//
//  ViewController.swift
//  fidgetswipe-ios
//
//  Created by Bradley Mackey on 07/07/2017.
//  Copyright © 2017 Bradley Mackey. All rights reserved.
//

import UIKit
import GameKit

class ViewController: UIViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LeaderboardManager.shared.set(presentingViewController: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupGestureRecognisers() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.gestureTapped(tapGestureRecogniser:)))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.gestureSwiped(swipeGestureRecognser:)))
        self.view.addGestureRecognizer(swipe)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func gestureTapped(tapGestureRecogniser: UITapGestureRecognizer) {
        
    }
    
    @objc
    func gestureSwiped(swipeGestureRecognser: UISwipeGestureRecognizer) {
        typealias D = UISwipeGestureRecognizerDirection
        switch swipeGestureRecognser.direction {
        case D.right: break
        case D.left: break
        case D.up: break
        case D.down: break
        default:
            fatalError("Invalid swipe direction")
        }
    }

}

