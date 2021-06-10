/*
*  © 2017-2020 Aware, Inc.  All Rights Reserved.
*
*  NOTICE:  All information contained herein is, and remains the property of Aware, Inc.
*  and its suppliers, if any.  The intellectual and technical concepts contained herein
*  are proprietary to Aware, Inc. and its suppliers and may be covered by U.S. and
*  Foreign Patents, patents in process, and are protected by trade secret or copyright law.
*  Dissemination of this information or reproduction of this material is strictly forbidden
*  unless prior written permission is obtained from Aware, Inc.
*/

import UIKit

class NFCDocumentFieldTypeCellTableViewCell: UITableViewCell {

    @IBOutlet weak var fieldTypeKeyLabel: UILabel!
    @IBOutlet weak var fieldTypeValueLabel: UILabel!
    
    var indexPath: IndexPath? {
        didSet {
            self.backgroundColor = (indexPath!.row % 2 == 0) ? UIColor.white : UIColor(red: 237/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
