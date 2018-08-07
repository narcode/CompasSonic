//
//  CompassViewController.swift
//  compass
//
//  Created by Federico Zanetello on 05/04/2017.
//
//  *** Tweaked and Hacked by CompasSonic Corp @ ICMC 2018 **** |(o . 0) /
//  NO Copyright
//

import UIKit
import CoreLocation

class CompassViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  let locationDelegate = LocationDelegate()
  var latestLocation: CLLocation? = nil
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_cats) ?? 0 }
  var yourLocationBearing2: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_hall) ?? 0 }
  var yourLocationBearing3: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_art) ?? 0 }

//  var yourLocation: CLLocation {
//    get { return UserDefaults.standard.currentLocation }
//    set { UserDefaults.standard.currentLocation = newValue }
//  }

  // load ICMClocations and sounds
  var location_cats = CLLocation(latitude: 35.869243, longitude: 128.595156)
  var location_hall = CLLocation(latitude: 35.875711640645228, longitude: 128.59409842832042)
  var location_art = CLLocation(latitude: 35.875508236691772, longitude: 128.58446901882641)

  let path1 = Bundle.main.path(forResource: "cats.mp3", ofType:nil)!
  let path2 = Bundle.main.path(forResource: "hall.mp3", ofType:nil)!
  let path3 = Bundle.main.path(forResource: "art.mp3", ofType:nil)!

  var sound1 : Sound? = nil
  var sound2 : Sound? = nil
  var sound3 : Sound? = nil
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
        //////  sounds load (optimizaiton not important now) \\\\\\\
        // print(path)
        self.sound1 = Sound(url: URL(fileURLWithPath: path1))
        self.sound2 = Sound(url: URL(fileURLWithPath: path2))
        self.sound3 = Sound(url: URL(fileURLWithPath: path3))
        
        self.sounds.append(self.sound1)
        self.sounds.append(self.sound2)
        self.sounds.append(self.sound3)
        
        self.sound1?.volume = 0
        self.sound1?.play(numberOfLoops: -1)
        self.sound2?.volume = 0
        self.sound2?.play(numberOfLoops: -1)
        self.sound3?.volume = 0
        self.sound3?.play(numberOfLoops: -1)
        
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
        let chris_value3 = Double(abs(self.yourLocationBearing3.radiansToDegrees))
        
        print("CHRIS VALUE: ", chris_value, "chris value 2: ", chris_value2, "chris value 3: ", chris_value3)

        
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
        
//        let angle = computeNewAngle(with: CGFloat(newHeading))
//        let angleDegree = -angle.radiansToDegrees
//        print("ANGLE: ", angle.radiansToDegrees)
        print("TRUE NORTH: ", newHeading) // this are the degrees :)
//        let angle_cats = angle.radiansToDegrees
//        let heading_cats = 360-abs(angle_cats)
        let heading_locations = 360-newHeading
        print("FIRST LOCATION -> ", heading_locations)
        
        // calibration compensation or error margin:
        let error_margin = 3.0
        
        if(heading_locations >= chris_value-error_margin && heading_locations <= chris_value+error_margin){
            print("sound1 playing")
            self.sound1?.volume = 1
        } else {
            print("sound1 off")
            self.sound1?.volume = 0
        }
        
        // play sounds if device is pointing to the specific location:
        if(heading_locations >= chris_value2-error_margin && heading_locations <= chris_value2+error_margin){
            print("sound2 playing")
            self.sound2?.volume = 1
        } else {
            print("sound2 off")
            self.sound2?.volume = 0
        }
        
        if(heading_locations >= chris_value3-error_margin && heading_locations <= chris_value3+error_margin){
            print("sound3 playing")
            self.sound3?.volume = 1
        } else {
            print("sound3 off")
            self.sound3?.volume = 0
        }
        
//        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
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
