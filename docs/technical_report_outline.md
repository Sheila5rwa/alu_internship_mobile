# Technical Report Outline

## 1. Introduction
- Problem statement: ALU students need internship experience while student-led startups need support.
- Proposed solution: ALU Internship Hub as a mobile bridge between both groups.

## 2. System Architecture
- Flutter front end
- Firebase Authentication
- Cloud Firestore database
- BLoC state management

## 3. Firebase Backend Structure
- users collection
- startups collection
- opportunities collection
- applications collection

## 4. Core Workflows
- Sign up and sign in
- Complete profile
- Create startup profile
- Post opportunity
- Discover and apply for opportunities
- Track applications

## 5. UI/UX and Design Decisions
- Clean onboarding and simple flows
- Search-first discovery for students
- Dashboard-first experience for founders

## 6. Scalability and Maintainability
- Modular folders for models, screens, cubits, and services
- Firestore collections designed around role-based access
- Reusable state and services

## 7. Challenges and Lessons Learned
- Managing authentication state across screens
- Structuring Firestore collections for real-time updates
- Balancing simplicity with realistic startup workflows

## 8. Future Improvements
- Notifications and chat
- Startup verification workflow
- Recommendation engine
- Analytics and dashboards
