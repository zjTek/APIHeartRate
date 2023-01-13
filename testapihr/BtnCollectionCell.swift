//
//  BtnCollectionCell.swift
//  testapihr
//
//  Created by Tek on 2023/1/8.
//

import UIKit

class BtnCell: UICollectionViewCell {
    private var label:UILabel!
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame:CGRectMake(0, 0, frame.width, frame.height))
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
        self.backgroundColor = .systemBlue
        self.layer.cornerRadius = 10
    }
    func setTxt(txt:String) {
        label.text = txt
    }
}
