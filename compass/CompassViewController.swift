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
  var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_felipe) ?? 0 }
  var yourLocationBearing2: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_anne) ?? 0 }
  var yourLocationBearing3: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_i_lly) ?? 0 }
  var yourLocationBearing4: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_chris) ?? 0 }
  var yourLocationBearing5: CGFloat { return latestLocation?.bearingToLocationRadian(self.location_jeena) ?? 0 }

//  var yourLocation: CLLocation {
//    get { return UserDefaults.standard.currentLocation }
//    set { UserDefaults.standard.currentLocation = newValue }
//  }

  // load ICMClocations and sounds
  var location_felipe = CLLocation(latitude: 35.869243, longitude: 128.595156)
  var location_anne = CLLocation(latitude: 35.875711640645228, longitude: 128.59409842832042)
  var location_i_lly = CLLocation(latitude: 35.875508236691772, longitude: 128.58446901882641)
  var location_chris = CLLocation(latitude: 35.8776782, longitude: 128.5947702)
  var location_jeena = CLLocation(latitude: 35.8776782, longitude: 128.5947702)

  let path1 = Bundle.main.path(forResource: "cats.mp3", ofType:nil)! //felipe
  let path2 = Bundle.main.path(forResource: "hall.mp3", ofType:nil)! //anne
  let path3 = Bundle.main.path(forResource: "art.mp3", ofType:nil)!  //i-lly
  let path4 = Bundle.main.path(forResource: "kPop.mp3", ofType:nil)! //chris
  let path5 = Bundle.main.path(forResource: "kPop.mp3", ofType:nil)! //jeena


  var sound1 : Sound? = nil
  var sound2 : Sound? = nil
  var sound3 : Sound? = nil
  var sound4 : Sound? = nil
  var sound5 : Sound? = nil


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
        //////  sounds load (optimizaiton not important now) \\\\\\\
        // print(path)
        self.sound1 = Sound(url: URL(fileURLWithPath: path1))
        self.sound2 = Sound(url: URL(fileURLWithPath: path2))
        self.sound3 = Sound(url: URL(fileURLWithPath: path3))
        self.sound4 = Sound(url: URL(fileURLWithPath: path4))
        self.sound5 = Sound(url: URL(fileURLWithPath: path5))

        
        self.sounds.append(self.sound1)
        self.sounds.append(self.sound2)
        self.sounds.append(self.sound3)
        self.sounds.append(self.sound4)
        self.sounds.append(self.sound5)
        
        self.sound1?.volume = 0
        self.sound1?.play(numberOfLoops: -1)
        self.sound2?.volume = 0
        self.sound2?.play(numberOfLoops: -1)
        self.sound3?.volume = 0
        self.sound3?.play(numberOfLoops: -1)
        self.sound4?.volume = 0
        self.sound4?.play(numberOfLoops: -1)
        self.sound5?.volume = 0
        self.sound5?.play(numberOfLoops: -1)
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
        let chris_value4 = Double(abs(self.yourLocationBearing4.radiansToDegrees))
        let chris_value5 = Double(abs(self.yourLocationBearing4.radiansToDegrees))
        
        print("CHRIS VALUE: ", chris_value, "chris value 2: ", chris_value2, "chris value 3: ", chris_value3, "chris value 4: ", chris_value4, "chris value 5: ", chris_value5)

        
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
        
        print("TRUE NORTH: ", newHeading) // this are the degrees :)

        let heading_locations = 360-newHeading
        print("FIRST LOCATION -> ", heading_locations)
        
        // calibration compensation or error margin:
        let error_margin = 0.5
        
        // play sounds if device is pointing to the specific location:
        if(heading_locations >= chris_value-error_margin && heading_locations <= chris_value+error_margin){
            print("sound1 playing")
            self.sound1?.volume = self.volumeAdjustment(angleLo: chris_value-error_margin,
                                                        angleHi: chris_value+error_margin,
                                                        angleCur: Float(heading_locations))
        } else {
            
            print("sound1 off")
            self.sound1?.volume = 0
        }
        
        if(heading_locations >= chris_value2-error_margin && heading_locations <= chris_value2+error_margin){
            print("sound2 playing")
            self.sound2?.volume = self.volumeAdjustment(angleLo: chris_value2-error_margin,
                                                        angleHi: chris_value2+error_margin,
                                                        angleCur: Float(heading_locations))
        } else {
            print("sound2 off")
            self.sound2?.volume = 0
        }
        
        if(heading_locations >= chris_value3-error_margin && heading_locations <= chris_value3+error_margin){
            print("sound3 playing")
            self.sound3?.volume = self.volumeAdjustment(angleLo: chris_value3-error_margin,
                                                        angleHi: chris_value3+error_margin,
                                                        angleCur: Float(heading_locations))
        } else {
            print("sound3 off")
            self.sound3?.volume = 0
        }
        
        if(heading_locations >= chris_value4-error_margin && heading_locations <= chris_value4+error_margin){
            print("sound4 playing")
            self.sound4?.volume = self.volumeAdjustment(angleLo: chris_value4-error_margin,
                                                        angleHi: chris_value4+error_margin,
                                                        angleCur: Float(heading_locations))
        } else {
            print("sound4 off")
            self.sound4?.volume = 0
        }
        
        if(heading_locations >= chris_value5-error_margin && heading_locations <= chris_value5+error_margin){
            print("sound5 playing")
            self.sound5?.volume = self.volumeAdjustment(angleLo: chris_value5-error_margin,
                                                        angleHi: chris_value5+error_margin,
                                                        angleCur: Float(heading_locations))
        } else {
            print("sound5 off")
            self.sound5?.volume = 0
        }
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
