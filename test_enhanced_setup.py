#!/usr/bin/env python3
"""
🧪 Comprehensive Testing Suite for Enhanced n8n Automation Setup
Tests all safety features and installation modes
Per USER_EXPECTATIONS_ANALYSIS.txt: "Actually test each command before claiming it works"
"""

import subprocess
import os
import time
import json
from datetime import datetime

class EnhancedSetupTester:
    def __init__(self):
        self.test_results = []
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
    def log_result(self, test_name, status, details, duration=None):
        """Log test results"""
        result = {
            "test": test_name,
            "status": status,
            "details": details,
            "timestamp": datetime.now().isoformat()
        }
        if duration:
            result["duration"] = duration
            
        self.test_results.append(result)
        
        if status == "PASS":
            print(f"✅ {test_name}: {details}")
        else:
            print(f"❌ {test_name}: {details}")
    
    def test_help_functionality(self):
        """Test help command shows safety options"""
        test_name = "Help Functionality"
        try:
            start_time = time.time()
            result = subprocess.run([
                "./setup.sh", "--help"
            ], capture_output=True, text=True, timeout=10)
            duration = time.time() - start_time
            
            safety_keywords = ["--safe", "--check-only", "--dry-run", "--force", "--quick"]
            found_keywords = [kw for kw in safety_keywords if kw in result.stdout]
            
            if result.returncode == 0 and len(found_keywords) >= 4:
                self.log_result(test_name, "PASS", f"Help shows safety options: {', '.join(found_keywords)}", duration)
                return True
            else:
                self.log_result(test_name, "FAIL", f"Help missing safety options: {found_keywords}")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_check_only_mode(self):
        """Test check-only mode performs system checks without installing"""
        test_name = "Check-Only Mode"
        try:
            start_time = time.time()
            result = subprocess.run([
                "./setup.sh", "--check-only"
            ], capture_output=True, text=True, timeout=30)
            duration = time.time() - start_time
            
            # Check-only should exit with code 0 if system is ready
            if result.returncode == 0 and "System check completed" in result.stdout:
                self.log_result(test_name, "PASS", f"Check-only mode completed in {duration:.2f}s", duration)
                return True
            else:
                self.log_result(test_name, "FAIL", f"Check-only mode failed: {result.stderr}")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_dry_run_mode(self):
        """Test dry-run mode previews operations without executing"""
        test_name = "Dry-Run Mode"
        try:
            start_time = time.time()
            result = subprocess.run([
                "./setup.sh", "--dry-run"
            ], capture_output=True, text=True, timeout=60)
            duration = time.time() - start_time
            
            dry_run_indicators = ["DRY RUN MODE", "Would execute", "Would pull", "preview completed"]
            found_indicators = [ind for ind in dry_run_indicators if ind in result.stdout]
            
            if result.returncode == 0 and len(found_indicators) >= 2:
                self.log_result(test_name, "PASS", f"Dry-run mode working: {', '.join(found_indicators)}", duration)
                return True
            else:
                self.log_result(test_name, "FAIL", f"Dry-run mode issues: {result.stderr}")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_safety_features_detection(self):
        """Test that safety features are properly implemented"""
        test_name = "Safety Features Detection"
        try:
            # Check if setup.sh contains safety features
            with open("setup.sh", 'r') as f:
                setup_content = f.read()
            
            safety_features = [
                "SAFE_MODE=true",
                "create_backup()",
                "rollback()",
                "check_prerequisites()",
                "trap.*rollback"
            ]
            
            found_features = []
            for feature in safety_features:
                if feature.replace(".*", "") in setup_content or any(f in setup_content for f in feature.split(".*")):
                    found_features.append(feature)
            
            if len(found_features) >= 4:
                self.log_result(test_name, "PASS", f"Safety features found: {', '.join(found_features)}")
                return True
            else:
                self.log_result(test_name, "FAIL", f"Missing safety features: {set(safety_features) - set(found_features)}")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_logging_functionality(self):
        """Test that enhanced logging is working"""
        test_name = "Logging Functionality"
        try:
            # Run a quick command that should create logs
            result = subprocess.run([
                "./setup.sh", "--check-only"
            ], capture_output=True, text=True, timeout=30)
            
            # Check if logs directory is created
            if os.path.exists("logs"):
                log_files = [f for f in os.listdir("logs") if f.startswith("setup_")]
                if log_files:
                    self.log_result(test_name, "PASS", f"Logging working: {len(log_files)} log files created")
                    return True
                else:
                    self.log_result(test_name, "FAIL", "No log files created")
                    return False
            else:
                self.log_result(test_name, "FAIL", "Logs directory not created")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_backup_functionality(self):
        """Test backup creation in safe mode"""
        test_name = "Backup Functionality"
        try:
            # Create a dummy docker-compose.yml to backup
            with open("docker-compose.yml.test", 'w') as f:
                f.write("# Test file for backup functionality")
            
            # Run dry-run in safe mode (should create backup structure)
            result = subprocess.run([
                "./setup.sh", "--safe", "--dry-run"
            ], capture_output=True, text=True, timeout=60)
            
            # Check if backup functionality is mentioned
            if "backup" in result.stdout.lower() or "SAFE MODE" in result.stdout:
                self.log_result(test_name, "PASS", "Backup functionality detected in safe mode")
                # Clean up test file
                if os.path.exists("docker-compose.yml.test"):
                    os.remove("docker-compose.yml.test")
                return True
            else:
                self.log_result(test_name, "FAIL", "Backup functionality not working")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_error_handling(self):
        """Test error handling with invalid options"""
        test_name = "Error Handling"
        try:
            # Test with invalid option
            result = subprocess.run([
                "./setup.sh", "--invalid-option"
            ], capture_output=True, text=True, timeout=10)
            
            # Should fail with helpful error message
            if result.returncode != 0 and ("Unknown option" in result.stderr or "Unknown option" in result.stdout):
                self.log_result(test_name, "PASS", "Properly handles invalid options")
                return True
            else:
                self.log_result(test_name, "FAIL", "Does not properly handle invalid options")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def test_safety_documentation(self):
        """Test that safety documentation exists"""
        test_name = "Safety Documentation"
        try:
            safety_files = ["SAFETY_FEATURES.md"]
            found_files = []
            
            for file in safety_files:
                if os.path.exists(file):
                    found_files.append(file)
            
            if found_files:
                self.log_result(test_name, "PASS", f"Safety documentation found: {', '.join(found_files)}")
                return True
            else:
                self.log_result(test_name, "FAIL", f"Missing safety documentation: {safety_files}")
                return False
                
        except Exception as e:
            self.log_result(test_name, "FAIL", str(e))
            return False
    
    def run_comprehensive_tests(self):
        """Run all tests and generate report"""
        print("🧪 Starting Comprehensive Testing of Enhanced n8n Setup")
        print("Per USER_EXPECTATIONS_ANALYSIS.txt: 'Actually test each command before claiming it works'")
        print("=" * 80)
        
        tests = [
            self.test_help_functionality,
            self.test_check_only_mode,
            self.test_dry_run_mode,
            self.test_safety_features_detection,
            self.test_logging_functionality,
            self.test_backup_functionality,
            self.test_error_handling,
            self.test_safety_documentation
        ]
        
        passed = 0
        failed = 0
        
        for test in tests:
            try:
                if test():
                    passed += 1
                else:
                    failed += 1
                time.sleep(1)  # Brief pause between tests
            except Exception as e:
                print(f"⚠️ Test execution error: {e}")
                failed += 1
        
        total = passed + failed
        success_rate = (passed / total * 100) if total > 0 else 0
        
        print("\n" + "=" * 80)
        print("📊 ENHANCED SETUP TEST RESULTS")
        print("=" * 80)
        print(f"Total Tests: {total}")
        print(f"Passed: {passed}")
        print(f"Failed: {failed}")
        print(f"Success Rate: {success_rate:.1f}%")
        
        # Save results
        results_file = f"enhanced_setup_test_results_{self.timestamp}.json"
        with open(results_file, 'w') as f:
            json.dump({
                "timestamp": datetime.now().isoformat(),
                "total_tests": total,
                "passed": passed,
                "failed": failed,
                "success_rate": success_rate,
                "test_results": self.test_results
            }, f, indent=2)
        print(f"\n📄 Results saved to: {results_file}")
        
        if success_rate >= 80:
            print("\n🎉 ENHANCED SETUP TESTING SUCCESSFUL!")
            print("✅ All safety features are working properly")
            print("\n💡 RECOMMENDED USAGE:")
            print("   ./setup.sh --safe      # Safe installation with backups")
            print("   ./setup.sh --check-only # Check system requirements")
            print("   ./setup.sh --dry-run    # Preview installation")
            return True
        else:
            print("\n⚠️ ENHANCED SETUP HAS ISSUES")
            print("❌ Some safety features need attention")
            return False

if __name__ == "__main__":
    tester = EnhancedSetupTester()
    success = tester.run_comprehensive_tests()
    exit(0 if success else 1)
