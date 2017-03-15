//
//  SwiftGameViewController.swift
//  OSX-Example
//
//  Created by C.W. Betts on 3/15/17.
//  Copyright © 2017 Ison Apps. All rights reserved.
//

import Cocoa
import AssimpKit
import SceneKit
import Quartz

class SwiftGameViewController: NSViewController, CAAnimationDelegate {
	@IBOutlet weak var gameView: SwiftGameView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		gameView.allowsCameraControl = true
		
		// show statistics such as fps and timing information
		gameView.showsStatistics = true
		
		// configure the view
		gameView.backgroundColor = NSColor.white
		
		gameView.isPlaying = true
	}
	
	@IBAction func viewModel(_ sender:AnyObject?) {
		let panel = NSOpenPanel()
		panel.allowedFileTypes = SCNAssimpScene.allowedFileExtensions
		panel.canChooseFiles = true
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = false
		let clicked = panel.runModal()
		
		if clicked == NSFileHandlingPanelOKButton {
			let scene = SCNScene.assimpScene(with: panel.url!, postProcessFlags: [.process_FlipUVs, .process_Triangulate])
			gameView.scene = scene?.modelScene
		}
	}
	
	@IBAction func addAnimation(_ sender: AnyObject?) {
		let panel = NSOpenPanel()
		panel.allowedFileTypes = SCNAssimpScene.allowedFileExtensions
		panel.canChooseFiles = true
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = false
		let clicked = panel.runModal()

		if clicked == NSFileHandlingPanelOKButton {
			let animScene = SCNScene.assimpScene(with: panel.url!, postProcessFlags: [.process_FlipUVs, .process_Triangulate])
			var scene = gameView.scene
			if scene == nil {
				scene = animScene?.modelScene
				gameView.scene = scene
			}
			let animationKeys = animScene!.animationKeys
			// If multiple animations exist, load the first animation
			if animationKeys.count > 0 {
				let settings = SCNAssimpAnimSettings()
				settings.repeatCount = 3
				
				let key = animationKeys[0]
				let eventBlock: SCNAnimationEventBlock = {animation, animatedObject, playingBackward in
					NSLog(" Animation Event triggered ");
					
					// To test removing animation uncomment
					// Then the animation wont repeat 3 times
					// as it will be removed after 90% of the first loop
					// is completed, as event key time is 0.9
					// [scene.rootNode removeAnimationSceneForKey:key];
					scene!.rootNode.pauseAnimationScene(forKey: key)
					NSLog(" Animation paused: \(scene!.rootNode.isAnimationScene(forKeyPaused: key))"
					       );
					// [scene.rootNode resumeAnimationSceneForKey:key];
				}
				let animEvent = SCNAnimationEvent(keyTime: 0.9, block: eventBlock)
				let animEvents = [animEvent]
				settings.animationEvents = animEvents
				
				settings.delegate = self
				
				let animation = animScene?.animationScene(forKey: key)
				scene?.rootNode.addAnimationScene(animation!, forKey: key, with: settings)
			}
		}
	}
	
	func animationDidStart(_ anim: CAAnimation) {
		NSLog(" animation did start...")
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		NSLog(" animation did stop...")
	}
}
