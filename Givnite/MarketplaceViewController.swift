//
//  MarketplaceViewController.swift
//  Givnite
//
//  Created by Danny Tan on 7/16/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MarketplaceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate  {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarText: UISearchBar!
    

  

    let storageRef = FIRStorage.storage().referenceForURL("gs://givniteapp.appspot.com")
    let dataRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
    let user = FIRAuth.auth()?.currentUser
    var imageNameArray = [String]()
    var imageArray = [UIImage]()
    
    var bookNameArray = [String]()
    var bookPriceArray = [String]()
    var userArray = [String]()
    var descriptionArray = [String]()
    
    var firstTimeUse: Bool = true
    
    var searchedBook: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(firstTimeUse)
        print(imageArray)
        if self.firstTimeUse == true {
            self.imageNameArray.removeAll()
            self.imageArray.removeAll()
            
        }
        self.userArray.removeAll()
        self.bookNameArray.removeAll()
        self.bookPriceArray.removeAll()
        self.descriptionArray.removeAll()
        
        loadImages()
        
        let swipeLeftGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "unwindToProfile")
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeftGestureRecognizer)
        
        searchBarText.delegate = self
        
        if searchedBook != "" {
            searchBarText.text = searchedBook
        }
    }
    
    func unwindToProfile(){
        print(123123)
        self.performSegueWithIdentifier("backToProfile", sender: self)

    }
    
    
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count == 0) {
            searchBar.performSelector("resignFirstResponder", withObject: nil, afterDelay: 0.1)
            self.firstTimeUse = true
            searchedBook = ""
            viewDidLoad()
        }
    
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      
        dataRef.child("user").child(user!.uid).child("query").setValue(searchBarText.text)
        searchBarText.resignFirstResponder()
        searchedBook = self.searchBarText.text!
        dataRef.child("user").child(user!.uid).child("queryres").observeEventType(.ChildChanged, withBlock: {(snapshot) -> Void in
            self.updateTheCell()
        })
    }

    
    func updateTheCell(){
        dataRef.child("user").child(user!.uid).child("queryres").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
        
            if let topSearches = snapshot.value! as? NSArray {

                self.imageNameArray.removeAll()
             
                for imageName in topSearches {
                    if let name = imageName as? String {
                        self.imageNameArray.append(name)
                        
                    }
                }
            }

            self.firstTimeUse = false
            self.viewDidLoad()
        })
    }
    
    
    

    
    
    
    //layout for cell size
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 2 ) / 2, height: (collectionView.frame.size.width + 100) / 2  )
    }


    
    func loadImages() {
        dataRef.child("marketplace").observeSingleEventOfType(.Value, withBlock: { (snapshot)
            in
            
            
         
            
            //adds image name from firebase database to an array
            
            if let itemDictionary = snapshot.value! as? NSDictionary {
                
                if self.firstTimeUse == true {
                   
                    var timeArray = [Int]()
                    
                    
                    for key in itemDictionary.allKeys {
                        if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                            if let time = keyDictionary["time"] {
                                let time2 = time as! Int
                                timeArray.append(time2)
                            }
                        }
                    }
                    timeArray = timeArray.sort().reverse()
                    
                    
                    for time in timeArray {
                        for key in itemDictionary.allKeys {
                            if let keyDictionary = itemDictionary["\(key)"] as? NSDictionary {
                                if let time2 = keyDictionary["time"]{
                                    if time == time2 as! Int {
                                        self.imageNameArray.append("\(key)")
                                        if let searchable = keyDictionary["searchable"] as? NSDictionary {
                                            if let bookName = searchable["book name"] as? String {
                                                self.bookNameArray.append(bookName)
                                            }
                                            else {
                                                self.bookNameArray.append("")
                                            }
                                            if let bookDescription  = searchable["description"] as? String {
                                                self.descriptionArray.append(bookDescription)
                                            }
                                            else {
                                                self.descriptionArray.append("")
                                            }
                                        }
                                        else {
                                            self.bookNameArray.append("")
                                            self.descriptionArray.append("")
                                        }
                                        if let bookPrice = keyDictionary["price"] as? String {
                                            self.bookPriceArray.append(bookPrice)
                                        }
                                        else {
                                            self.bookPriceArray.append("")
                                        }
                                        if let userID = keyDictionary["user"] as? String {
                                            self.userArray.append(userID)
                                        }
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                    }

                }
                else {
                    for image in self.imageNameArray {
                   
                        if let keyDictionary = itemDictionary[image] as? NSDictionary {
                            if let searchable = keyDictionary["searchable"] as? NSDictionary {
                                if let bookName = searchable["book name"] as? String {
                                    self.bookNameArray.append(bookName)
                                }
                                else {
                                    self.bookNameArray.append("")
                                }
                                if let bookDescription  = searchable["description"] as? String {
                                    self.descriptionArray.append(bookDescription)
                                }
                                else {
                                    self.descriptionArray.append("")
                                }
                            }
                            else {
                                self.bookNameArray.append("")
                                self.descriptionArray.append("")
                            }

                            if let bookPrice = keyDictionary["price"] as? String {
                                self.bookPriceArray.append(bookPrice)
                            }
                            else {
                                self.bookPriceArray.append("")
                            }
                            if let userID = keyDictionary["user"] as? String {
                                self.userArray.append(userID)
                            }
                            
                        }
                    }
                }
            }
           
            
            for index in 0..<self.imageNameArray.count {
                self.imageArray.append(UIImage(named: "Examples")!)
            }
            dispatch_async(dispatch_get_main_queue(),{
                self.collectionView.reloadData()
            })
        })
        
    }

    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNameArray.count
    }
    
    
    

    
    var priceCache = [String:String]()
    
    var bookCache = [String:String]()
    
    

    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as!
        MarketCollectionViewCell
        
        
        if let imageName = self.imageNameArray[indexPath.row] as? String {
            cell.itemImageView.image = nil
            
           
            if let image = NSCache.sharedInstance.objectForKey(imageName) as? UIImage {
                cell.itemImageView.image = image
                print(imageArray)
                self.imageArray[indexPath.row] = image
            }
                
            else {
                
                var imagesRef = storageRef.child(imageName).child("\(imageName).jpg")
                //sets the image on profile
                imagesRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                    if (error != nil) {
                        print ("File does not exist")
                        return
                    } else {
                        if (data != nil){
                            let imageToCache = UIImage(data:data!)
                            NSCache.sharedInstance.setObject(imageToCache!, forKey: imageName)
                            dispatch_async(dispatch_get_main_queue(),{
                                cell.itemImageView.image = imageToCache
                                self.imageArray[indexPath.row] = imageToCache!
                                
                            })
                        }
                    }
                    }.resume()
                
            }
            
            
            if userArray.count > indexPath.row {
                
                let userID = userArray[indexPath.row]
                cell.profileImageButton.layer.cornerRadius =  cell.profileImageButton.bounds.size.width/2
                cell.profileImageButton.clipsToBounds = true
                
                
                if let userImage = NSCache.sharedInstance.objectForKey(userID) as? UIImage {
                    
                    cell.profileImageButton.setImage(userImage, forState: .Normal)
                }
                    
                else {
                    
                    
                    var profilePicRef = storageRef.child(userID).child("profile_pic.jpg")
                    
                    
                    //sets the image on profile
                    profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                        if (error != nil) {
                            print ("File does not exist")
                            
                            return
                        } else {
                            if (data != nil){
                                let imageToCache = UIImage(data:data!)
                                NSCache.sharedInstance.setObject(imageToCache!, forKey: userID)
                                dispatch_async(dispatch_get_main_queue(),{
                                    cell.profileImageButton.setImage(imageToCache!, forState: .Normal)
                                })
                                
                            }
                        }
                        }.resume()
                }
            }
            if let bookName = bookCache[imageName] {
                cell.bookName.text = bookName
            
            }
            
            
            else {
                if bookNameArray.count > indexPath.row {
                    let bookNameToCache = bookNameArray[indexPath.row]
                    self.bookCache[imageName] = bookNameToCache
                    cell.bookName.text = bookNameToCache
                }
            }
            
            if let bookPrice = priceCache[imageName] {
                cell.bookPrice.text = bookPrice
            }
            
            else {
                if bookPriceArray.count > indexPath.row {
                    let bookPriceToCache = bookPriceArray[indexPath.row]
                    self.priceCache[imageName] = bookPriceToCache
                    cell.bookPrice.text = bookPriceToCache
                }
            }
 
        }
        
        
        cell.profileImageButton.addTarget(self, action: #selector(self.buttonClicked), forControlEvents: .TouchUpInside)
        return cell
    }
    
    
    
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("marketEnlarge", sender: self)
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        let point = collectionView.convertPoint(CGPointZero, fromView: sender)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            self.userID = self.userArray[indexPath.row]
            if let string = self.userArray[indexPath.row] as? String {
               
                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.performSegueWithIdentifier("showProfile", sender: self)
                })

            }
        }
    }
    
    var userID: String?
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        
        if segue.identifier == "marketEnlarge" {
        
            let destinationVC = segue.destinationViewController as! MarketItemViewController
            
            let indexPaths = self.collectionView!.indexPathsForSelectedItems()!
            let indexPath = indexPaths[0] as NSIndexPath
            
            
            destinationVC.imageName = self.imageNameArray[indexPath.row]
            
            destinationVC.name = self.bookNameArray[indexPath.row]
            
            destinationVC.price = self.bookPriceArray[indexPath.row]
            
            destinationVC.userID = self.userArray[indexPath.row]
            
            destinationVC.bkdescription = self.descriptionArray[indexPath.row]
            
            destinationVC.firstTimeUsed = self.firstTimeUse
            
            destinationVC.imageNameArray = self.imageNameArray
            
            destinationVC.imageArray = self.imageArray
            
            destinationVC.searchedBook = self.searchBarText.text!
            
        }
        
        if segue.identifier == "showProfile" {
            let destinationVC = segue.destinationViewController as! ProfileViewController
            
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.type = kCATransitionFade
            transition.subtype = kCATransitionFromLeft
            view.window!.layer.addAnimation(transition, forKey: kCATransition)

            
            
            destinationVC.userID = self.userID
        
            destinationVC.otherUser = true
        }
    
    }
    
        
}
