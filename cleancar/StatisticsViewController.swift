//
//  StatisticsViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/13/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import SwiftyJSON




class StatisticsViewController: UIViewController {

    // outlets
    @IBOutlet weak var segmentedFilterView: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonPrev: UIButton!
    @IBOutlet weak var buttonNext: UIButton!


    // actions
    @IBAction func changesSegmentedFilterView(sender: UISegmentedControl) {
        self.selectedFilter = StatisticFilter(rawValue: sender.selectedSegmentIndex)!
    }
    @IBAction func clickedButtonPrev(sender: UIButton) {
        let row = self.getCurrentRowIndex()
        self.currentItem = self.getItem(row - 1, reversed: true)
        
        let itemSize = self.collectionView.frame.size.width
        var co = self.collectionView.contentOffset
        co.x -= itemSize
        
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.setContentOffset(co, animated: true)
        })
    }
    @IBAction func clickedButtonNext(sender: UIButton) {
        let row = self.getCurrentRowIndex()
        self.currentItem = self.getItem(row + 1, reversed: true)
        
        let itemSize = self.collectionView.frame.size.width
        var co = self.collectionView.contentOffset
        co.x += itemSize

        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.setContentOffset(co, animated: true)
        })
    }


    // constants
    let segueTableInfoID = "embeddedTableInfo"
    let cellReuseOfCollectionID = "collectionCell"
    let cellReuseOfTableID = "tableCell"


    // variables
    var tableInfo: UITableView?
    lazy var spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        s.frame = CGRectMake(0, 0, 24, 24);
        s.hidesWhenStopped = true
        return s
    }()

    var selectedFilter: StatisticFilter = .Day {
        didSet {
            self.updateCollectionViewForFilter(selectedFilter)
        }
    }
    var currentItem: StatisticItem? {
        didSet {
            self.updateTableViewForItem(currentItem!)
        }
    }
    var wasRenderedCollectionView: Bool = false

    var dataStore = [
        StatisticFilter.Day: Array<StatisticItem>(),
        StatisticFilter.Week: Array<StatisticItem>(),
        StatisticFilter.Month: Array<StatisticItem>()
    ]


    override func viewDidLoad() {
        super.viewDidLoad()

        // init
        self.selectedFilter = .Day

        segmentedFilterView.selectedSegmentIndex = self.selectedFilter.rawValue
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // runs once
        self.scrollOnceToLastItem()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueTableInfoID {
            let destController = segue.destinationViewController as! UITableViewController
            self.tableInfo = destController.tableView
            self.tableInfo?.dataSource = self
        }
    }


    func updateCollectionViewForFilter(filter: StatisticFilter) {
        if self.dataStore[selectedFilter]!.isEmpty {
            self.generateDataFor(selectedFilter)
        }
        self.currentItem = getItem(0)
        self.collectionView.reloadData()

        // runs only after viewWillAppear runs it
        if self.wasRenderedCollectionView {
            self.wasRenderedCollectionView = false
            self.scrollOnceToLastItem()
        }
    }

    func updateTableViewForItem(item: StatisticItem) {
        if item.info == nil {
            item.fetchInfo({ self.tableInfo!.reloadData() })
        }
        self.tableInfo!.reloadData()
    }


    func generateDataFor(filter: StatisticFilter) {
        Range(1...5).generate() // 5 times
            .forEach({ _ in
                var item: StatisticItem?

                if let last = self.dataStore[filter]?.last {
                    item = last.genPrev()
                    if item == nil { // it was last item
                        return
                    }
                } else {
                    let now = NSDate()
                    item = StatisticItem(filter: filter, date: now, info: nil)
                }

                self.dataStore[filter]!.append(item!)
            })
    }

    func getItem(index: Int) -> StatisticItem  {
        return self.dataStore[self.selectedFilter]![index]
    }

    func getItem(index: Int, reversed: Bool) -> StatisticItem {
        if reversed == false {
            return getItem(index)
        }

        let count = self.dataStore[self.selectedFilter]!.count,
            indexDesc = count - index - 1
        return self.dataStore[self.selectedFilter]![indexDesc]
    }
}


extension StatisticsViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataStore[self.selectedFilter]!.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseOfCollectionID, forIndexPath: indexPath) as! StatisticItemCell
        let item = self.getItem(indexPath.row, reversed: true)

        cell.labelDescription.text = item.name()
        return cell
    }
}

extension StatisticsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

extension StatisticsViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let row = self.getCurrentRowIndex()
        self.currentItem = self.getItem(row, reversed: true)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        // add prev items
        if self.isOnFirstScrollItem() {
            self.generateDataFor(self.selectedFilter)
        }

        // hide buttons
        let animate = {
            self.buttonNext.layer.opacity = self.isOnLastScrollItem() ? 0.5 : 1
            self.buttonNext.enabled = !self.isOnLastScrollItem()
            self.buttonPrev.layer.opacity = self.isOnFirstScrollItem() ? 0.5 : 1
            self.buttonPrev.enabled = !self.isOnFirstScrollItem()
        }
        UIView.animateWithDuration(0.3, delay: 0.3, options: .CurveEaseOut, animations: animate, completion: nil)
    }

    // custom function for scroll
    func scrollOnceToLastItem() {
        if self.wasRenderedCollectionView {
            return
        }
        self.wasRenderedCollectionView = true
        
        let rowsCount = self.collectionView.numberOfItemsInSection(0),
        contentSize = Int(self.collectionView.frame.size.width)
        var co = self.collectionView.contentOffset
        co.x = CGFloat( contentSize * (rowsCount - 1) )
        
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.setContentOffset(co, animated: false)
        })
    }

    func isOnFirstScrollItem() -> Bool {
        return self.collectionView.contentOffset.x < self.collectionView.frame.size.width
    }

    func isOnLastScrollItem() -> Bool {
        let rightBorder = self.collectionView.contentOffset.x + self.collectionView.frame.size.width
        return rightBorder >= self.collectionView.contentSize.width
    }

    func getCurrentRowIndex() -> Int {
        return Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
    }
}



extension StatisticsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let info = self.currentItem?.info {
            self.spinner.stopAnimating()
            return info.isEmpty ? 1 : 4
        }
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableInfo!.dequeueReusableCellWithIdentifier(cellReuseOfTableID, forIndexPath: indexPath)

        if let info = self.currentItem?.info { // fetchInfo was finished
            // 1. no data
            if info.isEmpty {
                cell.textLabel!.text = "Нет данных"
                cell.detailTextLabel!.text = ""
                return cell
            }

            // 2. some data
            switch indexPath.row {
            case 0:
                cell.textLabel!.text = "Количество моек"
                cell.detailTextLabel!.text = String(info["count"]!)
            case 1:
                cell.textLabel!.text = "Общая сумма"
                cell.detailTextLabel!.text = formatMoney( info["sum"]! )
            case 2:
                cell.textLabel!.text = "Средний чек"
                cell.detailTextLabel!.text =  formatMoney( Int(info["sum"]! / info["count"]!) )
            case 3:
                cell.textLabel!.text = "Средний рейтинг"
                cell.detailTextLabel!.text =  String( Int(info["rate_sum"]! / info["rate_count"]!) )
            default:
                break
            }
        } else { // fetchInfo in progress
            cell.textLabel!.text = ""
            cell.detailTextLabel!.text = ""

            cell.accessoryView = self.spinner
            self.spinner.startAnimating()
        }

        return cell
    }

}


