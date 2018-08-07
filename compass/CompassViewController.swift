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
    
  let path1 = Bundle.main.path(forResource: "cats.mp3", ofType:nil)!
  let path2 = Bundle.main.path(forResource: "art.mp3", ofType:nil)!
  let path3 = Bundle.main.path(forResource: "hall.mp3", ofType:nil)!

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
    
    public func volumeAdjustment(angleLo: Double, angleHi: Double, angleCur: Float) -> Float {
        print("low angle: ", angleLo, "hi angle: ", angleHi, "current angle", angleCur)
        var vol : Float = 1
        var mid : Float = 0

        // first case scenario: lo < hi
        if(angleLo < angleHi){
            mid = Float(angleHi + angleLo) / 2
            vol = 1 - abs((angleCur - mid) / (Float(angleHi) - mid))
            print(">>>>>> current vol: ", vol)
        }
        // second case scenario: lo > hi
        else {
            mid = Float(angleHi - ((6.28 - angleLo + angleHi) / 2))
            print("mid ===== ", mid)
            vol = 1 - abs((angleCur - mid) / (Float(angleHi) - mid))
            print(">>>>>> current vol: ", vol)
        }
        return vol
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
        let angleFlipped = -angle
//        let angleDegree = -angle.radiansToDegrees
        print("ANGLE: ", angleFlipped)
        //print(newHeading) // this are the degrees :)

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
        
        if((angleFlipped < 6.28 && angleFlipped > 4.71) || (angleFlipped < 1.57 && angleFlipped > 0)){
            print("sound1 playing")
            
            self.sound1?.volume = self.volumeAdjustment(angleLo: 4.71, angleHi: 1.57, angleCur: Float(angleFlipped))
        } else if (angleFlipped > 1.57 && angleFlipped < 4.71) {
            print("sound2 playing")
            self.sound2?.volume = self.volumeAdjustment(angleLo: 1.57, angleHi: 4.71, angleCur: Float(angleFlipped))
        } else {
            self.sound1?.volume = 0
            self.sound2?.volume = 0
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
