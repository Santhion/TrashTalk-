//
//  TimelineTableViewController.swift
//  TrashTalk
//
//  Created by Kevin McReady on 2/10/15.
//  Copyright (c) 2015 EpiphanyApps. All rights reserved.
//

import UIKit
import iAd

class TimelineTableViewController: UITableViewController, UINavigationControllerDelegate, ADBannerViewDelegate {
    
    var timelineData = [PFObject]()
    
    var bannerView:ADBannerView?
    
    
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.canDisplayBannerAds = true
        self.bannerView?.delegate = self
        self.bannerView?.hidden = true
        
        self.navigationItem.title = "Trash Talk"

    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadData", name: "reloadTimeline", object: nil)

    }
    
    @IBAction func refreshButton()
    {
        timelineData.removeAll(keepCapacity: false)
        
        var findTimelineData:PFQuery = PFQuery(className: "TrashTalk")
        findTimelineData.findObjectsInBackgroundWithBlock
            {
                (objects:[AnyObject]! , error :NSError!) -> Void in
                if error == nil{
                    self.timelineData = objects.reverse() as [PFObject]
                    
                    //let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                    
                    println(objects)
                    
                    //self.timelineData = array as NSMutableArray
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    @IBAction func loadData(){
        timelineData.removeAll(keepCapacity: false)
        var findTimelineData:PFQuery = PFQuery(className: "TrashTalk")
        findTimelineData.findObjectsInBackgroundWithBlock
            {
                (objects:[AnyObject]!, error:NSError!) -> Void in
                if error == nil{
                    self.timelineData = objects.reverse() as [PFObject]
                    
                    //let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                    
                    //self.timelineData = array as NSMutable
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        var footerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        self.tableView.tableFooterView = footerView
        
    
        var logoutButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        logoutButton.frame = CGRectMake(20, 10, 50, 20)
        logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        logoutButton.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
        
        footerView.addSubview(logoutButton)
        
        if((PFUser.currentUser()) == nil){
            self.showLoginSignUp()
        }
    }
    
    func showLoginSignUp()
    {
        var loginAlert:UIAlertController = UIAlertController(title: "Sign Up / Login", message: "Please Login with your account, new users fill in username/password then click Sign Up.", preferredStyle: UIAlertControllerStyle.Alert)
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your username"
        })
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your password"
            textfield.secureTextEntry = true
        })
        
        loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
            let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextField:UITextField = textFields.objectAtIndex(1) as UITextField
            
            PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text){
                (user:PFUser!, error:NSError!)->Void in
                if((user) != nil){
                    println("Login Successful")
                    var installation:PFInstallation = PFInstallation.currentInstallation()
                    installation.addUniqueObject("Reload", forKey: "channels")
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackgroundWithTarget(nil, selector: nil)
                    
                }else{
                    println("Login Failed")
                }
            }
            
            
            
        }))
    
        loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
            let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextField:UITextField = textFields.objectAtIndex(1) as UITextField
            
            var trashtalker:PFUser = PFUser()
            trashtalker.username = usernameTextField.text
            trashtalker.password = passwordTextField.text
            
            trashtalker.signUpInBackgroundWithBlock{
                (success:Bool!, error:NSError!)->Void in
                
                if (error == nil){
                    println("Sign Up Successful")
                    
                    var installation:PFInstallation = PFInstallation.currentInstallation()
                    installation.addUniqueObject("Reload", forKey: "channels")
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackgroundWithTarget(nil, selector: nil)
                }else{
                    println("Error")
                }
            }
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
        
    }
    
    func logout(sender:UIButton){
        PFUser.logOut()
        self.showLoginSignUp()
    }
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        self.bannerView?.hidden = false
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
    return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return timelineData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TrashTalkTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TrashTalkTableViewCell
        let trashtalk: PFObject = self.timelineData[indexPath.row] as PFObject
        
        cell.trashtalkTextView.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        cell.trashtalkTextView.text = trashtalk.objectForKey("content") as String
        
        var dataFormatter:NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "yyyy-mm-dd HH:mm"
        cell.timestampLabel.text = dataFormatter.stringFromDate(trashtalk.createdAt)
        
        var findTrashTalker: PFQuery = PFUser.query()
        findTrashTalker.whereKey("objectId", equalTo:trashtalk.objectForKey("trashtalker").objectId)
        
        findTrashTalker.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if (error == nil){
                if let actualObjects = objects{
                    let possibleUser = (actualObjects as NSArray).lastObject as? PFUser
                    if let user = possibleUser {
                        cell.usernameLabel.text = user.username
                        
    
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.trashtalkTextView.alpha = 1
                            cell.timestampLabel.alpha = 1
                            cell.usernameLabel.alpha = 1
                        })
                        
                        
                    }
                    
                }
            }
        }
        
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
