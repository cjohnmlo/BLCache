//
//  ViewController.swift
//  BLCacheSample
//
//  Created by Christian John Lo on 07/05/2019.
//  Copyright © 2019 cjohnmlo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var sampleTable: UITableView!
    var stringUrlArray : [String] = []
    let sampleImages = ["https://picsum.photos/id/237/350/200",
                        "https://picsum.photos/id/123/450/200",
                        "https://picsum.photos/id/211/450/250",
                        "https://picsum.photos/id/199/350/300",
                        "https://picsum.photos/id/163/350/270"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //fake the data
        // 50 strings
        stringUrlArray = Array(repeating: sampleImages[0], count: 10) + Array(repeating: sampleImages[1], count: 10) + Array(repeating: sampleImages[2], count: 10) + Array(repeating: sampleImages[3], count: 10) + Array(repeating: sampleImages[4], count: 10)
        stringUrlArray = stringUrlArray.shuffled()
        
        sampleTable.dataSource = self
        sampleTable.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stringUrlArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusedCell = tableView.dequeueReusableCell(withIdentifier: "cell-reuse") as? TableViewCell
        
        guard let cell = reusedCell else {
            return UITableViewCell()
        }
        
        BLImageCache.shared.getImage(from: stringUrlArray[indexPath.row]) { (image) in
            cell.bgImage.image = image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

