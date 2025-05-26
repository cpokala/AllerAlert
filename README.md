# AllerAlert 🫁📱  
_A Mobile Health App for Proactive Asthma Management_

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/github/license/cpokala/AllerAlert)](LICENSE)

## 🌟 Overview

**AllerAlert** is a mobile health (mHealth) application built to empower asthma patients with real-time insights into their environment and health. Unlike traditional asthma apps that focus solely on symptom tracking or air quality, AllerAlert connects **real-time environmental monitoring** with **intelligent symptom tracking**, offering users personalized, data-driven insights to manage their condition proactively.

## 🚀 Features

### 🌬️ Real-Time Environmental Monitoring
- Connects to **Atmotube PRO** via Bluetooth Low Energy (BLE)
- Continuously tracks:
  - VOCs (Volatile Organic Compounds)
  - PM1, PM2.5, PM10 (Particulate Matter)
  - Temperature
  - Humidity
  - Atmospheric Pressure

### 🗣️ Voice-Enabled Symptom Tracking
- Users log symptoms using **voice input**
- NLP-powered **Named Entity Recognition (Huggingface NER)** auto-extracts:
  - Symptoms
  - Triggers
  - Medications

### 📊 Advanced Data Analysis
- Implements **DBSCAN Clustering** in Dart
- Identifies:
  - Environmental risk zones
  - Trigger patterns
  - Anomalies in air quality

### 🌦️ Weather Forecast Integration
- Uses **Tomorrow.io Weather API** for hyper-local forecasts
- Helps correlate weather conditions with symptom severity

### 🔐 Secure Authentication and Data Storage
- **Firebase Authentication** (Google Sign-in)
- **Firestore** for encrypted data storage
- No PHI stored outside Firebase

### 🧠 Personalized Insights
- Interactive symptom diary
- Trend visualizations and environmental history
- Trigger pattern detection

## 🧰 Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI |
| **Firebase Auth** | User authentication |
| **Cloud Firestore** | Secure, real-time cloud database |
| **flutter_blue_plus** | BLE communication with Atmotube |
| **Tomorrow.io API** | Weather forecasting |
| **Huggingface Transformers** | NLP-based symptom extraction |
| **DBSCAN (Dart)** | Clustering & pattern detection |

## 📱 Screenshots

| Home Dashboard | Air Quality Monitor | Symptom Diary |
|----------------|---------------------|----------------|
| ![Home](screenshots/home.png) | ![Air](screenshots/air_quality.png) | ![Diary](screenshots/diary.png) |

## 🔧 Setup Instructions

1. **Clone the repo**  
```bash
git clone https://github.com/cpokala/AllerAlert.git
cd AllerAlert
