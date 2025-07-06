//
//  ReceivedMessageViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 1/8/25.
//

import UIKit
import Util
import DesignSystem

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

public final class ReceivedMessageViewController: BaseViewController<MessageStorageReactor> {
    
    //MARK: - Properties

    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    //MARK: - Functions
    public override func setupUI() {
        super.setupUI()
        
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        

    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        

    }
    
    static func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    public  override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        

    }
}
