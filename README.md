# Square-3D-model-part
## ProjectorView
投影用的view， 初始化：ProjectorView.init(frame:CGRect, filePath:String, cameraInfoString:String, lightInfoString:String?, animation:(Bool, NSTimeInterval)) animation元组包括是否进行旋转动画和动画周期
## EditView
编辑3D模型、调整摄像头、添加灯光
### 使用： 
```swift
    editView = EditView.init(frame: self.view.frame)
    editView.filePath = filePath //一定要设置
    editView.lightInfoString = ... //light,没有则设为nil或不设置
    editView.cameraInfoString = ... //camera，同上
```
###添加灯光
从第一个vc跳转到第二个vc时 把第一个vc的参数都传给第二个vc的EditView，再第二个vc中：
```swift
    var node = editView.addLightNode()
```
对node进行操作即可。保存时将第二个viewcontroller的editView回传（见demo）
###编辑或删除已有的灯光
第一个viewcontroller添加如下属性
```swift
    var lightArray: [LightNodeInfo] {
        get {
            return (editView.lightInfoString?.convertStringToLightNodeInfoArray())!
        }
    }
```
再跳转至编辑界面是除了将editView传过去 还将这个array中相应的lightNodeInfo传过去,再第二个vc中：
```swift
    var node = editView.getNodeBy(nodeInfo)
```
对这个node操作即可进行编辑， 删除则是 node.removeFromParentNode()
    