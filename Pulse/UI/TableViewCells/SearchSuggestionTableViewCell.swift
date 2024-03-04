//
//  SearchSuggestionTableViewCell.swift
//  Pulse
//
//  Created by Bahdan Piatrouski on 24.02.24.
//

import UIKit
import PulseUIComponents

final class SearchSuggestionTableViewCell: BaseUITableViewCell {
    private lazy var searchSuggestionLabel = UILabel()
    
    func setText(_ text: String) {
        self.searchSuggestionLabel.text = text
    }
}

// MARK: - Setup interface methods
extension SearchSuggestionTableViewCell {
    override func setupLayout() {
        self.contentView.addSubview(searchSuggestionLabel)
    }
    
    override func setupConstraints() {
        searchSuggestionLabel.snp.makeConstraints({ $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 16, vertical: 10)) })
    }
}
