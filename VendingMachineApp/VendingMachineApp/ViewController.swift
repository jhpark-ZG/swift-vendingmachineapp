//
//  ViewController.swift
//  VendingMachineApp
//
//  Created by kimdo2297 on 2020/03/04.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    private var vendingMachine = VendingMachine()
    private var beverageObserver: NSObjectProtocol?
    private var balanceObsever: NSObjectProtocol?
    
    deinit {
        removeObservers()
    }
    
    private func removeObservers() {
        guard let beverageDidChangeToken = beverageObserver else { return }
        
        NotificationCenter.default.removeObserver(
            beverageDidChangeToken,
            name: VendingMachine.Notification.beveragesDidChange,
            object: vendingMachine
        )
        
        guard let balanceDidChangeToken = balanceObsever else { return }
        
        NotificationCenter.default.removeObserver(
            balanceDidChangeToken,
            name: VendingMachine.Notification.balanceDidChange,
            object: vendingMachine)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        balanceLabel.update(currentMoney: vendingMachine.currentMoney())
        configureObservers()
        confiureBalanceButtons()
    }
    
    private func configureObservers() {
        beverageObserver = NotificationCenter.default.addObserver(
            forName: VendingMachine.Notification.beveragesDidChange,
            object: vendingMachine,
            queue: nil
        ) { [weak self] _ in self?.updateBeverageLabels() }
        
        balanceObsever = NotificationCenter.default.addObserver(
            forName: VendingMachine.Notification.balanceDidChange,
            object: vendingMachine,
            queue: nil
        ) { [weak self] _ in self?.updateBalanceLabel() }
    }
    
    @IBOutlet var beverageNumberLabels: [BeverageLabel]!
    @IBAction func plusBeverageButtonTapped(_ sender: BeverageButton) {
        if let beverage = sender.beverage() {
            vendingMachine.addToStock(beverage: beverage)
        }
    }
    
    private func updateBeverageLabels() {
        let stockByKind = vendingMachine.stockByKind()
        beverageNumberLabels.forEach {
            if let beverage = $0.beverage(),
                let beverageNumber = stockByKind[beverage.kind] {
                $0.update(number: beverageNumber)
            }
        }
    }
    
    @IBOutlet weak var balanceLabel: BalanceLabel!
    @IBOutlet var balanceButtons: [BalanceButton]!
    
    private func confiureBalanceButtons() {
        balanceButtons.forEach { configureBalanceAction($0) }
    }
    
    private func configureBalanceAction(_ balanceButton: BalanceButton) {
        balanceButton.action = { [weak self] money in
            self?.vendingMachine.receive(insertedMoney: money)
        }
    }
    
    private func updateBalanceLabel() {
        let currentMoney = vendingMachine.currentMoney()
        balanceLabel.update(currentMoney: currentMoney)
    }
}
