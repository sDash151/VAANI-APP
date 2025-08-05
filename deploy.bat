@echo off
echo 🚀 Starting BSWL Deployment...

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo 📁 Creating necessary directories...
if not exist "BSWL_BACKEND\uploads\videos" mkdir "BSWL_BACKEND\uploads\videos"
if not exist "BSWL_ML\models" mkdir "BSWL_ML\models"
if not exist "BSWL_ML\checkpoints" mkdir "BSWL_ML\checkpoints"
if not exist "BSWL_ML\logs" mkdir "BSWL_ML\logs"
if not exist "nginx\ssl" mkdir "nginx\ssl"

echo 🔨 Building and starting services...
docker-compose up --build -d

echo ⏳ Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo 🏥 Checking service health...

REM Check backend health
curl -f http://localhost:3000/api/v1/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Backend service is not responding
) else (
    echo ✅ Backend service is healthy
)

REM Check ML service health
curl -f http://localhost:8000/health >nul 2>&1
if errorlevel 1 (
    echo ❌ ML service is not responding
) else (
    echo ✅ ML service is healthy
)

echo.
echo 🎉 Deployment completed!
echo.
echo 📋 Service URLs:
echo    Backend API: http://localhost:3000
echo    ML Service:  http://localhost:8000
echo    Nginx Proxy: http://localhost:80
echo    MongoDB:     localhost:27017
echo.
echo 📚 API Documentation:
echo    Swagger UI:  http://localhost:3000/api-docs
echo    ML Health:   http://localhost:8000/health
echo.
echo 🔧 Useful commands:
echo    View logs:   docker-compose logs -f
echo    Stop:        docker-compose down
echo    Restart:     docker-compose restart
echo    Update:      docker-compose pull ^&^& docker-compose up -d
echo.

echo 🐳 Running containers:
docker-compose ps

pause 