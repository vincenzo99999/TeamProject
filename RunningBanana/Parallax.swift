//
//  Parallax.swift
//  RunningBanana
//
//  Created by Arturo Cecora on 08/12/23.
//

import Foundation
import SpriteKit

class Parallax{
    
    var scene: SKScene
    var parallaxLayerSprites: [SKSpriteNode?]
    var speed: CGFloat
    var speedFactor: CGFloat
    
    init(scene: SKScene, parallaxLayerSprites: [SKSpriteNode?], getSpritesFromFile: Bool, speed: CGFloat, speedFactor: CGFloat) {
        self.scene = scene
        self.parallaxLayerSprites = parallaxLayerSprites
        self.speed = speed
        self.speedFactor = speedFactor
        for (index,layer) in parallaxLayerSprites.enumerated(){
            createBackground(parent: layer!,zPosition: CGFloat(index), getSpritesFromFile: getSpritesFromFile)
        }
    }
    

    fileprivate func createBackground(parent: SKSpriteNode, zPosition: CGFloat, getSpritesFromFile: Bool){
        for i in 0...3 {
            if !getSpritesFromFile {
                if i==2 {continue}
            }
            let layer = SKSpriteNode(texture: parent.texture)
            layer.name = parent.name! + "children_" + String(i)
            layer.size = CGSize(width: scene.size.width, height: scene.size.height)
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.position = CGPoint(x: CGFloat(i) * layer.size.width - 1.0, y: 0.0)
            layer.zPosition = zPosition
            
            parent.addChild(layer)
        }
    }


    /*To get scrolling background*/
    func update(layers: [SKSpriteNode?]){
        //get the layers in the array but with opposite indexes
        for (index, layer) in layers.enumerated() {
            parallaxLayer(layer: layer, speed: speed + (CGFloat(index) * speedFactor))
        }
        
    }


    fileprivate func parallaxLayer(layer: SKSpriteNode?, speed: CGFloat){
        layer?.position.x -= speed
        
        if (layer?.position.x)! < -scene.size.width {
            layer?.position.x += scene.size.width
        }
    }
}


