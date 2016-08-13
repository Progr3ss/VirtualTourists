//
//  perfomUIUpdatesOnMain.swift
//  Virtual Tourist
//
//  Created by martin chibwe on 8/12/16.
//  Copyright © 2016 Martin Chibwe. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(updates: () -> Void) {
	dispatch_async(dispatch_get_main_queue()) {
		updates()
	}
}