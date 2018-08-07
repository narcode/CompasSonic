//  Jeena Yin
//  MapViewController.swift
//  compass
//
//  Created by Federico Zanetello on 23/04/2017.
//  Copyright © 2017 Kimchi Media. All rights reserved.
//
import AVFoundation

import UIKit
import MapKit

class MapViewController: UIViewController {
  var delegate: MapViewControllerDelegate!
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func cancelTap(_ sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func resetTap(_ sender: UIBarButtonItem) {
    delegate.update(location: CLLocation(latitude: 90, longitude: 0))
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    print("in function>>>>>>")
    
    var isThatYou: AVAudioPlayer?
    
    let path = Bundle.main.path(forResource: "isthatyou01", ofType: "wav")!
    print(path)
    let url = URL(fileURLWithPath: path)
    
    do {
        isThatYou = try AVAudioPlayer(contentsOf: url)
        isThatYou?.numberOfLoops = -1
        isThatYou?.prepareToPlay()
        isThatYou?.play()
        //print(isThatYou?.isPlaying as Any)
    } catch {
        print("couldn't load file :(")
    }
    
    mapView.showsUserLocation = true
    if #available(iOS 9, *) {
      mapView.showsScale = true
      mapView.showsCompass = true
    }
    
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.didTap(_:)))
    mapView.addGestureRecognizer(gestureRecognizer)
  }

  public func didTap(_ gestureRecognizer: UIGestureRecognizer) {
    
    
    let location = gestureRecognizer.location(in: mapView)
    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    
    delegate.update(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    self.dismiss(animated: true, completion: nil)
  }
}


