//
//  DataPrefetch.swift
//  Prefetch
//
//  Created by Maple on 2019/7/5.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit



public protocol DataPrefetch where Self: UIScrollView {
    typealias PrefetchCallBack = () -> Void
    
    /// 滑到 未展示行  开始预加载
    var remainRows: Int { set get }
    /// 是否 开启 预加载 default: 不支持
    var isPrefetch: Bool { set get }
    /// 偏移量
    var contentOffsetObserver: NSKeyValueObservation? { set get }
    /// 加载更多
    var prefetchBlock: PrefetchCallBack? { set get }
    /// 是否在加载中
    var isPrefetchLoading: Bool { set get }
    /// 加载完毕
    var endPrefetchLoading: Bool { set get }
    
    func configRemain(_ maxY: CGFloat)
}

private var isPrefetchKey = "isPrefetchKey"
private var endPrefetchLoadingKey = "endPrefetchLoadingKey"
private var contentOffsetObserverKey = "contentOffsetObserverKey"
private var remainRowsKey = "remainRowsKey"
private var prefetchTotalRowsKey = "prefetchTotalRowsKey"
private var isPrefecthLoadingKey = "isPrefecthLoadingKey"
private var prefetchBlockKey = "prefetchBlockKey"
private var isPrefectchingKey = "isPrefecchingKey"

extension DataPrefetch {
    
    public var isPrefetch: Bool {
        set {
            if newValue {
                if contentOffsetObserver == nil {
                    contentOffsetObserver = observe(\.contentOffset, changeHandler: { [weak self] (observing, _) in
                        guard let weakSelf = self else { return }
                        let contentOffsetMaxY = observing.contentOffset.y + observing.bounds.height
                        weakSelf.configRemain(contentOffsetMaxY)
                    })
                }
            } else {
                contentOffsetObserver?.invalidate()
            }
            objc_setAssociatedObject(self, &isPrefetchKey,
                                     newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &isPrefetchKey) as? Bool ?? false
        }
    }
    
    public var endPrefetchLoading: Bool {
        set {
            objc_setAssociatedObject(self, &endPrefetchLoadingKey,
                                     newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &endPrefetchLoadingKey) as? Bool ?? true
        }
    }
    
    public var contentOffsetObserver: NSKeyValueObservation? {
        set {
            objc_setAssociatedObject(self, &contentOffsetObserverKey,
                                     newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &contentOffsetObserverKey) as? NSKeyValueObservation
        }
    }
    public var remainRows: Int {
        set {
            objc_setAssociatedObject(self, &remainRowsKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &remainRowsKey) as? Int ?? 0
        }
    }
    
    public var prefetchBlock: (() -> Void)? {
        set {
            objc_setAssociatedObject(self, &prefetchBlockKey,
                                     newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &prefetchBlockKey) as? PrefetchCallBack
        }
    }
    
    public var isPrefetchLoading: Bool {
        set {
            objc_setAssociatedObject(self, &isPrefecthLoadingKey,
                                     newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &isPrefecthLoadingKey) as? Bool ?? true
        }
    }
}

extension UITableView: DataPrefetch {
    public func configRemain(_ maxY: CGFloat) {
        guard
            !isPrefetchLoading,     // 加载中...  禁止再 预加载
            !endPrefetchLoading,     // 加载完毕
            totalRows != 0,  // 无数据 不执行预加载
            let indexPath = indexPathForRow(at: CGPoint(x: 0, y: maxY))   // 不在列表中 不加载
            else { return }
        let rowIndex = totalRowIndex(at: indexPath)
        guard
            totalRows - rowIndex <= remainRows   // 未 显示数量 大于 预加载 阈值
            else { return }
        prefetchBlock?()
    }
}


extension UITableView {
    /// 总行数
    var totalRows: Int {
        var total: Int = 0
        (0..<numberOfSections).forEach { (section) in
            total += numberOfRows(inSection: section)
        }
        return total
    }
    
    func totalRowIndex(at indexPath: IndexPath) -> Int {
        guard indexPath.section <= numberOfSections else { return totalRows }
        var index: Int = 0
        (0..<indexPath.section).forEach { (section) in
            let rows = numberOfRows(inSection: section)
            if indexPath.section == section,
                indexPath.row < rows {
                index += indexPath.row
            } else {
                index += rows
            }
        }
        return index
    }
}

