# 🗣️ VAANI-BSWL (Bridging Silence With Learning)

A comprehensive **Sign Language Learning Platform** that combines Machine Learning, Mobile App, and Web Services to make sign language education accessible to everyone.

## 🏗️ Project Architecture

```
FINAL_YEAR_PROJECT_BACKUP/
├── 📱 bswl_frontend_app/          # Flutter Mobile Application
├── 🔧 BSWL_BACKEND/               # Node.js REST API Server
├── 🤖 BSWL_ML/                    # Python ML Microservice
├── 🗄️ mongo-data/                 # MongoDB Database
├── 📁 ASSETS/                     # Sign Language Datasets & Videos
├── 🐳 docker-compose.yml          # Multi-service Deployment
└── 📚 Documentation/              # Project Documentation
```

## 🚀 Key Features

### 📱 **Mobile App (Flutter)**
- **Real-time Sign Detection** using device camera
- **Interactive Learning Modules** with video tutorials
- **Progress Tracking** and personalized learning paths
- **Offline Support** for downloaded content
- **Multi-language Support** (English & Hindi)

### 🔧 **Backend API (Node.js)**
- **RESTful API** for user management and content delivery
- **JWT Authentication** with Google Sign-In
- **File Upload/Download** for learning materials
- **Real-time Communication** via WebSocket
- **Rate Limiting** and security features

### 🤖 **ML Service (Python)**
- **Sign Language Recognition** using CNN/LSTM models
- **Real-time Video Processing** with OpenCV
- **Model Training Pipeline** with TensorFlow/PyTorch
- **API Endpoints** for prediction and training
- **GPU Acceleration** support

## 🛠️ Technology Stack

| Component | Technology | Version |
|-----------|------------|---------|
| **Frontend** | Flutter | 3.0+ |
| **Backend** | Node.js | 18+ |
| **ML Service** | Python | 3.9+ |
| **Database** | MongoDB | 6.0+ |
| **Cache** | Redis | 7+ |
| **Reverse Proxy** | Nginx | Latest |
| **Containerization** | Docker | Latest |
| **ML Framework** | TensorFlow/PyTorch | Latest |

## 📦 Installation & Setup

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development)
- Python 3.9+ (for ML development)
- Flutter SDK 3.0+ (for mobile development)

### 🐳 Quick Start with Docker

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd FINAL_YEAR_PROJECT_BACKUP
   ```

2. **Set up environment variables**
   ```bash
   cp BSWL_BACKEND/env.example BSWL_BACKEND/.env
   # Edit .env with your configuration
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Access the services**
   - Backend API: http://localhost:3000
   - ML Service: http://localhost:8000
   - MongoDB: localhost:27017
   - Redis: localhost:6379

### 🔧 Manual Setup

#### Backend Setup
```bash
cd BSWL_BACKEND
npm install
cp env.example .env
# Configure .env file
npm start
```

#### ML Service Setup
```bash
cd BSWL_ML
pip install -r requirements.txt
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

#### Flutter App Setup
```bash
cd bswl_frontend_app
flutter pub get
flutter run
```

## 📊 Dataset Information

The project uses comprehensive sign language datasets:

- **ISL Dataset**: 26,000+ images across 26 alphabets
- **Phrase Dataset**: 40+ common phrases with 40 variations each
- **Video Dataset**: 60+ sign language videos for learning
- **Processed Videos**: 160x160 resolution optimized videos

## 🔐 Security Features

- **JWT Authentication** with refresh tokens
- **Rate Limiting** to prevent abuse
- **CORS Configuration** for secure cross-origin requests
- **Input Validation** and sanitization
- **Environment-based** configuration management

## 📈 Performance Optimizations

- **Redis Caching** for frequently accessed data
- **Image Compression** for faster loading
- **Model Quantization** for mobile inference
- **CDN Integration** for static assets
- **Database Indexing** for faster queries

## 🧪 Testing

```bash
# Backend Tests
cd BSWL_BACKEND
npm test

# ML Service Tests
cd BSWL_ML
python -m pytest tests/

# Flutter Tests
cd bswl_frontend_app
flutter test
```

## 📚 API Documentation

- **Swagger UI**: http://localhost:3000/api-docs
- **Postman Collection**: Available in `BSWL_BACKEND/`
- **WebSocket Events**: Documented in `INTEGRATION_README.md`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Indian Sign Language Dataset** contributors
- **Flutter** and **TensorFlow** communities
- **OpenCV** for computer vision capabilities
- **MongoDB** for database solutions

## 📞 Support

For support and questions:
- 📧 Email: [your-email@domain.com]
- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)
- 📖 Documentation: [Wiki](https://github.com/your-repo/wiki)

---

**Made with ❤️ for the Deaf Community** 