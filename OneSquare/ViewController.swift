//
//  ViewController.swift
//  OneSquare
//
//  Created by 李超 on 15/12/10.
//  Copyright © 2015年 李超. All rights reserved.
//

import UIKit
import SnapKit
import SceneKit

class ViewController: UIViewController, LightEditViewControllerDelegate {

    var editView: EditView!
    var lightArray: [LightNodeInfo] {
        get {
            return (editView.lightInfoString?.convertStringToLightNodeInfoArray())!
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      //  editView = ProjectorView.init(frame: self.view.frame, filePath: "art.scnassets/chair_005.obj", cameraInfoString: "{\"position\": [-25.5695, -10.2187, -20.0461], \"euler\": [2.12371, -0.430795, -1.01731], \"lookAtPoint\": [0.0, 16.4107, 9.53674e-07]}", lightInfoString: nil, animation: (true, 5))
        editView = EditView.init(frame: self.view.frame)
        editView.filePath = "art.scnassets/chair_005.obj"
        editView.lightInfoString = "[{\"position\": [1.0, 1.0, 1.0], \"euler\": [1.0, 1.0, 1.0], \"lookAtPoint\": [1.0, 1.0, 1.0], \"type\":\"0\"}, {\"position\": [1.0, 30.0, 1.0], \"euler\": [1.0, 1.0, 1.0], \"lookAtPoint\": [1.0, 1.0, 1.0], \"type\":\"0\"}]"
        editView.cameraInfoString = "{\"position\": [-25.5695, -10.2187, -20.0461], \"euler\": [2.12371, -0.430795, -1.01731], \"lookAtPoint\": [0.0, 16.4107, 9.53674e-07]}"
        view.addSubview(editView!)
        let button = UIButton.init(frame: CGRectMake(100, 500, 100, 100))
        button.backgroundColor = UIColor.blackColor()
        button.addTarget(self, action: Selector.init("log"), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
    
    func didSave(cameraInfoString: String, lightInfoString: String) {
        self.editView.cameraInfoString = cameraInfoString
        self.editView.lightInfoString = lightInfoString
    }
    
    func log() {
        let vc = LightEditViewController.init()
        vc.editView = EditView.init(frame: self.view.frame)
        vc.editView?.filePath = self.editView.filePath
        vc.editView?.lightInfoString = self.editView.lightInfoString
        vc.editView?.cameraInfoString = self.editView.cameraInfoString
        vc.delegate = self
        vc.nodeInfo = self.lightArray[1]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

