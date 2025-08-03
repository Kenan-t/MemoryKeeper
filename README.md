# MemoryKeeper ---
A cross-platform Flutter app designed to help individuals with Alzheimer's preserve important life moments and stay connected to loved ones. Users can add people, record memories, tag individuals, attach images, and view relationships. Includes full CRUD functionality and image support.

# Demo

Below you can explore the app in two ways:

- Watch a short demo video showcasing the app’s features:  
  [Watch the demo](https://drive.google.com/file/d/1RYglfXINdpDYyMgC_S1dz_KvJWP2q5jE/view?usp=sharing)

- Try the app live on the web:  
  [Open Web Version](https://kenan-t.github.io/MemoryKeeper/)

Note: This app was designed for mobile and fully supports image uploads on Android/iOS. On web, images may not persist after reload due to browser limitations and the current implementation.


# Features

- Add, view, edit, and delete memories
- Attach images and dates to each memory
- Tag one or more people to each memory
- Create, view, edit, and delete people profiles
- Associate notes and relationship info with each person
- Filter and view all memories linked to a specific person
- Image support from both camera and gallery

# Code Structure ---

The core application logic and UI are implemented in: lib/main.dart:
This single file contains all the screens, models, and helper methods for managing both people and memories. The structure follows a simple and readable pattern, reusing widgets across the app for maintainability.

# CRUD Functionality

The app implements full CRUD (Create, Read, Update, Delete) functionality for both people and memories.

# Tech Stack

- **Flutter** for cross-platform UI
- **Dart** as the programming language
- **Provider** for state management
- **Image Picker** for camera/gallery image input

# Getting Started

To run this project locally:

1. Clone the repository  
2. Run `flutter pub get`  
3. Launch using `flutter run`  

# Status

This project is actively maintained and open to further feature development, including future support for cloud storage and search capabilities.
