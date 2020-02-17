/// Copyright (c) 2563 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreLocation

class KeyboardViewController: UIInputViewController {
    // 1
    var morseKeyboardView: MorseKeyboardView!

    var userLexicon: UILexicon?
    
    var currentWord: String? {
      var lastWord: String?
      // 1
      if let stringBeforeCursor = textDocumentProxy.documentContextBeforeInput {
        // 2
        stringBeforeCursor.enumerateSubstrings(in: stringBeforeCursor.startIndex...,
                                               options: .byWords)
        { word, _, _, _ in
          // 3
          if let word = word {
            lastWord = word
          }
        }
      }
      return lastWord
    }
    
    var currentLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      // 2
      let nib = UINib(nibName: "MorseKeyboardView", bundle: nil)
      let objects = nib.instantiate(withOwner: nil, options: nil)
      morseKeyboardView = objects.first as! MorseKeyboardView
      guard let inputView = inputView else { return }
      inputView.addSubview(morseKeyboardView)
      
      // 3
      morseKeyboardView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        morseKeyboardView.leftAnchor.constraint(equalTo: inputView.leftAnchor),
        morseKeyboardView.topAnchor.constraint(equalTo: inputView.topAnchor),
        morseKeyboardView.rightAnchor.constraint(equalTo: inputView.rightAnchor),
        morseKeyboardView.bottomAnchor.constraint(equalTo: inputView.bottomAnchor)
        ])

        morseKeyboardView.setNextKeyboardVisible(needsInputModeSwitchKey)
        
        morseKeyboardView.nextKeyboardButton.addTarget(self,
        action: #selector(handleInputModeList(from:with:)),
        for: .allTouchEvents)
        
        morseKeyboardView.delegate = self
        
        requestSupplementaryLexicon { lexicon in
          self.userLexicon = lexicon
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    
}

// MARK: - MorseKeyboardViewDelegate
extension KeyboardViewController: MorseKeyboardViewDelegate {
    func insertCharacter(_ newCharacter: String) {
        textDocumentProxy.insertText(newCharacter)
    }

    func deleteCharacterBeforeCursor() {
        textDocumentProxy.deleteBackward()
    }

    func characterBeforeCursor() -> String? {
        // 1
        guard let character = textDocumentProxy.documentContextBeforeInput?.last else {
          return nil
        }
        // 2
        return String(character)
    }
}

extension KeyboardViewController {
    override func textDidChange(_ textInput: UITextInput?) {
      // 1
      let colorScheme: MorseColorScheme

      // 2
      if textDocumentProxy.keyboardAppearance == .dark {
        colorScheme = .dark
      } else {
        colorScheme = .light
      }

      // 3
      morseKeyboardView.setColorScheme(colorScheme)
    }
}

// MARK: - Private methods
private extension KeyboardViewController {
  func attemptToReplaceCurrentWord() {
    // 1
    guard let entries = userLexicon?.entries,
      let currentWord = currentWord?.lowercased() else {
        return
    }

    // 2
    let replacementEntries = entries.filter {
      $0.userInput.lowercased() == currentWord
    }

    if let replacement = replacementEntries.first {
      // 3
      for _ in 0..<currentWord.count {
        textDocumentProxy.deleteBackward()
      }

      // 4
      textDocumentProxy.insertText(replacement.documentText)
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension KeyboardViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.first
  }
}
