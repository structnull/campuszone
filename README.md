<p align="center">
  <img src="https://github.com/user-attachments/assets/acd1b2ac-7088-4929-afb2-bde16a80e2fe" alt="icon" width="150">
</p>

<h3 align="center">CampusZone</h3>

CampusZone is a comprehensive Flutter mobile application designed to enhance campus life by providing a centralized platform for students to connect, share resources, and stay informed about campus activities.

## Abstract

CampusZone is a mobile application developed using Flutter to provide a centralized platform for students to enhance their campus life. The application offers various features such as user authentication, profile management, community events, notice board, resources section, and a chat system. The primary goal of CampusZone is to facilitate better communication, resource sharing, and engagement among students on campus.

## Problem Statement

In many educational institutions, students face challenges in staying informed about campus activities, connecting with peers, and accessing resources. Traditional methods of communication, such as notice boards and emails, are often inefficient and fail to reach all students. There is a need for a modern, centralized platform that can address these issues and improve the overall campus experience for students.

## Objective

The objective of CampusZone is to create a user-friendly mobile application that addresses the communication and resource-sharing needs of students on campus. The application aims to provide a seamless experience for students to stay informed about campus events, connect with peers, access resources, and engage in meaningful interactions.

## Features

- **User Authentication**
  - Sign up/Login functionality
  - Password recovery
  - Profile creation

- **Profile Management**
  - View and edit profile details
  - Update profile picture with image cropping
  - Account settings

- **Community Section**
  - Campus events listing and details
  - Event registration via external URLs
  - Community announcements

- **Notice Board**
  - Campus-wide announcements and notifications
  - Interactive notices with expandable content
  - Timestamp and categorization

- **Resources Section**
  - Lost and Found system
    - Post lost/found items with images
    - Add descriptions
    - Comment functionality

- **Chat System**
  - Direct messaging between users
  - Message history
  - Real-time updates

## System Model Architecture

The system model architecture of CampusZone is designed to ensure scalability, reliability, and ease of maintenance. The architecture consists of the following components:

1. **Frontend**: The mobile application developed using Flutter, which provides the user interface and handles user interactions.
2. **Backend**: Supabase is used as the backend service, providing authentication, database, and storage functionalities.
3. **Database**: Supabase's PostgreSQL database is used to store user data, events, notices, chat messages, and lost and found items.
4. **Storage**: Supabase's storage service is used to store user profile pictures and images related to lost and found items.
5. **API**: Supabase's RESTful API is used to interact with the database and storage services.

## System Workflow

The system workflow of CampusZone involves the following steps:

1. **User Registration and Authentication**: Users can sign up and log in to the application using their email and password. Supabase handles the authentication process.
2. **Profile Management**: Users can view and edit their profile details, including updating their profile picture. The updated information is stored in the Supabase database.
3. **Community Events**: Users can view a list of upcoming campus events, register for events via external URLs, and view event details. Event data is fetched from the Supabase database.
4. **Notice Board**: Users can view campus-wide announcements and notifications. Notices are categorized and timestamped for easy reference. Notice data is fetched from the Supabase database.
5. **Resources Section**: Users can post lost and found items with images and descriptions. Other users can comment on these posts. Lost and found data is stored in the Supabase database, and images are stored in Supabase storage.
6. **Chat System**: Users can send direct messages to other users, view message history, and receive real-time updates. Chat messages are stored in the Supabase database.

## Screenshots

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="https://github.com/user-attachments/assets/a4ec75fb-01cc-443e-a90c-d06ed4bc2cdf" width="150">
  <img src="https://github.com/user-attachments/assets/7303e637-c207-4543-a016-01c879f7a77d" width="150">
  <img src="https://github.com/user-attachments/assets/e8e514c6-e537-4f60-a047-1698a4727693" width="150">
  <img src="https://github.com/user-attachments/assets/a0a0b57d-1ddc-40a9-a468-7c0e9c882cb5" width="150">
  <img src="https://github.com/user-attachments/assets/f96ff3f8-22e6-4e31-bd69-1ac408c9054a" width="150">
  <img src="https://github.com/user-attachments/assets/d997fae5-676d-409b-9df7-0c726f3a5fdf" width="150">
  <img src="https://github.com/user-attachments/assets/48bc5890-00c0-4a32-8dd2-169a0f08e319" width="150">
  <img src="https://github.com/user-attachments/assets/cf35e964-d149-4212-b5a8-ac241b9559ae" width="150">
  <img src="https://github.com/user-attachments/assets/5caf2c93-6862-4903-a272-4071bfd9874a" width="150">
  <img src="https://github.com/user-attachments/assets/d5246ed5-791a-40b1-8eb1-755927b2a9c3" width="150">
  <img src="https://github.com/user-attachments/assets/f07fbbec-b1f1-455a-a3c0-117f5fc40b68" width="150">
  <img src="https://github.com/user-attachments/assets/33b22395-3729-42bf-bd98-af03c6676d72" width="150">
</div>



## Project Structure

```
campuszone                              # project root
├── analysis_options.yaml
├── assets
│   ├── fonts
│   │   └── Excalifont.ttf
│   └── profile.png
├── lib
│   ├── auth                            # Authentication related screens
│   │   ├── auth.dart
│   │   ├── forgot_pass.dart
│   │   ├── login_page.dart
│   │   ├── name_page.dart
│   │   └── register_page.dart
│   ├── chat                            # Chat functionality
│   │   ├── chat_list.dart
│   │   └── chatmsgpage.dart
│   ├── custom
│   │   └── custom_divider.dart
│   ├── globals.dart                    # Global variables and constants 
│   ├── main.dart
│   ├── pages                           # Main navigation pages including navbar
│   │   ├── navbar.dart
│   │   └── profilelink.dart
│   └── ui                              # UI components organized by feature
│       ├── community                   # Community and events related screens
│       │   ├── community.dart
│       │   └── events
│       │       ├── eventdetails.dart
│       │       └── events.dart
│       ├── home                        # Home screen and notice board
│       │   ├── home.dart
│       │   └── notice_board.dart
│       ├── profile                     # Profile related screens
│       │   ├── about.dart
│       │   ├── editprofile
│       │   │   ├── edit_profile.dart
│       │   │   └── profilepic
│       │   │       ├── fullscreenpicpage.dart
│       │   │       └── profile_picture.dart
│       │   ├── profile.dart
│       │   └── settings.dart
│       └── resources                   # Resources page including lost and found Section
│           ├── lostandfound
│           │   ├── comments
│           │   │   ├── commentitem.dart
│           │   │   └── comments.dart
│           │   ├── fullscreenpicpage.dart
│           │   ├── lost_and_found.dart
│           │   └── upload_data.dart
│           └── resources.dart
├── pubspec.lock
├── pubspec.yaml                        # dependencies and assets 
├── README.md

```

## Setup Instructions

### Prerequisites

- Flutter SDK version 3.6.0 or higher
- Dart SDK
- Android Studio / VS Code with Flutter plugins
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/structnull/campuszone.git
   cd campuszone
   ```

2. **Set up environment variables**
   
   Create a .env file in the root directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Configure Supabase**
   
   Create the following tables in your Supabase instance:
   - users (extends auth.users)
   - notices
   - events
   - Chat messages
   - Lost and found items

5. **Run the application**
   ```bash
   flutter run
   ```

## Dependencies

CampusZone relies on several key packages:

- [supabase_flutter](https://pub.dev/packages/supabase_flutter) - Backend and authentication
- [image_picker](https://pub.dev/packages/image_picker) & [image_cropper](https://pub.dev/packages/image_cropper) - Image handling
- [google_fonts](https://pub.dev/packages/google_fonts) - Typography
- [url_launcher](https://pub.dev/packages/url_launcher) - Open external links
- [permission_handler](https://pub.dev/packages/permission_handler) - Request permissions
- [connectivity_plus](https://pub.dev/packages/connectivity_plus) - Network state management
- [shimmer](https://pub.dev/packages/shimmer) & [flutter_staggered_animations](https://pub.dev/packages/flutter_staggered_animations) - UI effects

For a complete list of dependencies, see the pubspec.yaml file.

## Platform Support

CampusZone is configured for multiple platforms:
- Android
- iOS
- Web
- Linux
- macOS
- Windows

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Custom Fonts
The application uses a custom font called "Excalifont" located in assets/Fonts/Excalifont.ttf.

## Contributions
Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgements

- Johan george , kinnan , nandu for their ideas and support
