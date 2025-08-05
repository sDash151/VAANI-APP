Write-Host "🚀 Starting BSWL Backend with MongoDB..." -ForegroundColor Green

Write-Host ""
Write-Host "🔍 Checking if MongoDB is running..." -ForegroundColor Yellow

# Check if MongoDB is running on port 27018
$mongoRunning = Get-NetTCPConnection -LocalPort 27018 -ErrorAction SilentlyContinue

if ($mongoRunning) {
    Write-Host "✅ MongoDB is already running on port 27018" -ForegroundColor Green
} else {
    Write-Host "📦 Starting MongoDB..." -ForegroundColor Yellow
    Write-Host "Starting MongoDB on port 27018 with auth enabled..." -ForegroundColor Cyan
    Write-Host "Database path: E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db" -ForegroundColor Cyan
    
    # Create database directory if it doesn't exist
    $dbPath = "E:\vs code\FINAL YEAR PROJECT\mongo-data\bswl-db"
    if (!(Test-Path $dbPath)) {
        New-Item -ItemType Directory -Path $dbPath -Force | Out-Null
        Write-Host "📁 Created database directory: $dbPath" -ForegroundColor Green
    }
    
    # Start MongoDB in background
    Start-Process -FilePath "mongod" -ArgumentList "--port", "27018", "--auth", "--dbpath", "`"$dbPath`"" -WindowStyle Normal
    
    Write-Host "⏳ Waiting for MongoDB to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Check if MongoDB started successfully
    $mongoRunning = Get-NetTCPConnection -LocalPort 27018 -ErrorAction SilentlyContinue
    if ($mongoRunning) {
        Write-Host "✅ MongoDB started successfully on port 27018" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to start MongoDB. Please check if MongoDB is installed." -ForegroundColor Red
        Write-Host "You can install MongoDB from: https://www.mongodb.com/try/download/community" -ForegroundColor Yellow
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "🌐 Starting Backend Server..." -ForegroundColor Green
Write-Host "Backend will connect to MongoDB on port 27018" -ForegroundColor Cyan
Write-Host ""

# Start the backend
npm run dev 