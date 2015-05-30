//
//  ViewController.swift
//  MapTableView
//
//  Created by Kj Drougge on 2015-05-30.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var draggableLabel: UILabel!

    private var minHeight: CGFloat!
    private var maxHeight: CGFloat!
    
    private var dragableViewOriginalY: CGFloat!
    private var theMapOriginalY: CGFloat!
    private var theTableOriginalY: CGFloat!
    
    private var currentState: State = .Open
    private enum State: Int{
        case Open = 0
        case Closed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.mapView.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initialSetup(){
        self.setMinHeight(200, andMaxHeight: nil)
        self.dragableViewOriginalY = self.draggableView.frame.origin.y
        self.theMapOriginalY = self.mapView.frame.origin.y
        self.theTableOriginalY = self.tableView.frame.origin.y
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "didTapView")
        tapGesture.numberOfTapsRequired = 1
        self.draggableView.addGestureRecognizer(tapGesture)
    }
    
    private func setShadowEffect(){
        // Shadow effect
        self.draggableView.layer.shadowColor = UIColor.blackColor().CGColor
        self.draggableView.layer.shadowRadius = 10
        self.draggableView.layer.shadowOpacity = 0.7
    }
    
    private func setMinHeight(minHeight: CGFloat, andMaxHeight: CGFloat?){
        if let maxHeight = andMaxHeight{
            self.maxHeight = maxHeight
        } else {
            self.maxHeight = self.view.frame.height - self.draggableView.frame.height
        }
        self.minHeight = minHeight
    }

    func didTapView(){
        if currentState == .Closed {
            currentState = .Open
            toggleTable()
        }
    }
}

extension ViewController {
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch where touch.view == self.draggableView && self.currentState == .Open{
            // Do nothing
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch where touch.view == self.draggableView && self.currentState == .Open{
            let location = touch.locationInView(self.view)
            if self.draggableView.frame.origin.y >= self.minHeight && self.draggableView.frame.origin.y <= self.maxHeight{
                self.draggableView.frame.origin.y = location.y
                self.tableView.frame.origin.y = location.y + self.draggableView.frame.height
                self.topViewHeightConstraint.constant = self.draggableView.frame.origin.y
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch where touch.view == self.draggableView && self.currentState == .Open{
            self.currentState = self.draggableView.frame.origin.y > 350 ? .Closed : .Open
            self.toggleTable()
        }
    }

    func toggleTable(){
        UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: nil, animations: {
            self.draggableView.frame.origin.y = self.currentState == .Open ? self.dragableViewOriginalY : self.maxHeight
            self.tableView.frame.origin.y = self.currentState == .Open ? self.theTableOriginalY : self.draggableView.frame.origin.y + self.draggableView.frame.height
            self.topViewHeightConstraint.constant = self.draggableView.frame.origin.y
            self.view.layoutIfNeeded()
            
            self.mapView.userInteractionEnabled = self.currentState == .Open ? false : true
            }, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Table View Datasource and Delegate
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }
}