//
//  Cache.swift
//  
//
//  Created by v.khorkov on 29.01.2021.
//

import Foundation
import ArgumentParser
import Files
import ShellOut
import Rainbow

private extension String {
    static let buildTarget = "RemotePods"
}

struct Cache: ParsableCommand {
    @Flag(name: .long, help: "Print more information.") var verbose = false
    @Flag(name: .long, help: "Ignore already cached pods.") var rebuild = false
    static var configuration: CommandConfiguration = .init(
        abstract: "Remove remote pods, build them and integrate as frameworks."
    )

    func run() throws {
        let logFile = try Folder.current.createFile(at: .log)
        let buildTarget: String = .buildTarget

        let totalTime = try measure {
            let prepareStep = PrepareStep(logFile: logFile, verbose: verbose)
            let input = try prepareStep.run(buildTarget: buildTarget, needRebuild: rebuild)

            let buildStep = BuildStep(logFile: logFile, verbose: verbose)
            try buildStep.run(scheme: input.buildPods.isEmpty ? nil : buildTarget, checksums: input.checksums)

            let integrateStep = IntegrateStep(logFile: logFile, verbose: verbose)
            try integrateStep.run(remotePods: input.remotePods)

            let cleanupStep = CleanupStep(logFile: logFile, verbose: verbose)
            try cleanupStep.run(buildPods: input.buildPods, buildTarget: buildTarget, remotePods: input.remotePods)
        }
        print("[\(totalTime.formatTime())] ".yellow + "Let's roll 🏈 ".green)
        try shellOut(to: "tput bel")
    }
}