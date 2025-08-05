# VAANI-BSWL (Bridging Silence With Learning) - Database Design & Data Modeling

## Project Overview
**Project Name:** VAANI-BSWL (Bridging Silence With Learning)  
**Type:** Full-Stack Cross-Platform Sign Language Learning Platform  
**Primary Goal:** Making Indian Sign Language (ISL) learning accessible, interactive, and modern for all ages

## Database Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATABASE ARCHITECTURE                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PRIMARY DATABASE (MongoDB):                                                │
│  ├── User Management Collections                                            │
│  ├── Content Management Collections                                         │
│  ├── Learning Progress Collections                                          │
│  ├── Analytics & Reporting Collections                                      │
│  └── System Configuration Collections                                       │
│                                                                             │
│  EXTERNAL DATABASES:                                                        │
│  ├── Firebase Authentication (User Auth)                                    │
│  ├── Google Cloud Storage (Media Files)                                     │
│  ├── Redis Cache (Session & Temporary Data)                                │
│  └── Analytics Databases (Firebase Analytics, Custom Analytics)            │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Entity-Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ENTITY-RELATIONSHIP DIAGRAM                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │     USERS       │    │   USER_PROFILES │    │    USER_SESSIONS        │  │
│  │                 │    │                 │    │                         │  │
│  │ PK: user_id     │◄──►│ PK: profile_id  │    │ PK: session_id          │  │
│  │ email           │    │ FK: user_id     │    │ FK: user_id             │  │
│  │ password_hash   │    │ name            │    │ token                   │  │
│  │ role            │    │ age             │    │ created_at              │  │
│  │ status          │    │ learning_goals  │    │ expires_at              │  │
│  │ created_at      │    │ preferences     │    │ last_activity           │  │
│  │ updated_at      │    │ avatar_url      │    │ ip_address              │  │
│  └─────────────────┘    │ created_at      │    └─────────────────────────┘  │
│                         │ updated_at      │                                 │
│                         └─────────────────┘                                 │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │   CATEGORIES    │    │     LESSONS     │    │    VIDEO_ASSETS         │  │
│  │                 │    │                 │    │                         │  │
│  │ PK: category_id │◄──►│ PK: lesson_id   │◄──►│ PK: asset_id            │  │
│  │ name            │    │ FK: category_id │    │ FK: lesson_id           │  │
│  │ description     │    │ title           │    │ file_name               │  │
│  │ difficulty      │    │ description     │    │ file_path               │  │
│  │ icon_url        │    │ duration        │    │ file_size               │  │
│  │ order_index     │    │ prerequisites   │    │ mime_type               │  │
│  │ is_active       │    │ difficulty      │    │ cloud_url               │  │
│  │ created_at      │    │ order_index     │    │ thumbnail_url           │  │
│  │ updated_at      │    │ is_active       │    │ created_at              │  │
│  └─────────────────┘    │ created_at      │    │ updated_at              │  │
│                         │ updated_at      │    └─────────────────────────┘  │
│                         └─────────────────┘                                 │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │ USER_PROGRESS   │    │   ACHIEVEMENTS  │    │    LEARNING_SESSIONS    │  │
│  │                 │    │                 │    │                         │  │
│  │ PK: progress_id │    │ PK: achievement │    │ PK: session_id          │  │
│  │ FK: user_id     │    │ _id             │    │ FK: user_id             │  │
│  │ FK: lesson_id   │    │ name            │    │ FK: lesson_id           │  │
│  │ status          │    │ description     │    │ start_time              │  │
│  │ completion_rate │    │ icon_url        │    │ end_time                │  │
│  │ time_spent      │    │ criteria        │    │ duration                │  │
│  │ last_accessed   │    │ points          │    │ progress_percentage     │  │
│  │ created_at      │    │ is_active       │    │ notes                   │  │
│  │ updated_at      │    │ created_at      │    │ created_at              │  │
│  └─────────────────┘    │ updated_at      │    └─────────────────────────┘  │
│                         └─────────────────┘                                 │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │ USER_ACHIEVEMENT│    │   TRANSLATIONS  │    │    SYSTEM_LOGS          │  │
│  │                 │    │                 │    │                         │  │
│  │ PK: id          │    │ PK: translation │    │ PK: log_id              │  │
│  │ FK: user_id     │    │ _id             │    │ FK: user_id             │  │
│  │ FK: achievement │    │ FK: user_id     │    │ level                   │  │
│  │ _id             │    │ input_text      │    │ message                 │  │
│  │ earned_at       │    │ output_text     │    │ context                 │  │
│  │ points_earned   │    │ confidence      │    │ stack_trace             │  │
│  │ created_at      │    │ processing_time │    │ created_at              │  │
│  └─────────────────┘    │ created_at      │    └─────────────────────────┘  │
│                         └─────────────────┘                                 │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────────┐  │
│  │   ANALYTICS     │    │   NOTIFICATIONS │    │    SYSTEM_CONFIG        │  │
│  │                 │    │                 │    │                         │  │
│  │ PK: analytics_id│    │ PK: notification│    │ PK: config_id           │  │
│  │ FK: user_id     │    │ _id             │    │ key                     │  │
│  │ event_type      │    │ FK: user_id     │    │ value                   │  │
│  │ event_data      │    │ type            │    │ description             │  │
│  │ timestamp       │    │ title           │    │ is_active               │  │
│  │ session_id      │    │ message         │    │ created_at              │  │
│  │ created_at      │    │ is_read         │    │ updated_at              │  │
│  └─────────────────┘    │ created_at      │    └─────────────────────────┘  │
│                         └─────────────────┘                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Conceptual Schema Design

### 1. User Management Schema

```javascript
// Users Collection
{
  _id: ObjectId,
  email: String,                    // Unique email address
  password_hash: String,            // Encrypted password
  role: String,                     // "student", "instructor", "admin"
  status: String,                   // "active", "inactive", "suspended"
  firebase_uid: String,             // Firebase Authentication UID
  created_at: Date,
  updated_at: Date,
  last_login: Date
}

// User Profiles Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  name: String,                     // Full name
  age: Number,                      // User age
  learning_goals: [String],         // Array of learning objectives
  preferences: {
    language: String,               // Preferred language
    difficulty: String,             // Preferred difficulty level
    notifications: Boolean,         // Notification preferences
    theme: String                   // UI theme preference
  },
  avatar_url: String,               // Profile picture URL
  bio: String,                      // User biography
  created_at: Date,
  updated_at: Date
}

// User Sessions Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  token: String,                    // JWT token
  device_info: {
    device_type: String,            // "mobile", "tablet", "desktop"
    os: String,                     // Operating system
    browser: String,                // Browser information
    ip_address: String              // IP address
  },
  created_at: Date,
  expires_at: Date,
  last_activity: Date,
  is_active: Boolean
}
```

### 2. Content Management Schema

```javascript
// Categories Collection
{
  _id: ObjectId,
  name: String,                     // Category name (e.g., "Elementary")
  description: String,              // Category description
  difficulty: String,               // "beginner", "intermediate", "advanced"
  icon_url: String,                 // Category icon URL
  order_index: Number,              // Display order
  is_active: Boolean,
  created_at: Date,
  updated_at: Date
}

// Lessons Collection
{
  _id: ObjectId,
  category_id: ObjectId,            // Reference to Categories
  title: String,                    // Lesson title
  description: String,              // Lesson description
  duration: Number,                 // Duration in seconds
  prerequisites: [ObjectId],        // Array of prerequisite lesson IDs
  difficulty: String,               // Lesson difficulty level
  order_index: Number,              // Display order within category
  tags: [String],                   // Search tags
  is_active: Boolean,
  created_at: Date,
  updated_at: Date
}

// Video Assets Collection
{
  _id: ObjectId,
  lesson_id: ObjectId,              // Reference to Lessons
  file_name: String,                // Original file name
  file_path: String,                // Local file path
  file_size: Number,                // File size in bytes
  mime_type: String,                // MIME type
  cloud_url: String,                // Cloud storage URL
  thumbnail_url: String,            // Thumbnail image URL
  duration: Number,                 // Video duration in seconds
  resolution: String,               // Video resolution
  encoding_info: {
    codec: String,
    bitrate: Number,
    fps: Number
  },
  created_at: Date,
  updated_at: Date
}
```

### 3. Learning Progress Schema

```javascript
// User Progress Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  lesson_id: ObjectId,              // Reference to Lessons
  status: String,                   // "not_started", "in_progress", "completed"
  completion_rate: Number,          // Percentage completed (0-100)
  time_spent: Number,               // Total time spent in seconds
  last_accessed: Date,              // Last access timestamp
  progress_data: {
    current_position: Number,       // Current video position
    bookmarks: [Number],            // Bookmarked positions
    notes: String                   // User notes
  },
  created_at: Date,
  updated_at: Date
}

// Learning Sessions Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  lesson_id: ObjectId,              // Reference to Lessons
  start_time: Date,
  end_time: Date,
  duration: Number,                 // Session duration in seconds
  progress_percentage: Number,      // Progress made in session
  interaction_data: {
    play_count: Number,             // Number of times played
    pause_count: Number,            // Number of times paused
    seek_operations: [Number],      // Seek positions
    completion_status: String       // "completed", "partial", "abandoned"
  },
  notes: String,                    // Session notes
  created_at: Date
}

// Achievements Collection
{
  _id: ObjectId,
  name: String,                     // Achievement name
  description: String,              // Achievement description
  icon_url: String,                 // Achievement icon URL
  criteria: {
    type: String,                   // "lessons_completed", "time_spent", "streak"
    value: Number,                  // Required value
    conditions: Object              // Additional conditions
  },
  points: Number,                   // Points awarded
  is_active: Boolean,
  created_at: Date,
  updated_at: Date
}

// User Achievements Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  achievement_id: ObjectId,         // Reference to Achievements
  earned_at: Date,                  // When achievement was earned
  points_earned: Number,            // Points earned
  created_at: Date
}
```

### 4. Analytics & Reporting Schema

```javascript
// Analytics Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  event_type: String,               // "lesson_start", "lesson_complete", "translation"
  event_data: {
    lesson_id: ObjectId,            // Related lesson
    session_id: ObjectId,           // Related session
    duration: Number,               // Event duration
    metadata: Object                // Additional event data
  },
  timestamp: Date,
  session_id: ObjectId,             // Reference to session
  device_info: {
    device_type: String,
    os: String,
    browser: String,
    ip_address: String
  },
  created_at: Date
}

// System Logs Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users (optional)
  level: String,                    // "info", "warning", "error", "debug"
  message: String,                  // Log message
  context: {
    component: String,              // Component name
    action: String,                 // Action performed
    parameters: Object              // Additional context
  },
  stack_trace: String,              // Error stack trace
  created_at: Date
}
```

### 5. Translation & ML Schema

```javascript
// Translations Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  input_text: String,               // Input sign language
  output_text: String,              // Translated text
  confidence: Number,               // Translation confidence (0-1)
  processing_time: Number,          // Processing time in milliseconds
  model_version: String,            // ML model version used
  session_id: ObjectId,             // Related session
  created_at: Date
}

// ML Model Metadata Collection
{
  _id: ObjectId,
  model_name: String,               // Model name
  version: String,                  // Model version
  accuracy: Number,                 // Model accuracy
  performance_metrics: {
    inference_time: Number,         // Average inference time
    memory_usage: Number,           // Memory usage
    gpu_utilization: Number         // GPU utilization
  },
  is_active: Boolean,               // Currently active model
  created_at: Date,
  updated_at: Date
}
```

### 6. System Configuration Schema

```javascript
// System Configuration Collection
{
  _id: ObjectId,
  key: String,                      // Configuration key
  value: Mixed,                     // Configuration value
  description: String,              // Configuration description
  category: String,                 // "security", "performance", "features"
  is_active: Boolean,
  created_at: Date,
  updated_at: Date
}

// Notifications Collection
{
  _id: ObjectId,
  user_id: ObjectId,                // Reference to Users
  type: String,                     // "achievement", "content_update", "system"
  title: String,                    // Notification title
  message: String,                  // Notification message
  is_read: Boolean,                 // Read status
  action_url: String,               // Action URL (optional)
  created_at: Date
}
```

## Database Indexes & Optimization

```javascript
// Primary Indexes
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "firebase_uid": 1 }, { unique: true })
db.user_profiles.createIndex({ "user_id": 1 }, { unique: true })
db.user_sessions.createIndex({ "token": 1 }, { unique: true })
db.user_sessions.createIndex({ "user_id": 1, "is_active": 1 })

// Content Indexes
db.categories.createIndex({ "order_index": 1 })
db.categories.createIndex({ "is_active": 1 })
db.lessons.createIndex({ "category_id": 1, "order_index": 1 })
db.lessons.createIndex({ "difficulty": 1 })
db.lessons.createIndex({ "tags": 1 })
db.video_assets.createIndex({ "lesson_id": 1 })

// Progress Indexes
db.user_progress.createIndex({ "user_id": 1, "lesson_id": 1 }, { unique: true })
db.user_progress.createIndex({ "user_id": 1, "status": 1 })
db.learning_sessions.createIndex({ "user_id": 1, "created_at": -1 })
db.user_achievements.createIndex({ "user_id": 1, "achievement_id": 1 }, { unique: true })

// Analytics Indexes
db.analytics.createIndex({ "user_id": 1, "timestamp": -1 })
db.analytics.createIndex({ "event_type": 1, "timestamp": -1 })
db.system_logs.createIndex({ "level": 1, "created_at": -1 })
db.translations.createIndex({ "user_id": 1, "created_at": -1 })

// Performance Indexes
db.user_sessions.createIndex({ "expires_at": 1 }, { expireAfterSeconds: 0 })
db.notifications.createIndex({ "user_id": 1, "is_read": 1 })
```

## Data Relationships & Constraints

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DATA RELATIONSHIPS & CONSTRAINTS                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ONE-TO-ONE RELATIONSHIPS:                                                  │
│  ├── Users ↔ User Profiles (1:1)                                            │
│  ├── Lessons ↔ Video Assets (1:1)                                           │
│  └── Users ↔ User Sessions (1:Many, but unique per active session)         │
│                                                                             │
│  ONE-TO-MANY RELATIONSHIPS:                                                 │
│  ├── Categories → Lessons (1:Many)                                          │
│  ├── Users → User Progress (1:Many)                                         │
│  ├── Users → Learning Sessions (1:Many)                                     │
│  ├── Users → Analytics (1:Many)                                             │
│  ├── Users → Translations (1:Many)                                          │
│  └── Users ↔ Notifications (1:Many)                                         │
│                                                                             │
│  MANY-TO-MANY RELATIONSHIPS:                                                │
│  ├── Users ↔ Achievements (Many:Many through User_Achievements)            │
│  ├── Lessons ↔ Prerequisites (Many:Many through self-reference)            │
│  └── Users ↔ Lessons (Many:Many through User_Progress)                     │
│                                                                             │
│  DATA INTEGRITY CONSTRAINTS:                                                │
│  ├── Unique Constraints: Email, Firebase UID, User Profile per User        │
│  ├── Foreign Key Constraints: All referenced IDs must exist                 │
│  ├── Check Constraints: Completion rate (0-100), Confidence (0-1)          │
│  └── Not Null Constraints: Essential fields marked as required              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Conclusion

The database design provides a comprehensive data model for the VAANI-BSWL platform, featuring:

1. **Scalable Schema Design**: MongoDB collections optimized for performance and scalability
2. **Comprehensive Data Modeling**: Covers all aspects from user management to analytics
3. **Flexible Document Structure**: JSON-based schema allowing for complex nested data
4. **Performance Optimization**: Strategic indexing for common query patterns
5. **Data Integrity**: Proper relationships and constraints ensuring data consistency
6. **Analytics Ready**: Built-in support for learning analytics and reporting

This documentation serves as a complete reference for understanding the data architecture, relationships, and optimization strategies for the VAANI-BSWL platform. 