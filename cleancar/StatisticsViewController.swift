//
//  StatisticsViewController.swift
//  cleancar
//
//  Created by MacBook Pro on 9/13/16.
//  Copyright © 2016 a. All rights reserved.
//

import UIKit
import SwiftyJSON


enum StatisticFilter: Int {
    case Day
    case Week
    case Month
    case Year
}

struct StatisticItem {
    var filter: StatisticFilter
    var date: NSDate

    var info: Dictionary<String, Int>?


    func key() -> String {
        return getStaticKey(date, forFilter: filter)
    }

    func name() -> String {
        return getStaticKeyDisplay(date, forFilter: filter)
    }

    func genPrev() -> StatisticItem {
        let calendar = getCalendar()
        var prevDate = NSDate()

        switch filter {
        case .Day:
            prevDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: date, options: [])!
        case .Week:
            prevDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: date, options: [])!
        case .Month:
            prevDate = calendar.dateByAddingUnit(.Month, value: -1, toDate: date, options: [])!
        default:
            break
        }

        return StatisticItem(filter: filter, date: prevDate, info: nil)
    }
    
    mutating func fetchInfo(completion: ()->(Void)) {
        getFirebaseRef()
            .child(key())
            .observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value is NSNull {
                    self.info = Dictionary<String, Int>()
                } else {
                    let parsed = JSON(snapshot.value!).dictionaryValue
                    self.info = parsed.reduce([String: Int]()) { (var acc, nextValue) in
                        acc.updateValue(nextValue.1.intValue, forKey: nextValue.0)
                        return acc
                    }
                }
                completion()
            })
    }
}


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
    }
    @IBOutlet weak var clickedButtonNext: UIButton!

    
    // constants
    let segueTableInfoID = "embeddedTableInfo"
    let cellReuseOfCollectionID = "collectionCell"
    let cellReuseOfTableID = "tableCell"


    // variables
    var tableInfo: UITableView?

    var selectedFilter: StatisticFilter = .Day {
        didSet {
            if self.dataStore[selectedFilter]!.isEmpty {
                generateDataFor(selectedFilter)
                self.currentItem = getItem(0)
            }
            self.collectionView.reloadData()
        }
    }
    var currentItem: StatisticItem? {
        didSet {
            if currentItem == nil {
                return
            }

            if currentItem!.info != nil {
                self.tableInfo?.reloadData()
            } else {
                currentItem!.fetchInfo({ self.tableInfo?.reloadData() })
            }
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
        
        self.selectedFilter = .Day
        let d = self.dataStore[selectedFilter]!
        print(".here", self.currentItem, d.count, d.map({ $0.date }) )

        segmentedFilterView.selectedSegmentIndex = self.selectedFilter.rawValue
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.scrollOnceToLastItem()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == self.segueTableInfoID {
            let destController = segue.destinationViewController as! UITableViewController
            self.tableInfo = destController.tableView
            self.tableInfo?.dataSource = self
        }
    }


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

    func generateDataFor(filter: StatisticFilter) {
        Range(1...5).generate() // 5 times
            .forEach({ _ in
                var item: StatisticItem?

                if let last = self.dataStore[filter]?.last {
                    item = last.genPrev()
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
        let rowsCount = self.collectionView.numberOfItemsInSection(0),
            rowDesc = rowsCount - indexPath.row - 1,
            item = self.getItem(rowDesc)

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
        let row = Int(self.collectionView.contentOffset.x / self.collectionView.frame.size.width)
        self.currentItem = self.getItem(row)
    }
}



extension StatisticsViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.currentItem?.info != nil) ? 4 : 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableInfo!.dequeueReusableCellWithIdentifier(cellReuseOfTableID, forIndexPath: indexPath)

        if let info = self.currentItem?.info {
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
        } else {
            cell.textLabel!.text = "Нет данных"
            cell.detailTextLabel!.text = ""
        }

        return cell
    }
}

