//
//  main.swift
//  MyYearWithGit
//
//  Created by 秋星桥 on 2024/12/17.
//

import Foundation

let requiredYear = 2024

setenv("GIT_TERMINAL_PROMPT", "0", 1)
setenv("GIT_LFS_SKIP_SMUDGE", "1", 1)

AuxiliaryExecuteWrapper.setupExecutables()
AuxiliaryExecuteWrapper.setupGitTemplates()

MyYearWithGitApp.main()
