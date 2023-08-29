//
//  CoversScrollingView.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 29.08.23.
//

import UIKit
import InfiniteScrolling_SPM

class CoversScrollingView: BaseUIView {
    private lazy var coversCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 20
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(ScrollingCoverCollectionViewCell.self)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private var infiniteScrollingBehaviour: InfiniteScrollingBehaviour?
    private var covers = [PulseCover]()
    private var startFrom = 0
    private var timer: Timer?
    
    func setupCovers(covers: [PulseCover], start: Int = 0) {
        self.covers = covers
        self.startFrom = start
        self.infiniteScrollingBehaviour?.reload(with: covers)
        
        self.coversCollectionView.setContentOffset(CGPoint(x: self.coversCollectionView.contentOffset.x + CGFloat(start * 150), y: self.coversCollectionView.contentOffset.y), animated: false)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(newScrolling), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    @objc private func newScrolling() {
        var currentOffset = coversCollectionView.contentOffset
        currentOffset = CGPoint(x: currentOffset.x + 5 * (self.startFrom % 2 == 0 ? 1 : -1), y: currentOffset.y)
        
        coversCollectionView.setContentOffset(currentOffset, animated: true)
        currentOffset = CGPoint(x: 0, y: currentOffset.y)
    }
    
    func removeTimer() {
        timer?.invalidate()
    }
}

// MARK: -
// MARK: Setup interface methods
extension CoversScrollingView {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.infiniteScrollingBehaviour == nil else { return }
        
        let configuration = CollectionViewConfiguration(scrollingDirection: .horizontal, layoutType: .fixedSize(size: 150, lineSpacing: 20))
        self.infiniteScrollingBehaviour = InfiniteScrollingBehaviour(with: self.coversCollectionView, and: covers, delegate: self, collectionConfiguration: configuration)
    }
    
    override func setupLayout() {
        self.addSubview(coversCollectionView)
    }
    
    override func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        self.coversCollectionView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}

extension CoversScrollingView: InfiniteScrollingBehaviourDelegate {
    func configuredCell(forItemAt indexPath: IndexPath, originallyAt index: Int, and data: InfiniteScrollingData, for behaviour: InfiniteScrollingBehaviour) -> UICollectionViewCell {
        let cell = coversCollectionView.dequeueReusableCell(withReuseIdentifier: ScrollingCoverCollectionViewCell.id, for: indexPath)
        guard let scrollingCoverCell = cell as? ScrollingCoverCollectionViewCell,
              let cover = data as? PulseCover
        else { return cell }
        
        scrollingCoverCell.setupImage(link: cover.medium)
        return scrollingCoverCell
    }
}
