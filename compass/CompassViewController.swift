//
//  CompassViewController.swift
//  compass
//
//  Created by Federico Zanetello on 05/04/2017.
//  Copyright © 2017 Kimchi Media. All rights reserved.
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  let locationDelegate = LocationDelegate()
  var latestLocation: CLLocation? = nil
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_cats) ?? 0 }
  var yourLocationBearing2: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_hall) ?? 0 }

//  var yourLocation: CLLocation {
//    get { return UserDefaults.standard.currentLocation }
//    set { UserDefaults.standard.currentLocation = newValue }
//  }
//  var location_cats = CLLocation(latitude: 35.869243, longitude: 128.595156)
  var location_cats = CLLocation(latitude: 35.875508236691772, longitude: 128.58446901882641)
  var location_hall = CLLocation(latitude: 35.875711640645228, longitude: 128.59409842832042)


  let path1 = Bundle.main.path(forResource: "cats.mp3", ofType:nil)!
  let path2 = Bundle.main.path(forResource: "hall.mp3", ofType:nil)!
  let path3 = Bundle.main.path(forResource: "art.mp3", ofType:nil)!

  var sound1 : Sound? = nil
  var sound2 : Sound? = nil
  var sounds : Array<Sound?> = []
    
  let locationManager: CLLocationManager = {
    $0.requestWhenInUseAuthorization()
    $0.desiredAccuracy = kCLLocationAccuracyBest
    $0.startUpdatingLocation()
    $0.startUpdatingHeading()
    return $0
  }(CLLocationManager())
    
  private func orientationAdjustment() -> CGFloat {
    let isFaceDown: Bool = {
      switch UIDevice.current.orientation {
      case .faceDown: return true
      default: return false
      }
    }()
    
    let adjAngle: CGFloat = {
      switch UIApplication.shared.statusBarOrientation {
      case .landscapeLeft:  return 90
      case .landscapeRight: return -90
      case .portrait, .unknown: return 0
      case .portraitUpsideDown: return isFaceDown ? 180 : -180
      }
    }()
    return adjAngle
  }
  
    override func viewWillAppear(_ animated: Bool) {
        //////  sounds load \\\\\\\
        // print(path)
        self.sound1 = Sound(url: URL(fileURLWithPath: path1))
        self.sound2 = Sound(url: URL(fileURLWithPath: path2))
        self.sounds.append(self.sound1)
        self.sounds.append(self.sound2)
        
        self.sound1?.volume = 0
        self.sound1?.play(numberOfLoops: -1)
        self.sound2?.volume = 0
        self.sound2?.play(numberOfLoops: -1)
    }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = locationDelegate
    
    locationDelegate.locationCallback = { location in
      self.latestLocation = location
    }
    
    locationDelegate.headingCallback = { newHeading in
      
        let chris_value = Double(abs(self.yourLocationBearing.radiansToDegrees))
        let chris_value2 = Double(abs(self.yourLocationBearing2.radiansToDegrees))
        print("CHRIS VALUE: ", chris_value, "chris value 2: ", chris_value2)

        
      func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
        let heading: CGFloat = {
          let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
          switch UIDevice.current.orientation {
          case .faceDown: return -originalHeading
          default: return originalHeading
          }
        }()
        
        return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
      }
      
//      print(self.location_cats)
        
      UIView.animate(withDuration: 0.5) {
        
        let angle = computeNewAngle(with: CGFloat(newHeading))
//        let angleDegree = -angle.radiansToDegrees
//        print("ANGLE: ", angle.radiansToDegrees)
        print("TRUE NORTH: ", newHeading) // this are the degrees :)
//        let angle_cats = angle.radiansToDegrees
//        let heading_cats = 360-abs(angle_cats)
        let heading_locations = 360-newHeading
        print("CATS HEADING? -> ", heading_locations)
//        if(newHeading >= 355 && newHeading <= 360){
//            print("sound1 playing")
//            self.sound1?.volume = 1
//        } else {
//            if(newHeading >= 354-25 && newHeading <= 354) {
//                print("sound1 softer")
//                self.sound1?.volume = Float((newHeading/365)-0.9)
//            } else {
//                print("sound1 at 0")
//                self.sound1?.volume = 0
//                }
//            }
        
        if(heading_locations >= chris_value-5 && heading_locations <= chris_value+5){
            print("sound1 playing")
            self.sound1?.volume = 1
        } else {
            print("sound1 off")
            self.sound1?.volume = 0
        }
        
        if(heading_locations >= chris_value2-5 && heading_locations <= chris_value2+5){
            print("sound2 playing")
            self.sound2?.volume = 1
        } else {
            print("sound2 off")
            self.sound2?.volume = 0
        }
        
        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
      }
    }
    
//    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CompassViewController.showMap))
//    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
//  func showMap() {
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController")
//    ((mapViewController as? UINavigationController)?.viewControllers.first as? MapViewController)?.delegate = self
//    self.present(mapViewController, animated: true, completion: nil)
//  }
}

//extension CompassViewController: MapViewControllerDelegate {
//  func update(location: CLLocation) {
//    yourLocation = location
//  }
//}
