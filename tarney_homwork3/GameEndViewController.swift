//
//  GameEndViewController.swift
//  tarney_homework3
//
//  Created by Brandon Tarney on 3/17/18.
//  Copyright © 2018 Johns Hopkins University. All rights reserved.
//

import UIKit

class GameEndViewController: UIViewController {

    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var finalScore:Int!
    var gameStatus:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gameStatusLabel.text = self.gameStatus
        self.scoreLabel.text = String(self.finalScore)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAgain(_ sender: Any) {
        _ = self.dismiss(animated: true, completion: nil)
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
