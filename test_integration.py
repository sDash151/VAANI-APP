#!/usr/bin/env python3
"""
BSWL ML Service Integration Test Script
This script tests the integration between backend and ML service
"""

import requests
import json
import time
import sys
from pathlib import Path

class IntegrationTester:
    def __init__(self):
        self.backend_url = "http://localhost:3000"
        self.ml_service_url = "http://localhost:8000"
        self.test_results = []

    def log_test(self, test_name, success, message=""):
        """Log test results"""
        status = "✅ PASS" if success else "❌ FAIL"
        print(f"{status} {test_name}: {message}")
        self.test_results.append({
            "test": test_name,
            "success": success,
            "message": message
        })

    def test_backend_health(self):
        """Test backend health endpoint"""
        try:
            response = requests.get(f"{self.backend_url}/api/v1/health", timeout=5)
            if response.status_code == 200:
                self.log_test("Backend Health Check", True, "Backend is healthy")
                return True
            else:
                self.log_test("Backend Health Check", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Backend Health Check", False, f"Error: {str(e)}")
            return False

    def test_ml_service_health(self):
        """Test ML service health endpoint"""
        try:
            response = requests.get(f"{self.ml_service_url}/health", timeout=5)
            if response.status_code == 200:
                self.log_test("ML Service Health Check", True, "ML service is healthy")
                return True
            else:
                self.log_test("ML Service Health Check", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("ML Service Health Check", False, f"Error: {str(e)}")
            return False

    def test_ml_integration_health(self):
        """Test ML integration health endpoint"""
        try:
            response = requests.get(f"{self.backend_url}/api/v1/ml/health", timeout=5)
            if response.status_code == 200:
                data = response.json()
                if data.get("success") and data.get("data", {}).get("ml_service_healthy"):
                    self.log_test("ML Integration Health Check", True, "ML integration is working")
                    return True
                else:
                    self.log_test("ML Integration Health Check", False, "ML service not healthy")
                    return False
            else:
                self.log_test("ML Integration Health Check", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("ML Integration Health Check", False, f"Error: {str(e)}")
            return False

    def test_ml_service_status(self):
        """Test ML service status endpoint"""
        try:
            response = requests.get(f"{self.ml_service_url}/status", timeout=5)
            if response.status_code == 200:
                data = response.json()
                self.log_test("ML Service Status", True, f"Service: {data.get('service', 'Unknown')}")
                return True
            else:
                self.log_test("ML Service Status", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("ML Service Status", False, f"Error: {str(e)}")
            return False

    def test_backend_ml_status(self):
        """Test backend ML status endpoint"""
        try:
            response = requests.get(f"{self.backend_url}/api/v1/ml/status", timeout=5)
            if response.status_code == 200:
                data = response.json()
                if data.get("success"):
                    self.log_test("Backend ML Status", True, "Backend can communicate with ML service")
                    return True
                else:
                    self.log_test("Backend ML Status", False, "Backend cannot communicate with ML service")
                    return False
            else:
                self.log_test("Backend ML Status", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Backend ML Status", False, f"Error: {str(e)}")
            return False

    def test_nginx_proxy(self):
        """Test nginx reverse proxy"""
        try:
            response = requests.get("http://localhost/health", timeout=5)
            if response.status_code == 200:
                self.log_test("Nginx Proxy", True, "Nginx proxy is working")
                return True
            else:
                self.log_test("Nginx Proxy", False, f"Status code: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("Nginx Proxy", False, f"Error: {str(e)}")
            return False

    def test_docker_services(self):
        """Test if Docker services are running"""
        try:
            import subprocess
            result = subprocess.run(
                ["docker-compose", "ps", "--format", "json"],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                services = result.stdout.strip().split('\n')
                running_services = []
                
                for service in services:
                    if service:
                        service_data = json.loads(service)
                        if service_data.get("State") == "running":
                            running_services.append(service_data.get("Service", "Unknown"))
                
                if len(running_services) >= 3:  # At least backend, ml-service, and mongo
                    self.log_test("Docker Services", True, f"Running: {', '.join(running_services)}")
                    return True
                else:
                    self.log_test("Docker Services", False, f"Only {len(running_services)} services running")
                    return False
            else:
                self.log_test("Docker Services", False, "Docker Compose command failed")
                return False
        except Exception as e:
            self.log_test("Docker Services", False, f"Error: {str(e)}")
            return False

    def run_all_tests(self):
        """Run all integration tests"""
        print("🧪 Starting BSWL Integration Tests...")
        print("=" * 50)
        
        # Test Docker services first
        self.test_docker_services()
        
        # Wait a bit for services to be ready
        time.sleep(2)
        
        # Test individual services
        self.test_backend_health()
        self.test_ml_service_health()
        self.test_ml_service_status()
        
        # Test integration
        self.test_ml_integration_health()
        self.test_backend_ml_status()
        
        # Test proxy
        self.test_nginx_proxy()
        
        # Print summary
        print("=" * 50)
        self.print_summary()

    def print_summary(self):
        """Print test summary"""
        total_tests = len(self.test_results)
        passed_tests = sum(1 for result in self.test_results if result["success"])
        failed_tests = total_tests - passed_tests
        
        print(f"\n📊 Test Summary:")
        print(f"   Total Tests: {total_tests}")
        print(f"   Passed: {passed_tests}")
        print(f"   Failed: {failed_tests}")
        
        if failed_tests > 0:
            print(f"\n❌ Failed Tests:")
            for result in self.test_results:
                if not result["success"]:
                    print(f"   - {result['test']}: {result['message']}")
        
        if passed_tests == total_tests:
            print(f"\n🎉 All tests passed! Your ML integration is working correctly.")
        else:
            print(f"\n⚠️  Some tests failed. Please check the service logs and configuration.")
        
        return passed_tests == total_tests

def main():
    """Main function"""
    tester = IntegrationTester()
    
    try:
        success = tester.run_all_tests()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⏹️  Tests interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n💥 Unexpected error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 