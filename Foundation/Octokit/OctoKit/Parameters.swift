//
// Created by Marcin on 19/05/2017.
// Copyright (c) 2017 nerdish by nature. All rights reserved.
//

import Foundation

public enum SortDirection: String {
    case asc
    case desc
}

public enum SortType: String {
    case created
    case updated
    case popularity
    case longRunning = "long-running"
}
