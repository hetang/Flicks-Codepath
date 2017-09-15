//
//  MovieListViewController.swift
//  Flicks
//
//  Created by Hetang.Shah on 9/13/17.
//  Copyright © 2017 hetang. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import NVActivityIndicatorView

class MovieListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var movieTableView: UITableView!
    
    var endpoint: String!
    var movies: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMovieList()
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchMovieList(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieListCell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell", for: indexPath) as! MovieListCell
        cell.posterImage.image = nil
        
        let movie = movies[indexPath.row]
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            Alamofire.request("https://image.tmdb.org/t/p/w342\(imageUrlString)").responseImage { response in
                if let image = response.result.value {
                    cell.posterImage.image = image
                }
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        cell.movieTitle.text = movie.value(forKeyPath: "title") as? String
        cell.movieDescription.text = movie.value(forKeyPath: "overview") as? String
        
        return cell
    }

    func fetchMovieList(_ refreshControl: UIRefreshControl? = nil) {
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        
        if(NetworkReachabilityManager()!.isReachable) {
            networkErrorView.isHidden = true
            Alamofire.request("https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=b77938edb923ce496495324ce5825607").responseJSON { response in
                
                self.stopAnimating()
                
                if let data = response.result.value as? NSDictionary {
                    self.movies = data["results"] as! [NSDictionary]
                    self.movieTableView.reloadData()
                    refreshControl?.endRefreshing()
                }
            }
        } else {
            networkErrorView.isHidden = false
            stopAnimating()
            refreshControl?.endRefreshing()
        }
    }

}
