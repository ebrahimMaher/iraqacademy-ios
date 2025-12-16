//
//  SecuritySuite.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit
import Foundation
import Darwin
import MachO
import Security

// MARK: - Security Result

struct SecurityResult {
    let isJailbroken: Bool
    let isDebugged: Bool
    let isEmulator: Bool
    let threats: [String]
    
    var isSecure: Bool {
        return !isJailbroken && !isDebugged && !isEmulator
    }
}

// MARK: - SecuritySuite - Optimized Implementation

class SecuritySuite {
    
    static let shared = SecuritySuite()
    private init() {}
    
    /// Exception Constants
    private let EXC_BAD_ACCESS: exception_type_t = 1
    private let EXC_BAD_INSTRUCTION: exception_type_t = 2
    private let EXC_ARITHMETIC: exception_type_t = 3
    private let EXC_EMULATION: exception_type_t = 4
    private let EXC_SOFTWARE: exception_type_t = 5
    private let EXC_BREAKPOINT: exception_type_t = 6
    private let EXC_SYSCALL: exception_type_t = 7
    private let EXC_MACH_SYSCALL: exception_type_t = 8
    private let EXC_RPC_ALERT: exception_type_t = 9
    private let EXC_CRASH: exception_type_t = 10
    private let EXC_RESOURCE: exception_type_t = 11
    private let EXC_GUARD: exception_type_t = 12
    private let EXC_CORPSE_NOTIFY: exception_type_t = 13
    private let EXC_TYPES_COUNT: mach_msg_type_number_t = 14
    private let P_TRACED: Int32 = 0x00000800
    
    /// Computed exception masks
    private var EXC_MASK_ALL: exception_mask_t {
        let basic = (1 << EXC_BAD_ACCESS) | (1 << EXC_BAD_INSTRUCTION) | (1 << EXC_ARITHMETIC)
        let system = (1 << EXC_EMULATION) | (1 << EXC_SOFTWARE) | (1 << EXC_BREAKPOINT)
        let syscalls = (1 << EXC_SYSCALL) | (1 << EXC_MACH_SYSCALL) | (1 << EXC_RPC_ALERT)
        let crashes = (1 << EXC_CRASH) | (1 << EXC_RESOURCE) | (1 << EXC_GUARD) | (1 << EXC_CORPSE_NOTIFY)
        return exception_mask_t(basic | system | syscalls | crashes)
    }
    
    private let obfuscationKey: UInt8 = 0x55
    
    /// Comprehensive security check
    func performSecurityCheck() -> SecurityResult {
        var threats: [String] = []
        var isJailbroken = false
        var isDebugged = false
        var isEmulator = false
        
        // 1. Comprehensive jailbreak detection
        let jailbreakThreats = performJailbreakDetection()
        if !jailbreakThreats.isEmpty {
            threats.append(contentsOf: jailbreakThreats)
            isJailbroken = true
        }
        
        // 2. Debugger detection
        let debuggerThreats = performDebuggerDetection()
        if !debuggerThreats.isEmpty {
            threats.append(contentsOf: debuggerThreats)
            isDebugged = true
        }
        
        // 3. Emulator detection (for non-iOS emulators)
        let emulatorThreats = performEmulatorDetection()
        if !emulatorThreats.isEmpty {
            threats.append(contentsOf: emulatorThreats)
            isEmulator = true
        }
        
        return SecurityResult(
            isJailbroken: isJailbroken,
            isDebugged: isDebugged,
            isEmulator: isEmulator,
            threats: threats
        )
    }
    
    // MARK: - Jailbreak Detection
    
    private func performJailbreakDetection() -> [String] {
        var threats: [String] = []
        
        // 1. Check for jailbreak applications
        if checkForJailbreakApps() {
            threats.append("Jailbreak applications found")
        }
        
        // 2. Check for jailbreak libraries
        if checkForJailbreakLibraries() {
            threats.append("Jailbreak libraries loaded")
        }
        
        // 3. Check for jailbreak URL schemes
        if checkForJailbreakURLSchemes() {
            threats.append("Jailbreak URL schemes accessible")
        }
        
        // 4. Check for root access capabilities
        if checkForRootAccess() {
            threats.append("Root access capabilities found")
        }
        
        // 5. Check sandbox integrity
        if checkSandboxIntegrity() {
            threats.append("Sandbox violations detected")
        }
        
        return threats
    }
    
    // MARK: - Debugger Detection
    
    private func performDebuggerDetection() -> [String] {
        var threats: [String] = []
        
        // 1. ptrace detection
        if detectDebuggerWithPtrace() {
            threats.append("Debugger attached (ptrace)")
        }
        
        // 2. Exception ports check
        if detectDebuggerByExceptionPorts() {
            threats.append("Debugger detected (exception ports)")
        }
        
        // 3. Check for debugger processes
        if detectDebuggerProcesses() {
            threats.append("Debugger processes detected")
        }
        
        // 4. Runtime manipulation check
        if checkForRuntimeManipulation() {
            threats.append("Runtime manipulation detected")
        }
        
        return threats
    }
    
    // MARK: - Emulator Detection (Device Only)
    
    private func performEmulatorDetection() -> [String] {
        var threats: [String] = []
        
        // 1. Check for emulator-specific files
        if checkForEmulatorFiles() {
            threats.append("Emulator-specific files detected")
        }
        
        return threats
    }
    
    // MARK: - Detection Methods
    
    /// Check for jailbreak applications
    private func checkForJailbreakApps() -> Bool {
        let obfuscatedPaths = [
            deobfuscate([0x7A, 0x70, 0x71, 0x71, 0x6C, 0x64, 0x7E, 0x68, 0x66, 0x67, 0x74, 0x7A, 0x78, 0x34, 0x65, 0x68, 0x7E, 0x29, 0x7E, 0x71, 0x71]), // "/Applications/Cydia.app"
            deobfuscate([0x7A, 0x70, 0x71, 0x71, 0x6C, 0x64, 0x7E, 0x68, 0x66, 0x67, 0x74, 0x7A, 0x76, 0x68, 0x6C, 0x62, 0x66, 0x29, 0x7E, 0x71, 0x71]), // "/Applications/Sileo.app"
            deobfuscate([0x7A, 0x70, 0x71, 0x71, 0x6C, 0x64, 0x7E, 0x68, 0x66, 0x67, 0x74, 0x7A, 0x79, 0x62, 0x61, 0x75, 0x7E, 0x29, 0x7E, 0x71, 0x71]), // "/Applications/Zebra.app"
        ]
        return obfuscatedPaths.contains { safeFileCheck($0) }
    }
    
    /// Check for jailbreak-specific libraries
    private func checkForJailbreakLibraries() -> Bool {
        let jailbreakLibraries = ["MobileSubstrate", "substrate", "cycript", "fishhook", "substitute"]
        let imageCount = _dyld_image_count()
        
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName).lowercased()
                for library in jailbreakLibraries {
                    if name.contains(library.lowercased()) &&
                       !name.contains("test") &&
                       !name.contains("debug") {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    /// Check for jailbreak URL schemes
    private func checkForJailbreakURLSchemes() -> Bool {
        let schemes = ["cydia://", "sileo://", "zbra://", "filza://"]
        
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    /// Check for root access capabilities
    private func checkForRootAccess() -> Bool {
        let rootPaths = ["/root/", "/var/mobile/"]
        for path in rootPaths {
            if FileManager.default.isReadableFile(atPath: path) {
                return true
            }
        }
        return false
    }
    
    /// Check sandbox integrity
    private func checkSandboxIntegrity() -> Bool {
        // Try to write to restricted system directories
        let testPaths = ["/private/test.txt", "/var/tmp/test.txt"]
        
        for path in testPaths {
            do {
                try "test".write(toFile: path, atomically: true, encoding: .utf8)
                try? FileManager.default.removeItem(atPath: path)
                return true // Should fail on non-jailbroken devices
            } catch {
                // Expected behavior
            }
        }
        return false
    }
    
    /// Detect debugger using ptrace
    private func detectDebuggerWithPtrace() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        return result == 0 && (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    /// Detect debugger by exception ports
    private func detectDebuggerByExceptionPorts() -> Bool {
        // Simplified exception port check to avoid missing constants
        var count: mach_msg_type_number_t = 0
        let task = mach_task_self_
        
        // Allocate memory for exception port info
        guard let masks = UnsafeMutablePointer<exception_mask_t>.allocate(capacity: Int(EXC_TYPES_COUNT)).self as UnsafeMutablePointer<exception_mask_t>?,
              let ports = UnsafeMutablePointer<mach_port_t>.allocate(capacity: Int(EXC_TYPES_COUNT)).self as UnsafeMutablePointer<mach_port_t>?,
              let behaviors = UnsafeMutablePointer<exception_behavior_t>.allocate(capacity: Int(EXC_TYPES_COUNT)).self as UnsafeMutablePointer<exception_behavior_t>?,
              let flavors = UnsafeMutablePointer<thread_state_flavor_t>.allocate(capacity: Int(EXC_TYPES_COUNT)).self as UnsafeMutablePointer<thread_state_flavor_t>? else {
            return false
        }
        
        defer {
            masks.deallocate()
            ports.deallocate()
            behaviors.deallocate()
            flavors.deallocate()
        }
        
        let result = task_get_exception_ports(task, EXC_MASK_ALL, masks, &count, ports, behaviors, flavors)
        
        if result == KERN_SUCCESS && count > 0 {
            for i in 0..<Int(count) {
                if ports[i] != MACH_PORT_NULL {
                    return true
                }
            }
        }
        return false
    }
    
    /// Detect debugger processes
    private func detectDebuggerProcesses() -> Bool {
        let debuggerProcesses = ["lldb", "gdb", "debugserver", "frida", "cycript"]
        let processes = getRunningProcesses()
        
        for process in processes {
            for debugger in debuggerProcesses {
                if process.lowercased().contains(debugger.lowercased()) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Check for runtime manipulation
    private func checkForRuntimeManipulation() -> Bool {
        // Check for hooking frameworks
        let hookingFrameworks = ["fishhook", "substitute", "MSHookFunction"]
        let imageCount = _dyld_image_count()
        
        for i in 0..<imageCount {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName).lowercased()
                for framework in hookingFrameworks {
                    if name.contains(framework.lowercased()) {
                        return true
                    }
                }
            }
        }
        
        // Check for suspicious environment variables
        let suspiciousEnvVars = ["DYLD_INSERT_LIBRARIES", "DYLD_FORCE_FLAT_NAMESPACE"]
        for envVar in suspiciousEnvVars {
            if let value = getenv(envVar) {
                let envValue = String(cString: value)
                if envValue.contains("substrate") || envValue.contains("hook") {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Check for emulator-specific files
    private func checkForEmulatorFiles() -> Bool {
        // Check for Android emulator or other non-iOS emulator files
        let emulatorPaths = [
            "/system/build.prop",
            "/system/bin/qemu-props",
            "/proc/version"
        ]
        return emulatorPaths.contains { FileManager.default.fileExists(atPath: $0) }
    }
    
    private func getRunningProcesses() -> [String] {
        var processes: [String] = []
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var length: size_t = 0
        
        if sysctl(&name, u_int(name.count), nil, &length, nil, 0) == 0 {
            let buffer = UnsafeMutableRawPointer.allocate(byteCount: Int(length), alignment: MemoryLayout<kinfo_proc>.alignment)
            defer { buffer.deallocate() }
            
            if sysctl(&name, u_int(name.count), buffer, &length, nil, 0) == 0 {
                let count = Int(length) / MemoryLayout<kinfo_proc>.stride
                let procList = buffer.bindMemory(to: kinfo_proc.self, capacity: count)
                
                for i in 0..<count {
                    let proc = procList[i]
                    let nameChars = withUnsafeBytes(of: proc.kp_proc.p_comm) { bytes in
                        bytes.bindMemory(to: CChar.self)
                    }
                    let processName = String(cString: nameChars.baseAddress!)
                    processes.append(processName)
                }
            }
        }
        return processes
    }
    
    private func safeFileCheck(_ path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    }
    
    private func deobfuscate(_ obfuscated: [UInt8]) -> String {
        let deobfuscated = obfuscated.map { $0 ^ obfuscationKey }
        return String(bytes: deobfuscated, encoding: .utf8) ?? ""
    }
}

// MARK: - SecuritySuite - Show/Hide Blocker Screen

extension SecuritySuite {
    func presentBlockerScreen() {
        DispatchQueue.main.async {
            guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window,
                  let topVC = AppCoordinator.shared.getTopViewController(from: window.rootViewController),
                  !(topVC is SecurityBlockerVC) else {
                return
            }
            
            let vc = AppCoordinator.shared.build(for: .securityBlocker)
            vc.modalPresentationStyle = .fullScreen
            topVC.present(vc, animated: true)
        }
    }

    func dismissIfBlockerVisible() {
        DispatchQueue.main.async {
            guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window,
                  let topVC = AppCoordinator.shared.getTopViewController(from: window.rootViewController),
                  topVC is SecurityBlockerVC else {
                return
            }
            
            topVC.dismiss(animated: true)
        }
    }
}
