//
//  ComposeViewController.swift
//  TrashTalk
//
//  Created by Kevin McReady on 2/10/15.
//  Copyright (c) 2015 EpiphanyApps. All rights reserved.
//

import UIKit


class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var trashtalkTextView: UITextView!
    @IBOutlet var charRemainingLabel: UILabel!
    
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
    trashtalkTextView.layer.borderColor = UIColor.blackColor().CGColor
    trashtalkTextView.layer.borderWidth = 0.5
    trashtalkTextView.layer.cornerRadius = 5
    trashtalkTextView.delegate = self
        
    trashtalkTextView.becomeFirstResponder()
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendTrashTalk(sender: AnyObject) {
        
        var trashtalk:PFObject = PFObject(className: "TrashTalk")
        trashtalk["content"] = trashtalkTextView.text
        trashtalk["trashtalker"] = PFUser.currentUser()
        
        trashtalk.saveInBackgroundWithTarget(nil, selector: nil)
        
        var push:PFPush = PFPush()
        push.setChannel("Reload")
        
        var data:NSDictionary = ["alert":"", "badge":"0", "content-available":"1", "sound":""]
        
        push.setData(data)
        push.sendPushInBackgroundWithTarget(nil, selector: nil)
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        
    }
    
    func textView(textView: UITextView,
        shouldChangeTextInRange range: NSRange,
        replacementText text: String) ->Bool{
            
            var newLength:Int = (textView.text as NSString).length + (text as NSString).length - range.length
            var remainingChar:Int = 140 - newLength
            
            charRemainingLabel.text = "\(remainingChar)"
            
            return (newLength > 140) ? false : true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
