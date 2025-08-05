@echo off
echo 🚀 Starting BSWL Backend...

echo.
echo 🔍 Checking if MongoDB is running...
netstat -an | findstr ":27018" >nul
if %errorlevel% equ 0 (
    echo ✅ MongoDB is running on port 27018
) else (
    echo ❌ MongoDB is not running on port 27018
    echo Please start MongoDB first or run start_backend.bat
    pause
    exit /b 1
)

echo.
echo 🌐 Starting Backend Server...
echo Backend will connect to MongoDB on port 27018
echo.

REM Start the backend
npm run dev 