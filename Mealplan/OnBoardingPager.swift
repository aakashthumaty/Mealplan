//
//  OnBoardingPager.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/24/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import PopupDialog

class OnBoardingPager: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
 
        
        if viewController.isKind(of:StepFour.self) {
            // 2 -> 1
            return getStepOne()
        } else
        
            if viewController.isKind(of:StepThree.self) {
            // 2 -> 1
            return getStepOne()
        } else
        
                if viewController.isKind(of:StepTwo.self) {
            // 2 -> 1
            return getStepOne()
                    
        } else if viewController.isKind(of:StepOne.self) {
            // 1 -> 0
            return getStepZero()
                    
        } else {
            // 0 -> end of the road
            return nil
        }
        

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of:StepZero.self) {
            // 0 -> 1
            return getStepOne()
        } else if viewController.isKind(of:StepOne.self) {
            // 1 -> 2
            return getStepTwo()
        } else if viewController.isKind(of:StepTwo.self) {
            // 1 -> 2
            return getStepThree()
        }else if viewController.isKind(of:StepThree.self) {
            // 1 -> 2
            return getStepFour()
        }else {
            // 2 -> end of the road
            return nil
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    
    override func viewDidLoad() {
        setViewControllers([getStepZero()], direction: .forward, animated: false, completion: nil)
        view.backgroundColor = UIColor(red: 90/255, green: 182/255, blue: 221/255, alpha: 1.00)

        dataSource = self
        delegate = self
        
        let title = "WELCOME TO MEALPLAN!"
        let message = "Here's a quick tutorial on what Mealplan's about and how you can get as many free and discounted deals as possible!"
        
        let popup = PopupDialog(title: title, message: message)//, image: image)
        
        let buttonOne = CancelButton(title: "OK") {
            print("You canceled the car dialog.")
        }
        
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return 5
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return 0
//    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 5
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func getStepZero() -> StepZero {
        return storyboard!.instantiateViewController(withIdentifier: "stepzero") as! StepZero
    }
    
    func getStepOne() -> StepOne {
        return storyboard!.instantiateViewController(withIdentifier: "stepone") as! StepOne
    }
    
    func getStepTwo() -> StepTwo {
        return storyboard!.instantiateViewController(withIdentifier: "steptwo") as! StepTwo
    }
    func getStepThree() -> StepThree {
        return storyboard!.instantiateViewController(withIdentifier: "stepthree") as! StepThree
    }
    func getStepFour() -> StepFour {
        return storyboard!.instantiateViewController(withIdentifier: "stepfour") as! StepFour
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
