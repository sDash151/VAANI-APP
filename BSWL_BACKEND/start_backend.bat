@echo off
echo 🚀 Starting BSWL Backend with MongoDB...

echo.
echo 🔍 Checking if MongoDB is running...
netstat -an | findstr ":27018" >nul
if %errorlevel% equ 0 (
    echo ✅ MongoDB is already running on port 27018
) else (
    echo 📦 Starting MongoDB...
    echo Starting MongoDB on port 27018 with auth enabled...
    echo Database path: E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db
    
    REM Create database directory if it doesn't exist
    if not exist "E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db" (
        mkdir "E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db"
        echo 📁 Created database directory
    )
    
    REM Start MongoDB in background
    start "MongoDB" cmd /k "mongod --port 27018 --auth --dbpath \"E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db\""
    
    echo ⏳ Waiting for MongoDB to start...
    timeout /t 5 /nobreak >nul
    
    REM Check if MongoDB started successfully
    netstat -an | findstr ":27018" >nul
    if %errorlevel% equ 0 (
        echo ✅ MongoDB started successfully on port 27018
    ) else (
        echo ❌ Failed to start MongoDB. Please check if MongoDB is installed.
        echo You can install MongoDB from: https://www.mongodb.com/try/download/community
        pause
        exit /b 1
    )
)

echo.
echo 🌐 Starting Backend Server...
echo Backend will connect to MongoDB on port 27018
echo.

REM Start the backend
npm run dev