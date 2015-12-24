//
//  LightEditViewController.swift
//  OneSquare
//
//  Created by 李超 on 15/12/23.
//  Copyright © 2015年 李超. All rights reserved.
//

import UIKit
import SceneKit

@objc protocol LightEditViewControllerDelegate {
    func didSave(cameraInfoString: String, lightInfoString: String)
}

class LightEditViewController: UIViewController {
    var nodeInfo: LightNodeInfo? {
        didSet {
            if nodeInfo != nil {
                node = editView?.getNodeBy(nodeInfo!)
            }
        }
    }
    var node: SCNNode? {
        didSet {
            node?.position = SCNVector3Make(0, 0, 0)
        }
    }
    var delegate: LightEditViewControllerDelegate?
    var editView: EditView?
    var editingNode: SCNNode?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        if editView != nil {
            self.view.addSubview(editView!)
        }
        //editingNode = self.editView?.addLightNode()
        
        let button = UIButton.init(frame: CGRectMake(100, 400, 100, 100))
        button.backgroundColor = UIColor.blackColor()
        button.addTarget(self, action: Selector("didSaveAndPop"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func didSaveAndPop() {
        
        self.delegate?.didSave((self.editView?.cameraInfoString)!, lightInfoString: (self.editView?.lightInfoString)!)
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
