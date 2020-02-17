/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

/// Delegate method for the morse keyboard view that will allow it to perform
/// actions on whatever text entry you want to use it with. It does not assume
/// any type e.g. UITextField vs UITextView.
protocol MorseKeyboardViewDelegate: class {
  func insertCharacter(_ newCharacter: String)
  func deleteCharacterBeforeCursor()
  func characterBeforeCursor() -> String?
}

/// Contains all of the logic for handling button taps and translating that into
/// specific actions on the text entry associated with it
class MorseKeyboardView: UIView {
//  @IBOutlet var previewLabel: UILabel!
  @IBOutlet var nextKeyboardButton: UIButton!
  @IBOutlet var deleteButton: UIButton!
  @IBOutlet var stackView: UIStackView!
  @IBOutlet var spaceButtonToParentConstraint: NSLayoutConstraint!
  @IBOutlet var spaceButtonToNextKeyboardConstraint: NSLayoutConstraint!
  @IBOutlet var predictCollectionView: UICollectionView!

  weak var delegate: MorseKeyboardViewDelegate?
    
    var predictionArray: [String] = []
    
    var weatherData = WeatherData()

  /// Cache of signal inputs
  var signalCache: [MorseData.Signal] = [] {
    didSet {
      var text = ""
      if signalCache.count > 0 {
        text = signalCache.reduce("") {
          return $0 + $1.rawValue
        }
        text += " = \(cacheLetter)"
      }
//      previewLabel.text = text
    }
  }

  /// The letter represented by the current signalCache
  var cacheLetter: String {
    return MorseData.letter(fromSignals: signalCache) ?? "?"
  }
    
    var weatherCacheLetter: String = ""

  override init(frame: CGRect) {
    super.init(frame: frame)
    insertKeys(.English)
    setNextKeyboardVisible(false)
    setupCollectionView()
    setColorScheme(.light)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    insertKeys(.English)
    setNextKeyboardVisible(false)
    setupCollectionView()
    setColorScheme(.light)
  }

  func setNextKeyboardVisible(_ visible: Bool) {
    spaceButtonToNextKeyboardConstraint.isActive = visible
    spaceButtonToParentConstraint.isActive = !visible
    nextKeyboardButton.isHidden = !visible
  }

  func setColorScheme(_ colorScheme: MorseColorScheme) {
    var colorScheme = MorseColors(colorScheme: colorScheme)
    
//    previewLabel.backgroundColor = colorScheme.previewBackgroundColor
//    previewLabel.textColor = colorScheme.previewTextColor
    backgroundColor = colorScheme.backgroundColor
    predictCollectionView.backgroundColor = colorScheme.backgroundColor
    
    func buttonColor(_ button: KeyboardButton) {
          button.setTitleColor(colorScheme.buttonTextColor, for: [])
          button.tintColor = colorScheme.buttonTextColor

          if button == nextKeyboardButton || button == deleteButton {
            button.defaultBackgroundColor = colorScheme.buttonHighlightColor
            button.highlightBackgroundColor = colorScheme.buttonBackgroundColor
          } else {
            button.defaultBackgroundColor = colorScheme.buttonBackgroundColor
            button.highlightBackgroundColor = colorScheme.buttonHighlightColor
          }
    }

    for view in subviews {
      if let button = view as? KeyboardButton {
        buttonColor(button)
        }
      else if let s = view as? UIStackView {
        for view in s.arrangedSubviews {
            if let ss = view as? UIStackView {
                for view in ss.arrangedSubviews {
                    if let ss = view as? UIStackView {
                        for view in ss.arrangedSubviews {
                            if let button = view as? KeyboardButton {
                            buttonColor(button)
                            }
                        }
                    }
                }
            }
        }
        }
      }
    }
    
    func insertKeys(_ arrangement: KeyArrangement) {
        let maxRowCount = arrangement.getMaxRowCount()
        let maxKeySize = (self.stackView.bounds.size.width / CGFloat(maxRowCount)) - CGFloat(2.0)
        for row in arrangement.getKeyRows() {
//            let rowCount = row.count
            
            let outsideStack = UIStackView()
            outsideStack.axis = .horizontal
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            stack.spacing = 6
//            stack.heightAnchor.constraint(equalToConstant: 45).isActive = true
            self.stackView?.addArrangedSubview(outsideStack)
            outsideStack.addArrangedSubview(stack)
            for key in row {
                let button = KeyboardButton()
                button.addTarget(self, action: #selector(keyPressed(text:)), for: .touchUpInside)
                button.setTitle(key, for: .normal)
                stack.addArrangedSubview(button)
                button.widthAnchor.constraint(equalToConstant: maxKeySize).isActive = true
            }
            let leftView = UIView()
            leftView.backgroundColor = .clear
            outsideStack.insertArrangedSubview(leftView, at: 0)
            let rightView = UIView()
            rightView.backgroundColor = .clear
            outsideStack.addArrangedSubview(rightView)
            leftView.widthAnchor.constraint(equalTo: rightView.widthAnchor).isActive = true
        }
    }
    
    func setupCollectionView() {
        predictCollectionView.delegate = self
        predictCollectionView.dataSource = self
        predictCollectionView.register(UINib(nibName: "PredictionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
}

enum KeyArrangement { case English
    func getKeyRows() -> [[String]] {
        switch self {
        case .English:
            return [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"], ["a", "s", "d", "f", "g", "h", "j", "k", "l"], ["z", "x", "c", "v", "b", "n", "m"]]
        }
    }
    
    func getMaxRowCount() -> Int {
        let longestSubArray = self.getKeyRows().max(by: { $0.count < $1.count })!
        return longestSubArray.count
    }
}

// MARK: - Actions
extension MorseKeyboardView {
  @IBAction func dotPressed(button: UIButton) {
    addSignal(.dot)
  }

  @IBAction func dashPressed() {
    addSignal(.dash)
  }

  @IBAction func deletePressed() {
    if weatherCacheLetter.count > 0 {
        weatherCacheLetter.removeLast()
    }
      delegate?.deleteCharacterBeforeCursor()
  }

  @IBAction func spacePressed() {
    if signalCache.count > 0 {
      // Clear our the signal cache
      signalCache = []
    } else {
      delegate?.insertCharacter(" ")
        weatherCacheLetter.removeAll()
        predictionArray = []
        predictCollectionView.reloadData()

    }
  }
    
    func weatherString(text: String) -> String {
        return "\("".weatherEmoji().first ?? "") \((weatherData.temptFrom(WeekDayConverter.getNextWeekDayOf(text)) * 100).rounded() / 100.0 ) °C"
    }

  @IBAction func keyPressed(text: UIButton) {
    if signalCache.count > 0 {
      // Clear our the signal cache
      signalCache = []
    } else {
        weatherCacheLetter.append(text.titleLabel?.text ?? "")
        delegate?.insertCharacter(text.titleLabel?.text ?? "")

        predictionArray = []
        if weatherCacheLetter.count > 2 {
            predictionArray = ["\(weatherString(text: weatherCacheLetter))"]
        }
        predictCollectionView.reloadData()
    }
  }
}

// MARK: - Private Methods
private extension MorseKeyboardView {
  func addSignal(_ signal: MorseData.Signal) {
    if signalCache.count == 0 {
      // Have an empty cache
      signalCache.append(signal)
      delegate?.insertCharacter(cacheLetter)
    } else {
      // Building on existing letter
      signalCache.append(signal)
      delegate?.deleteCharacterBeforeCursor()
      delegate?.insertCharacter(cacheLetter)
    }
  }
}

extension MorseKeyboardView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return predictionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PredictionCollectionViewCell
        
        cell.didPress = {
            self.delegate?.insertCharacter(self.predictionArray[indexPath.item])
            self.weatherCacheLetter.removeAll()
            self.predictionArray = []
            self.predictCollectionView.reloadData()
        }
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.titleLabel.setTitle(predictionArray[indexPath.item], for: .normal)

        return cell
    }
}

extension MorseKeyboardView: UICollectionViewDelegate {
}

extension MorseKeyboardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.bounds.width)/CGFloat(predictionArray.count)) * 0.8, height: collectionView.bounds.height)
    }
}
