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

class MovieListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NVActivityIndicatorViewable, UISearchBarDelegate {
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var movieTableView: UITableView!
    
    var endpoint: String!
    var movies: [NSDictionary] = []
    var tableMovies: [NSDictionary] = []

    lazy var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        searchBar.placeholder = "Search movie name..."
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        fetchMovieList()
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchMovieList(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        movieTableView.insertSubview(refreshControl, at: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MovieListCell = tableView.dequeueReusableCell(withIdentifier: "MovieListCell", for: indexPath) as! MovieListCell
        cell.posterImage.image = nil

        let movie = tableMovies[indexPath.row]
        let imageCache = AutoPurgingImageCache()
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            if let cachedPoster = imageCache.image(withIdentifier: imageUrlString) {
                cell.posterImage.image = cachedPoster
            } else {
                Alamofire.request("https://image.tmdb.org/t/p/w342\(imageUrlString)").responseImage { response in
                    if let image = response.result.value {
                        imageCache.add(image, withIdentifier: imageUrlString)
                        cell.posterImage.alpha = 0.0
                        cell.posterImage.image = image
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            cell.posterImage.alpha = 1.0
                        })
                    }
                }
            }
        } else {
            // photos is nil. Good thing we didn't try to unwrap it!
        }
        
        cell.movieTitle.text = movie.value(forKeyPath: "title") as? String
        cell.movieDescription.text = movie.value(forKeyPath: "overview") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.red
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        deSelectedCell.contentView.backgroundColor = UIColor.black
    }

    func fetchMovieList(_ refreshControl: UIRefreshControl? = nil) {
        startAnimating(CGSize(width: 40, height: 40), type: .lineSpinFadeLoader)
        
        if(NetworkReachabilityManager()!.isReachable) {
            networkErrorView.isHidden = true
            Alamofire.request("https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=b77938edb923ce496495324ce5825607").responseJSON { response in
                self.cancelSearchFocus()
                self.stopAnimating()
                
                if let data = response.result.value as? NSDictionary {
                    self.movies = data["results"] as! [NSDictionary]
                    self.tableMovies = self.movies
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let index = movieTableView.indexPath(for: cell)
        let movie = tableMovies[(index!.row)]
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        self.tabBarController?.tabBar.isHidden = true
        movieTableView.deselectRow(at: index!, animated: true)
    }

    /**
     * Search Bar Delegates functions
    **/
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keyword = searchText.lowercased()
        if (keyword.characters.count == 0) {
            self.tableMovies = self.movies
            self.movieTableView.reloadData()
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(filterMovies(keyword:)), object: nil)
            self.perform(#selector(filterMovies(keyword:)), with: keyword, afterDelay: 0.5)
        }
    }
    
    func filterMovies(keyword: String) {
        print("keyword: \(keyword)")
        let searchResults = movies.filter{
            var title = $0.value(forKeyPath: "title") as? String ?? ""
            title = title.lowercased()
            
            var overview = $0.value(forKeyPath: "overview") as? String ?? ""
            overview = overview.lowercased()
            
            return title.range(of: keyword) != nil
                || overview.range(of: keyword) != nil
            
        }
        
        print("searchResults: \(searchResults)")
        self.tableMovies = searchResults
        self.movieTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSearchFocus))
        return true
    }
    
    func cancelSearchFocus() {
        navigationItem.rightBarButtonItem = nil
        searchBar.resignFirstResponder()
        searchBar.text = nil
        self.tableMovies = self.movies
        self.movieTableView.reloadData()

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
