@echo off
echo 🚀 Starting BSWL Development Servers...

echo.
echo ✅ MongoDB is already running on ports 27017 and 27018
echo.

echo 📦 Installing dependencies...

echo Installing backend dependencies...
cd BSWL_BACKEND
call npm install
cd ..

echo Installing ML service dependencies...
cd BSWL_ML
call pip install -r requirements.txt
cd ..

echo.
echo 🔧 Creating necessary directories...
if not exist "BSWL_BACKEND\uploads\videos" mkdir "BSWL_BACKEND\uploads\videos"
if not exist "BSWL_ML\models" mkdir "BSWL_ML\models"
if not exist "BSWL_ML\logs" mkdir "BSWL_ML\logs"

echo.
echo 🌐 Starting services...
echo.
echo Starting ML Service on http://localhost:8000
echo Starting Backend Service on http://localhost:3000
echo.
echo Press Ctrl+C to stop all services
echo.

REM Start ML service in background
start "ML Service" cmd /k "cd BSWL_ML && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"

REM Wait a moment for ML service to start
timeout /t 3 /nobreak >nul

REM Start backend service
start "Backend Service" cmd /k "cd BSWL_BACKEND && start_backend.bat"

echo.
echo ✅ Services started!
echo.
echo 📋 Service URLs:
echo    Backend API: http://localhost:3000
echo    ML Service:  http://localhost:8000
echo.
echo 📚 API Documentation:
echo    Backend API Docs: http://localhost:3000/api-docs
echo    ML Service Docs: http://localhost:8000/docs
echo.
echo 🧪 To test the integration, run:
echo    python test_integration.py
echo.

pause 