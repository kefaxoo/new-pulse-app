//
//  StoriesTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 6.01.24.
//

import UIKit
import PulseUIComponents

final class StoriesTableViewCell: BaseUITableViewCell {
    private lazy var storiesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 60, height: 60)
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(horizontal: 16)
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(StoryCollectionViewCell.self)
        return collectionView
    }()
    
    private var stories = [PulseStory]()
    private var completion: ((IndexPath) -> ())?
    
    func configure(withStories stories: [PulseStory], completion: ((IndexPath) -> ())?) {
        self.stories = stories
        self.completion = completion
        self.storiesCollectionView.reloadData()
        self.setupConstraints()
    }
}

// MARK: -
// MARK: Setup interface methods
extension StoriesTableViewCell {
    override func setupInterface() {
        super.setupInterface()
        self.separatorInset = UIEdgeInsets(right: UIScreen.main.bounds.width)
    }
    
    override func setupLayout() {
        self.contentView.addSubview(storiesCollectionView)
    }
    
    override func setupConstraints() {
        storiesCollectionView.snp.removeConstraints()
        
        storiesCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(stories.map({ StoryCollectionViewCell.height(withStory: $0) }).max() ?? 60)
        }
    }
}

// MARK: -
// MARK: UICollectionViewDataSource
extension StoriesTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.id, for: indexPath)
        (cell as? StoryCollectionViewCell)?.configure(withStory: self.stories[indexPath.item], trackCompletion: { [indexPath, weak self] track in
            self?.stories[indexPath.item].trackObj = track
        })
        return cell
    }
}

// MARK: -
// MARK: UICollectionViewDelegateFlowLayout
extension StoriesTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 60, height: StoryCollectionViewCell.height(withStory: self.stories[indexPath.item]))
    }
}

// MARK: -
// MARK: UICollectionViewDelegate
extension StoriesTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let track = self.stories[indexPath.item].trackObj else { return }
        
        MainCoordinator.shared.presentStoryTrackController(track: track, story: self.stories[indexPath.item], completion: { [weak self, indexPath] in
            self?.completion?(indexPath)
        })
    }
}

@available(iOS 17.0, *)
#Preview {
    return StoriesTableViewCell()
}
