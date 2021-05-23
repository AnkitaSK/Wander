//
//  UITableViewExtension.swift
//  Wander
//
//  Created by Ankita on 23.05.21.
//


extension UITableView {
    func register<T>(_ type: T.Type) where T: UITableViewCell {
        register(type, forCellReuseIdentifier: String(describing: type))
    }
}
