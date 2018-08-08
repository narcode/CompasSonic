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
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
  var yourLocation: CLLocation {
    get { return UserDefaults.standard.currentLocation }
    set { UserDefaults.standard.currentLocation = newValue }
  }
    
  let path1 = Bundle.main.path(forResource: "hall.mp3", ofType:nil)!
  let path2 = Bundle.main.path(forResource: "cats.mp3", ofType:nil)!
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
    
    public func volumeAdjustment(angleLo: Double, angleHi: Double, angleCur: Float) -> Float {
        //rounding
        let lo = round(100 * angleLo) / 100
        let hi = round(100 * angleHi) / 100
        let cur = Float(round(100 * angleCur) / 100)
        
        print("low angle: ", lo, "hi angle: ", hi, "current angle", cur)
        var vol : Float = 0
        var mid : Float = 0

        // first case scenario: lo < hi
        if(lo < hi){
            mid = Float(hi + lo) / 2
            vol = 1 - abs((cur - mid) / (Float(hi) - mid))
            print(">>>>>> current vol: ", vol)
        }
        // second case scenario: lo > hi **** Buggy ****
        else{
            vol = 1
        }
        return vol
    }
  
    override func viewWillAppear(_ animated: Bool) {
        //////  sounds load \\\\\\\
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
      
      UIView.animate(withDuration: 0.5) {
        // radian
        let angle = computeNewAngle(with: CGFloat(newHeading))
        let angleFlipped = Float(-angle)
//        let angleDegree = -angle.radiansToDegrees
        print("ANGLE: ", angleFlipped)
        //print(newHeading) // this are the degrees :)
        
        // sound ranges
        let lo1: Float = 5.17
        let hi1: Float = 0.8
        
        let lo2: Float = 1.57
        let hi2: Float = 4
        
        let lo3: Float = 4
        let hi3: Float = 5
        
        if((angleFlipped < 6.28 && angleFlipped > lo1) || (angleFlipped < hi1 && angleFlipped > 0)){
            print("sound1 playing")
            self.sound1?.volume = self.volumeAdjustment(angleLo: Double(lo1), angleHi: Double(hi1), angleCur: angleFlipped)
        } else if (angleFlipped > lo2 && angleFlipped < hi2) {
            print("sound2 playing")
            self.sound2?.volume = self.volumeAdjustment(angleLo: Double(lo2), angleHi: Double(hi2), angleCur: angleFlipped)
        } else if (angleFlipped > lo3 && angleFlipped < hi3) {
            print("sound3 playing")
            self.sound3?.volume = self.volumeAdjustment(angleLo: Double(lo3), angleHi: Double(hi3), angleCur: angleFlipped)
        }
        else {
            self.sound1?.volume = 0
            self.sound2?.volume = 0
            self.sound3?.volume = 0
        }
        
        self.imageView.transform = CGAffineTransform(rotationAngle: angle)
      }
    }
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CompassViewController.showMap))
    view.addGestureRecognizer(tapGestureRecognizer)
  }
  
  func showMap() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController")
    ((mapViewController as? UINavigationController)?.viewControllers.first as? MapViewController)?.delegate = self
    self.present(mapViewController, animated: true, completion: nil)
  }
}

extension CompassViewController: MapViewControllerDelegate {
  func update(location: CLLocation) {
    yourLocation = location
  }
}
