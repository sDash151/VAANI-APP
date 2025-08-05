#!/usr/bin/env python3
"""
BSWL ML Service Integration Test Script (Development Mode)
This script tests the integration between backend and ML service without Docker
"""

import requests
import json
import time
import sys

class DevIntegrationTester:
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

    def test_mongodb_connection(self):
        """Test MongoDB connection through backend"""
        try:
            response = requests.get(f"{self.backend_url}/api/v1/health", timeout=5)
            if response.status_code == 200:
                data = response.json()
                if data.get("success"):
                    self.log_test("MongoDB Connection", True, "Backend connected to MongoDB")
                    return True
                else:
                    self.log_test("MongoDB Connection", False, "Backend health check failed")
                    return False
            else:
                self.log_test("MongoDB Connection", False, f"Backend not responding: {response.status_code}")
                return False
        except Exception as e:
            self.log_test("MongoDB Connection", False, f"Error: {str(e)}")
            return False

    def test_api_documentation(self):
        """Test API documentation endpoints"""
        try:
            # Test backend API docs
            response = requests.get(f"{self.backend_url}/api-docs", timeout=5)
            if response.status_code == 200:
                self.log_test("Backend API Docs", True, "Backend API documentation accessible")
            else:
                self.log_test("Backend API Docs", False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test("Backend API Docs", False, f"Error: {str(e)}")

        try:
            # Test ML service docs
            response = requests.get(f"{self.ml_service_url}/docs", timeout=5)
            if response.status_code == 200:
                self.log_test("ML Service Docs", True, "ML service documentation accessible")
            else:
                self.log_test("ML Service Docs", False, f"Status code: {response.status_code}")
        except Exception as e:
            self.log_test("ML Service Docs", False, f"Error: {str(e)}")

    def run_all_tests(self):
        """Run all integration tests"""
        print("🧪 Starting BSWL Development Integration Tests...")
        print("=" * 60)
        
        # Wait a bit for services to be ready
        print("⏳ Waiting for services to be ready...")
        time.sleep(3)
        
        # Test individual services
        self.test_backend_health()
        self.test_ml_service_health()
        self.test_ml_service_status()
        
        # Test database connection
        self.test_mongodb_connection()
        
        # Test integration
        self.test_ml_integration_health()
        self.test_backend_ml_status()
        
        # Test documentation
        self.test_api_documentation()
        
        # Print summary
        print("=" * 60)
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
            print(f"\n⚠️  Some tests failed. Please check:")
            print(f"   1. Are both services running?")
            print(f"   2. Check the service logs")
            print(f"   3. Verify model files are in place")
        
        return passed_tests == total_tests

def main():
    """Main function"""
    tester = DevIntegrationTester()
    
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