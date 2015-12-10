//
//  GameViewController.swift
//  tiles
//
//  Created by Walker Smith on 12/7/15.
//  Copyright (c) 2015 Walker Smith. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView = view as! SKView
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill

        level = Level(filename: "Level_3")
        scene.level = level

        skView.presentScene(scene)
        beginGame()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.AllButUpsideDown
    }

    func beginGame(){
        shuffle()
    }

    func shuffle(){
        let newCookies = level.shuffle()
        scene.addSpritesForCookies(newCookies)
    }
}
