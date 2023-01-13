//
//  TestBtn.swift
//  testapihr
//
//  Created by Tek on 2023/1/8.
//

import UIKit

class TestBtn: UIButton {
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? UIColor.systemBlue : UIColor.lightGray
        }
    }
    var tapAction:((UIButton)->())?
    init(frame: CGRect, title: String, action: @escaping ((UIButton)->())) {
        super.init(frame: frame)
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .systemBlue
        self.tapAction = action
        self.addTarget(self, action: #selector(tapBtn), for: .touchUpInside)
    }
    @objc func tapBtn(){
        tapAction?(self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
