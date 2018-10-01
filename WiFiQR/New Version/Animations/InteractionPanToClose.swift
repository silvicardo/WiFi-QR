//
//  InteractionPanToClose.swift
//  DesignCodeApp
//
//  Created by riccardo silvi on 27/07/18.
//  Copyright © 2018 Meng To. All rights reserved.
//

import UIKit


class InteractionPanToClose: UIPercentDrivenInteractiveTransition {

    
    
    @IBOutlet weak var viewController: UIViewController!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dialogView: UIView!
    
    var panGestureRecognizer : UIPanGestureRecognizer!
    
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    //METODI RELATIVI ALLA DIALOG VIEW PER LA SUA APPARIZIONE
    //E SPARIZIONE CON ROTAZIONE
    
    func rotateDialogOut(){
    
        let rotationAngle = CGFloat(Int(arc4random_uniform(60)) - 30) * CGFloat.pi / 180.0
        
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let translationTransform = CGAffineTransform(translationX: 0, y: 300)
        
        dialogView.alpha = 0
        dialogView.transform = rotationTransform.concatenating(translationTransform)
    
    }
    
    func animateDialogAppear() {
        
        rotateDialogOut()
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.9, animations: {
            
            self.dialogView.alpha = 1
            self.dialogView.transform = .identity
            
        })
        animator.startAnimation()
    }
    
    //APPLICAZIONE DEI GESTURE RECOGNIZER AD ELEMENTI DELLA VIEW
    
    func setGestureRecognizer () {
        
        //CON LA PAN GESTURE LA SCROLL è IN GRADO DI CHIUDERSI CON UNA
        //PAN GESTURE(SWIPE NEGATIVO)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handle))
        scrollView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
    
        //ASSEGNANDO UNA TAP GESTURE RECOGNIZER ALLA SCROLL VIEW
        //OGNI VOLTA CHE NON VERRà TOCCATO UN ELEMENTO DELLA UI
        //AL SUO INTERNO SI PROVOCHERA' L'USCITA DAL CONTROLLER
        //CHE DEVE ESSERE UNA MODAL PER IL DISMISS
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(animateDialogDisappearAndDismiss))
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
    }
    
    
    //TAP METHOD
    @objc func animateDialogDisappearAndDismiss (_ gesture : UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, animations: {
            
            self.rotateDialogOut()
            
        }, completion: { finished in
            
            self.viewController.dismiss(animated: true, completion: nil)
            
        })
    }
    
    
    //PAN METHOD
    @objc func handle(_ gesture : UIPanGestureRecognizer) {
        
        guard scrollView.contentOffset.y < 1 else { return }
        
        let threshold : CGFloat = 100
        let translation = gesture.translation(in: viewController?.view)
        
        switch gesture.state {
        case .changed:
            // The animation will update
            if translation.y > 0 {
                let percentComplete = translation.y / 2000
                update(percentComplete)
            }
        case .ended:
            // The animation will finish or cancel
            if translation.y > threshold { finish() }
            else { cancel() }
        default: break
        }
    }
    
    override func update(_ percentComplete: CGFloat) {
        
        visualEffectView.alpha = 1-percentComplete
        
        let translation = panGestureRecognizer.translation(in: viewController.view)
        
        let translationY = CGAffineTransform(translationX: 0, y: translation.y)
        let scale = CGAffineTransform(scaleX: 1-percentComplete, y: 1-percentComplete)
        
        let origin = panGestureRecognizer.location(in: viewController.view)
        
        let frameWidth = viewController.view.frame.width
        let originX = origin.x/frameWidth
        let degrees = 150 - originX * 300
        let rotationAngle = percentComplete * degrees * CGFloat.pi / 180.0
        let rotation = CGAffineTransform(rotationAngle: rotationAngle)
        
        let transform = translationY.concatenating(scale).concatenating(rotation)
        
        dialogView.transform = transform
    }
    
    override func cancel() {
        
        let animator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.6) {
            
            self.visualEffectView.alpha = 1
            self.dialogView.transform = .identity
        }
        animator.startAnimation()
    }
    
    override func finish() {
        
        let animator = UIViewPropertyAnimator(duration: 0.9, dampingRatio: 0.9) {
            
            self.dialogView.frame.origin.y += 200
            self.visualEffectView.effect = nil
            self.viewController.dismiss(animated: true)
        }
        animator.startAnimation()
    }
}
//SUPPORTA MULTIPLI GESTURE CONTEMPORANEAMENTE
//Siccome la scrollView supporta già un tocco integrato per poter
//interagire anche con nostri gestureRecognizer necessità di
//questa funzione
extension InteractionPanToClose : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }


//EVITA CHE OGNI TOCCO CAUSI LA DISMISSAL DELLA VIEW

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        //Solo se il tocco è sul tapGestureRecognizer e allo stesso tempo è all'interno della dialogView
        //lascia la view aperta
        if gestureRecognizer == tapGestureRecognizer && touch.view!.isDescendant(of: dialogView){
        return false
        }
    
        return true
    }
    
    
}


