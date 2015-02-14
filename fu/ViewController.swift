//
//  ViewController.swift
//  fu
//
//  Created by Johnny Sparks on 2/13/15.
//
//

import UIKit

enum StarType : Printable {
    case M, G
    var description: String {
        get { return self == M ? "M" : "G" }
    }
}

enum PlanetType {
    case Gas, Ice, Water
}

struct Body: Printable {
    let x, y, z:CGFloat
    var description: String {
        get { return "\(x) \(y) \(z)" }
    }
}

struct Star: Printable {
    let body:Body
    let type:StarType
    var description: String {
        get { return "\(body) \(type)" }
    }
}

struct Planet {
    let body:Body
    let type:PlanetType
}


class StarMap {
    
    var stars:[Star] = []
    
    init(stars:[Star]) {
        self.stars = stars
    }
    
    func numberOfRegions() -> Int {
        return 1
    }
    
    func numberOfStarsInRegion(region:Int) -> Int {
        return region == 0 ? stars.count : 0
    }
    
    func starForIndexPath(indexPath:NSIndexPath) -> Star {
        return stars[indexPath.row]
    }
}


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
        return CGSize(width: CGRectGetWidth(collectionView!.bounds) * 20, height: CGRectGetHeight(collectionView!.bounds) * 20)
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
        for region:Int in 0...map.numberOfRegions() - 1  {
            for item:Int in 0...map.numberOfStarsInRegion(region) - 1 {
                let path = NSIndexPath(forItem: item, inSection: region)
                println("\(path)")
                paths.append(path)
            }
        }
        return paths
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let star = map.starForIndexPath(indexPath)
        println("\(star)")
        attributes.frame = CGRectMake(star.body.x, star.body.y, 20, 20)
        return attributes
    }
}

class StarCell: UICollectionViewCell {
    
    var star:Star
    
    override init(frame: CGRect) {
        star = Star(body: Body(x: 0, y: 0, z: 0), type: .M)
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
    
    required init(coder aDecoder: NSCoder) {
        starMap = StarMap(stars:[
            Star(body: Body(x: 100, y: 100, z: 0), type: .M),
            Star(body: Body(x: 120, y: 190, z: 0), type: .M),
            Star(body: Body(x: 180, y: 80, z: 0), type: .M),
            Star(body: Body(x: 90, y: 380, z: 0), type: .M),
            Star(body: Body(x: 280, y: 480, z: 0), type: .M),
            Star(body: Body(x: 80, y: 280, z: 0), type: .M),
        ])
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
        view.addSubview(collectionView)
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return starMap.numberOfStarsInRegion(section)
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


}

