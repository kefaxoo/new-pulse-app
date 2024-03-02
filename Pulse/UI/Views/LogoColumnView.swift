//
//  LogoColumnView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 18.02.24.
//

import UIKit
import PulseUIComponents

final class LogoRowView: UIView {
    fileprivate enum Row: CaseIterable {
        case first
        case second
        case third
        case fourth
        case fifth
        case sixth
        case seventh
        
        var color: UIColor? {
            return switch self {
                case .first:
                    UIColor(hex: "#FF4770")
                case .second:
                    UIColor(hex: "#FF6AAD")
                case .third:
                    UIColor(hex: "#FBD177")
                case .fourth:
                    UIColor(hex: "#FBCC68")
                case .fifth:
                    UIColor(hex: "#ACDE8E")
                case .sixth:
                    UIColor(hex: "#7FCC56")
                case .seventh:
                    UIColor(hex: "#5ABD26")
            }
        }
    }
    
    fileprivate init(numberOfRow: Row) {
        super.init(frame: .zero)
        self.backgroundColor = numberOfRow.color
        self.layer.cornerRadius = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LogoColumnView: UIView {
    enum Column: CaseIterable {
        case first
        case second
        case third
        
        fileprivate var initialHidden: [Bool] {
            return switch self {
                case .first:
                    [true, true, true, true, false, false, false]
                case .second:
                    [false, false, false, false, false, false, false]
                case .third:
                    [true, true, false, false, false, false, false]
            }
        }
        
        fileprivate var initialDidEndAnimation: Bool {
            return self == .second
        }
    }
    
    fileprivate enum Direction {
        case up
        case down
        
        mutating func toggle() {
            self = self == .up ? .down : .up
        }
    }
    
    private let numberOfColumn: Column
    
    private lazy var rows: [LogoRowView] = {
        var rows = [LogoRowView]()
        LogoRowView.Row.allCases.enumerated().forEach { [weak self] index, row in
            let rowView = LogoRowView(numberOfRow: row)
            rowView.isHidden = self?.numberOfColumn.initialHidden[index] ?? true
            rows.append(rowView)
        }
        
        return rows
    }()
    
    private var timer: Timer?
    private var animationDirection: Direction
    private var didAnimationEnded: Bool
    
    init(numberOfColumn: Column) {
        self.numberOfColumn = numberOfColumn
        self.animationDirection = .up
        self.didAnimationEnded = numberOfColumn.initialDidEndAnimation
        super.init(frame: .zero)
        self.setupInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInterface() {
        self.rows.enumerated().forEach { [weak self] index, rowView in
            guard let self else { return }
            
            self.addSubview(rowView)
            
            rowView.snp.makeConstraints { make in
                make.height.equalTo(10)
                make.width.equalTo(50)
                make.leading.trailing.equalToSuperview()
                if index == 0 {
                    make.top.equalToSuperview()
                } else {
                    make.top.equalTo(self.rows[index - 1].snp.bottom).offset(19)
                }
            }
        }
    }
    
    func animate() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.hideViews()
        })
    }
    
    @objc func hideViews() {
        var indexes = Array(0..<self.rows.count)
        if self.animationDirection == .up {
            indexes = indexes.map({ self.rows.count - 1 - $0 })
        }
        
        print(indexes)
        for index in indexes {
            if self.didAnimationEnded, [0, 6].contains(index) {
                self.animationDirection.toggle()
                self.didAnimationEnded = false
            } else {
                if self.animationDirection == .down {
                    if self.rows[index].isHidden {
                        continue
                    }
                        
                    self.rows[index].isHidden = true
                } else {
                    if !self.rows[index].isHidden {
                        continue
                    }
                    
                    self.rows[index].isHidden = false
                }
                
                self.didAnimationEnded = [0, 6].contains(self.rows.filter({ $0.isHidden }).count)
            }
            
            break
        }
    }
    
    func stopAnimation() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
