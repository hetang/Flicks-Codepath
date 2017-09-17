//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Hetang.Shah on 9/16/17.
//  Copyright © 2017 hetang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Cosmos

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var detailsViewContainer: UIView!

    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageCache = AutoPurgingImageCache()
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            if let cachedPoster = imageCache.image(withIdentifier: imageUrlString) {
                posterImageView.image = cachedPoster
            } else {
                Alamofire.request("https://image.tmdb.org/t/p/w342\(imageUrlString)").responseImage { response in
                    if let image = response.result.value {
                        imageCache.add(image, withIdentifier: imageUrlString)
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = image
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                        })
                    }
                }
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        movieTitle.text = movie.value(forKeyPath: "title") as? String
        movieOverview.text = movie.value(forKeyPath: "overview") as? String
        movieOverview.sizeToFit()
        ratingView.settings.updateOnTouch = false
        ratingView.settings.fillMode = .half
        if var ratings = movie.value(forKeyPath: "vote_average") as? Double {
            ratings = ratings / 2
            ratingView.rating = ratings
        } else {
            ratingView.isHidden = true
        }
        
        if let release = movie.value(forKeyPath: "release_date") as? String {
            print("release: \(release)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            let date = dateFormatter.date(from: release)! //according to date format your date string
            print("date: \(date)")
            dateFormatter.dateFormat = "MMM d, yyyy" //Your New Date format as per requirement change it own
            releaseDate.text = dateFormatter.string(from: date)
        } else {
            releaseDate.isHidden = true
        }
        detailsViewContainer.sizeToFit()
        detailsScrollView.contentSize = CGSize(width: detailsScrollView.frame.size.width, height: (detailsViewContainer.frame.origin.y + detailsViewContainer.frame.size.height - 50))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
