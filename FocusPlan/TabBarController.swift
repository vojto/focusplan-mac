//
//  TabBarController.swift
//  FocusPlan
//
//  Created by Vojtech Rinik on 5/11/17.
//  Copyright © 2017 Median. All rights reserved.
//

import Cocoa
import Cartography
import ReactiveSwift

enum TabBarItem {
    case plan
    case projects
    
    var image: NSImage {
        switch self {
        case .plan:
            return #imageLiteral(resourceName: "PlanIcon")
        case .projects:
            return #imageLiteral(resourceName: "ProjectsIcon")
        }
    }
    
    var label: String {
        switch self {
        case .plan:
            return "Plan"
        case .projects:
            return "Projects"
        }
    }
}

class TabBarController: NSViewController {
    
    @IBOutlet weak var stackView: NSStackView!
    
    var views = [TabBarItemView]()
    
    let selectedIndex = MutableProperty<Int>(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items: [TabBarItem] = [.plan, .projects]
        
        let views = items.map { item -> NSView in
            let view = createView()
            
            constrain(view) { view in
                view.height == 64
            }
            
            view.item = item
            
            view.button.target = self
            view.button.action = #selector(selectTab(sender:))
            
            self.views.append(view)
 
            return view
        }
        
        let spacer = NSView()
        spacer.setContentHuggingPriority(100, for: .vertical)
        
        stackView.setViews(views + [spacer], in: .center)

        selectedIndex.producer.startWithValues { index in
            if let view = self.views.at(index) {
                self.select(view: view)
            }
        }
    }
    
    func createView() -> TabBarItemView {
        var objects: NSArray? = NSMutableArray()
        
        let nib = NSNib(nibNamed: "TabBarItemView", bundle: nil)!
        nib.instantiate(withOwner: self, topLevelObjects: &objects)
        
        return objects!.filter({ $0 is TabBarItemView }).first as! TabBarItemView
    }
    
    func selectTab(sender: Any) {
        if let view = (sender as? NSButton)?.superview as? TabBarItemView,
            let index = views.index(of: view) {
            
            selectedIndex.value = index
        }
    }
    
    func select(view: TabBarItemView) {
        for view in views {
            view.isActive = false
        }
        
        view.isActive = true
    }
    
}
