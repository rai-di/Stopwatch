//
//  ViewController.swift
//  Stopwatch
//
//  Created by DiRai on 11/09/20.
//  Copyright © 2020 DiRai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK:- IBOutlet
    @IBOutlet weak var mainTimerLabel: UILabel!
    @IBOutlet weak var lapTimerLabel: UILabel!
    @IBOutlet weak var lapButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK:- Variables
    var isTimerRunning = false
    var isTimerStarted = false
    
    var mainTimer : Timer?
    var lapTimer : Timer?
    
    var mainTimerCounter = 0
    var lapTimerCounter = 0
    
    var lapArray = [Lap]()
    
    var minIndex = 0
    var maxIndex = 0
    var isMinAndMaxIndexAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lapButton.layer.cornerRadius = lapButton.frame.height / 2
        setup()
        tableView.dataSource = self
    }

    // MARK:- IBAction
    
    @IBAction func lapButtonPressed(_ sender: UIButton) {
        if isTimerRunning{
            addLap()
        }else{
            resetTimer()
        }
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        checkTimerStatus()
    }
    
    // MARK:- Helper Functions
    
    func setup(){
        lapButton.isEnabled = false
    }
    
    func checkTimerStatus(){
        if !isTimerStarted{
            startTimer()
            lapButton.isEnabled = true
            startButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
            startButton.tintColor = .red
            isTimerStarted = true
            isTimerRunning = true
        }else{
            if isTimerRunning{
                stopTimer()
                startButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                startButton.tintColor = .green
                lapButton.setTitle("Reset", for: .normal)
            }else{
                startTimer()
                startButton.setBackgroundImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
                startButton.tintColor = .red
                lapButton.setTitle("Lap", for: .normal)
            }
            isTimerRunning = !isTimerRunning
        }
    }
    
    func startTimer(){
        if mainTimer == nil{
            mainTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateMainTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(mainTimer!, forMode: .common)
        }
        
        if lapTimer == nil{
            lapTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateLapTimer), userInfo: nil, repeats: true)
            RunLoop.main.add(lapTimer!, forMode: .common )
        }
    }
    
    func resetTimer(){
        
        mainTimerCounter = 0
        lapTimerCounter = 0
        
        isTimerRunning = false
        isTimerStarted = false
        
        lapButton.isEnabled = false
        
        startButton.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        startButton.tintColor = .green
        lapButton.setTitle("Lap", for: .normal)
        
        mainTimerLabel.text = "00:00:00"
        lapTimerLabel.text = "00:00:00"
        
        lapArray.removeAll()
        
        isMinAndMaxIndexAvailable = false
        
        minIndex = 0
        maxIndex = 0
        
        tableView.reloadData()
        
    }
    
    func addLap(){
        
        let time = lapTimerCounter
        let title = "Lap " + String( lapArray.count + 1 )
        let lap  = Lap(title: title, time: time)
        lapArray.append(lap)
        
        lapTimerCounter = 0
        lapTimerLabel.text = intToTime(lapTimerCounter)
        
        if lapArray.count > 2{
            checkMinAndMaxIndex()
        }
        
        tableView.reloadData()
    }
    
    func checkMinAndMaxIndex(){
        isMinAndMaxIndexAvailable = true
        var minTime = lapArray[ minIndex ].time
        var maxTime = lapArray[ maxIndex ].time
        
        for( index, value ) in lapArray.enumerated(){
            let time = value.time
            if time > maxTime{
                maxTime = time
                maxIndex = index
            }else if time < minTime{
                minTime = time
                minIndex = index
            }
        }
    }
    
    func  stopTimer(){
        mainTimer!.invalidate()
        mainTimer = nil
        lapTimer!.invalidate()
        lapTimer = nil
    }
    
    func intToTime( _ counter : Int ) -> String{
        let hour = counter / 3600
        let min  = ( counter % 3600 ) / 60
        let sec = ( counter % 3600 ) % 60
        return String( format: "%0.2d:%0.2d:%0.2d", hour,min,sec)
    }
    
    @objc func updateMainTimer(){
        mainTimerCounter = mainTimerCounter + 1
        mainTimerLabel.text = intToTime( mainTimerCounter )
    }
    
    @objc func updateLapTimer(){
        lapTimerCounter = lapTimerCounter + 1
        lapTimerLabel.text = intToTime( lapTimerCounter )
    }
}

extension ViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "lapCell", for: indexPath)
        let index = lapArray.count - ( indexPath.row + 1 )
        
        var textColor = UIColor.black
        
        if isMinAndMaxIndexAvailable{
            if index == minIndex{
                textColor = .green
            }else if index == maxIndex{
                textColor = .red
            }
        }
        
        cell.textLabel?.textColor = textColor
        cell.detailTextLabel?.textColor = textColor
        
        cell.textLabel!.text = lapArray[ index ].title
        cell.detailTextLabel!.text = intToTime( lapArray[ index ].time )
        
        return cell
    }
}

