import UIKit
import Social
import MessageUI

class ExportAccountVC: AbstractViewController , MFMailComposeViewControllerDelegate
{
    @IBOutlet weak var qrImage: UIImageView!
    
    private var popup :AbstractViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.fromVC = SegueToExportAccount
        State.currentVC = SegueToExportAccount
        
        let login = State.currentWallet!.login
        let password = State.currentWallet!.password
        let salt = State.currentWallet!.salt
        let privateKey = HashManager.AES256Decrypt(State.currentWallet!.privateKey)
        let privateKey_AES = HashManager.AES256Encrypt(privateKey, key: "my qr key")
        let objects = [login, password, salt, privateKey_AES]
        let keys = ["login", "password", "salt", "private"]
        
        let jsonAccountDictionary :NSDictionary = NSDictionary(objects: objects, forKeys: keys)
        let jsonDictionary :NSDictionary = NSDictionary(objects: [3, jsonAccountDictionary], forKeys: ["type", "data"])
        let jsonData :NSData = try! NSJSONSerialization.dataWithJSONObject(jsonDictionary, options: NSJSONWritingOptions())
        let base64String :String = jsonData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        
        let qr :QR = QR()
        
        qrImage.image =  qr.createQR(base64String)
    }
    
    @IBAction func backButtonTouchUpInside(sender: AnyObject) {
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(State.lastVC)
        }
    }
    
    @IBAction func shareQR(sender: AnyObject) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let shareVC :ShareViewController =  storyboard.instantiateViewControllerWithIdentifier("SharePopUp") as! ShareViewController
        shareVC.view.frame = CGRect(x: 0, y: 0, width: shareVC.view.frame.width, height: shareVC.view.frame.height)
        shareVC.view.layer.opacity = 0
        shareVC.delegate = self
        
        shareVC.images = [qrImage.image!]
        popup = shareVC
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(shareVC.view)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                shareVC.view.layer.opacity = 1
                }, completion: nil)
        })
    }
}