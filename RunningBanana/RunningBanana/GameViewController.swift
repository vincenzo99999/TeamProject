//
//  GameViewController.swift
//  RunningBanana
//
//  Created by Vincenzo Eboli on 05/12/23.
//


import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.view as! SKView? {
            // Set the view's bounds to the device's screen bounds
            view.bounds = UIScreen.main.bounds

            // Create and configure the scene
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill

            // Present the scene
            view.presentScene(scene)
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
