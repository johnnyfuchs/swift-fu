//
//  ViewController.swift
//  fu
//
//  Created by Johnny Sparks on 2/13/15.
//
//

import UIKit
import Foundation


// Universe Generator

public func == (rhs:Region, lhs:Region) -> Bool {
    return (rhs.x == lhs.x && rhs.y == lhs.y)
}

public struct Region : Equatable, Hashable {
    let x, y:Int;
    public var hashValue: Int {
        get { return x ^ y }
    }
}

public class Universe {
    var seed:NSString = "a8d778e887f8884ff8c8e8"
    
    func starsInRegion(region:Region) -> [Star] {
        return [
            Star(x: 0, y: 0, z: 0, mass: 0, type: .M),
            Star(x: 100, y: 100, z: 0, mass: 0, type: .M),
            Star(x: 120, y: 190, z: 0, mass: 0, type: .M),
            Star(x: 180, y: 80, z: 0, mass: 0, type: .M),
            Star(x: 90, y: 380, z: 0, mass: 0, type: .M),
            Star(x: 480, y: 480, z: 0, mass: 0, type: .M),
            Star(x: 80, y: 280, z: 0, mass: 0, type: .M),
            Star(x: 0, y: 480, z: 0, mass: 0, type: .M),
            Star(x: 480, y: 0, z: 0, mass: 0, type: .M),
        ]
    }
    
    func planetsFor(star:Star, region:Region) -> [Planet] {
        return [
            Planet(x: -10, y: 10, z: 0, mass: 0, type: .Water)
        ]
    }
}


class StarMap {
    
    let regionSize:CGSize
    let originRegion:Region
    var viewport:CGRect
    let universe:Universe
    var viewportStars:[Star]?
    var regionStars:[Region:[Star]]
    
    init() {
        regionSize = CGSize(width: 500, height: 500)
        originRegion = Region(x: 0, y: 0)
        universe = Universe()
        viewport = UIScreen.mainScreen().bounds
        regionStars = [Region:[Star]]()
    }

    func regionAtPoint(point:CGPoint) -> Region {
        // get the total offset of the rect based on the viewport's offset
        let totalOffset = CGPoint(x: point.x + viewport.origin.x, y: point.y + viewport.origin.y)
        let offsetRegion = Region(x: Int(ceil(totalOffset.x / regionSize.width)), y: Int(ceil(totalOffset.y / regionSize.height)))
        return offsetRegion
    }

    func starsInRegion(region:Region) -> [Star] {
        if regionStars[region] == nil {
            regionStars[region] = universe.starsInRegion(region)
        }
        return regionStars[region]!
    }

    func regionsInRect(rect:CGRect) -> [Region] {
        
        // rect : x: 0, y:0, w: 320, h: 500
        // offset x: 0 y: 0
        
        let startRegion = regionAtPoint(rect.origin)
        let regionsWide = Int(ceil(rect.width / regionSize.width)) + 2
        let regionsTall = Int(ceil(rect.height / regionSize.height)) + 2
        
        var regions = [startRegion]
        for x in 0...regionsWide {
            for y in 0...regionsTall {
                regions.append(Region(x: originRegion.x + x - 1, y: originRegion.y + y - 1))
            }
        }
        return regions
    }

    func numberOfStarsInViewport() -> Int {
        return starsInViewport().count
    }
    
    func starsInViewport() -> [Star] {
        if viewportStars == nil {
            viewportStars = starsInRect(viewport)
        }
        return viewportStars!
    }

    func starsInRect(rect:CGRect) -> [Star] {
        var stars:[Star] = []
        let regions = regionsInRect(rect)
        for region in regions {
            let regionStars = starsInRegion(region)
            for star in regionStars {
                star.region = region
                stars.append(star)
            }
        }
        return stars
    }
    
    func starForIndexPath(indexPath:NSIndexPath) -> Star {
        return starsInViewport()[indexPath.item]
    }
}

/*

universe size : 100,000 x 100,000

origin region 75k, 75k

collection view:

[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][o][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]

scrolling:

[o][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]
[ ][ ][ ][ ][ ][ ][ ]

// on arrival of corner cell:

// update origin region

*/



class StarMapCollectionViewLayout : UICollectionViewLayout {
    
    let map:StarMap
    
    init(map:StarMap) {
        self.map = map
        super.init()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareLayout() {
        
    }
    
    override func collectionViewContentSize() -> CGSize {
        return map.viewport.size
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var paths = indexPathsInRect(rect)
        var allAttributes:[UICollectionViewLayoutAttributes] = []
        for path in paths {
            allAttributes.append(layoutAttributesForItemAtIndexPath(path))
        }
        return allAttributes
    }
    
    func indexPathsInRect(rect: CGRect) -> [NSIndexPath] {
        var paths:[NSIndexPath] = []
        
        var allStars = map.starsInViewport()
        var viewStars = map.starsInRect(rect)
        
        var item = 0
        for star in allStars {
            if find(viewStars, star) != nil {
                paths.append(NSIndexPath(forItem: item, inSection: 0))
            }
            item += 1
        }
        return paths
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let star = map.starForIndexPath(indexPath)
//        println("\(star)")
        let originX = star.x + CGFloat(star.region.x) * map.regionSize.width
        let originY = star.y + CGFloat(star.region.y) * map.regionSize.height
        attributes.frame = CGRectMake(originX, originY, 20, 20)
        return attributes
    }
}

class StarCell: UICollectionViewCell {
    
    var star:Star
    
    override init(frame: CGRect) {
        star = Star(x: 0, y: 0, z: 0, mass: 0, type: .M)
        super.init(frame: frame)
        contentView.removeFromSuperview()
        backgroundColor = UIColor(hue: 0.4, saturation: 0.8, brightness: 0.7, alpha: 1)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var starMap:StarMap
    var collectionView:UICollectionView
    
    convenience override init() {
        self.init(coder: NSCoder.empty())
    }

    required init(coder aDecoder: NSCoder) {
        starMap = StarMap()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: StarMapCollectionViewLayout(map: starMap))
        super.init(coder: aDecoder)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.registerClass(StarCell.self, forCellWithReuseIdentifier: "starCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        collectionView.frame = view.bounds
        starMap.viewport = CGRectMake(0, 0, view.bounds.size.width * 7, view.bounds.size.height * 7)
        view.addSubview(collectionView)
        collectionView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starMap.numberOfStarsInViewport()
    }

    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:StarCell = collectionView.dequeueReusableCellWithReuseIdentifier("starCell", forIndexPath: indexPath) as StarCell
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // update the viewport

        println("\(targetContentOffset.memory.x) \(targetContentOffset.memory.y)")
    }
}

