//
//  Download.swift
//  HalfTunes
//
//  Created by Alaxabo on 4/3/17.
//  Copyright © 2017 Ken Toh. All rights reserved.
//

import Foundation
class Download: NSObject{
    var url: String
    var isDownLoading = false
    var progress: Float = 0.0
    
    var downloadTask: URLSessionDownloadTask?
    var resumeData: NSData?
    
    init (url: String){
        self.url = url
    }
}
