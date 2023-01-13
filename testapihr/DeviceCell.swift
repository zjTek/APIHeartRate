//
//  DeviceCell.swift
//  testapihr
//
//  Created by Tek on 2023/1/12.
//

import UIKit

class DeviceCell: UITableViewCell {
    
    var txtLbl:UILabel = UILabel()
    var detailLbl: UILabel = UILabel()
    var subDetailLbl: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        let cntView = UIView()
        cntView.backgroundColor = .white
        cntView.layer.cornerRadius = 10
        addSubview(cntView)
        cntView.snp.makeConstraints { make in
            make.margins.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        }
        txtLbl.font = UIFont.systemFont(ofSize: 20)
        detailLbl.font = UIFont.systemFont(ofSize: 14)
        subDetailLbl.font = UIFont.systemFont(ofSize: 14)
        detailLbl.textColor = .gray
        subDetailLbl.textColor = .gray
    
        cntView.addSubview(txtLbl)
        cntView.addSubview(detailLbl)
        cntView.addSubview(subDetailLbl)
        
        txtLbl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        detailLbl.snp.makeConstraints { make in
            make.top.equalTo(txtLbl.snp.bottomMargin)
            make.left.equalTo(txtLbl)
            make.right.equalTo(txtLbl)
            make.height.equalTo(30)
        }
        
        subDetailLbl.snp.makeConstraints { make in
            make.top.equalTo(detailLbl.snp.bottomMargin)
            make.left.equalTo(detailLbl)
            make.right.equalTo(detailLbl)
            make.height.equalTo(30)
        }
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
