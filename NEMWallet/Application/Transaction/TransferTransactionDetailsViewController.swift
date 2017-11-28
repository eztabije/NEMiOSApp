//
//  TransferTransactionDetailsViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2017 NEM
//

import UIKit

///
final class TransferTransactionDetailsViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    public var account: Account?
    public var transferTransaction: TransferTransaction?

    // MARK: - View Controller Outlets
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var transactionDateLabel: UILabel!
    @IBOutlet weak var transactionSignerLabel: UILabel!
    @IBOutlet weak var transactionRecipientLabel: UILabel!
    @IBOutlet weak var transactionAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeLabel: UILabel!
    @IBOutlet weak var transactionAssetsView: UIView!
    @IBOutlet weak var transactionAssetsTableView: UITableView!
    @IBOutlet weak var transactionAssetsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionMessageLabel: UILabel!
    @IBOutlet weak var transactionMessageLabelTopToAmountLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var transactionMessageEncryptedImageView: UIImageView!
    @IBOutlet weak var transactionBlockHeightLabel: UILabel!
    @IBOutlet weak var transactionHashLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateAppearance()
        reloadTransactionDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTransactionDetails), name: Constants.transactionDataChangedNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        transactionAssetsTableViewHeightConstraint.constant = transactionAssetsTableView.contentSize.height
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Reloads all transaction details with the newest data.
    @objc internal func reloadTransactionDetails() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.numberStyle = .currency
        
        if let transferTransaction = transferTransaction {
            switch transferTransaction.type {
            case .transferTransaction:
                
                transactionTypeLabel.text = transferTransaction.transferType == .incoming ? "Incoming Transaction" : "Outgoing Transaction"
                transactionDateLabel.text = transferTransaction.timeStamp.format()
                transactionSignerLabel.text = AccountManager.sharedInstance.generateAddress(forPublicKey: transferTransaction.signer).nemAddressNormalised()
                transactionRecipientLabel.text = transferTransaction.recipient.nemAddressNormalised()
                
                if transferTransaction.transferType == .incoming {
                    transactionAmountLabel.text = "+\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.incomingColor
                } else if transferTransaction.transferType == .outgoing {
                    transactionAmountLabel.text = "-\(transferTransaction.amount.format()) XEM"
                    transactionAmountLabel.textColor = Constants.outgoingColor
                }
                
                if transferTransaction.mosaics?.count != 0 {
                    transactionMessageLabelTopToAmountLabelConstraint.isActive = false
                    transactionAssetsView.isHidden = false
                }
                
                if transferTransaction.message?.type == .encrypted {
                    transactionMessageEncryptedImageView.isHidden = false
                } else {
                    transactionMessageEncryptedImageView.isHidden = true
                }
                
                transactionFeeLabel.text = "\(transferTransaction.fee.format()) XEM"
                transactionMessageLabel.text = transferTransaction.message?.message ?? "-"
                transactionBlockHeightLabel.text = transferTransaction.metaData?.height != nil ? "\(transferTransaction.metaData!.height!)" : "-"
                transactionHashLabel.text = transferTransaction.metaData?.hash != "" ? "\(transferTransaction.metaData?.hash ?? "-")" : "-"
                
            default:
                break
            }
        }
    }
    
    /// Updates the appearance of the view controller.
    private func updateAppearance() {
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }
}

extension TransferTransactionDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table View Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transferTransaction?.mosaics?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let transactionAsset = transferTransaction?.mosaics?[indexPath.row] {
            
            let transactionAssetTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionAssetTableViewCell") as! TransactionAssetTableViewCell
            transactionAssetTableViewCell.transactionAssetNameLabel.text = "\(transactionAsset.namespace!):\(transactionAsset.name!)"
            transactionAssetTableViewCell.transactionAssetAmountLabel.text = "\(transactionAsset.quantity ?? 0)"
            
            return transactionAssetTableViewCell
            
        } else {
            return UITableViewCell()
        }
    }
}
