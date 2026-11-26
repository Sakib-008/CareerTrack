# CareerTrack – Job & Internship Application Manager

CareerTrack is an iOS app, written in SwiftUI, that helps students manage job and internship applications. Users can track each application's status, schedule interviews, set follow-up reminders, keep a career profile, practise interview questions and view statistics about their progress.

It is a solo university mini-project: moderate in size, with each feature small enough to explain in a presentation.

---

## Objectives

- Build a working SwiftUI app with real data flow, not a set of static screens.
- Demonstrate SwiftUI state management (`@State`, `@Binding`, `@ObservedObject`, `@StateObject`, `@EnvironmentObject`).
- Use `NavigationStack`, `NavigationLink`, `navigationDestination` and `NavigationPath`.
- Use Firebase Authentication and Cloud Firestore for per-user cloud data.
- Parse a bundled JSON file with `Codable` / `JSONDecoder`.
- Stay compatible with **Xcode 14.0 / Swift 5.7 / iOS 16**.

## Features

| Area | What it does |
|---|---|
| **Authentication** | Email/password register, login and logout (Firebase Auth). Validates empty fields and email format, shows friendly errors, and shows a loading spinner while signing in. |
| **Dashboard** | Welcome message, counts (total / applied / interviews / accepted), upcoming interviews, follow-ups, recent activity and a quick "Add New Application" button. All numbers are calculated from stored data. |
| **Applications** | Create, edit, delete and view applications. Search by text, filter by status chips, sort by date, colored status badges, swipe to delete with confirmation. |
| **Application details** | All fields, job link, salary, notes, linked interviews, quick status change, and edit/delete actions. |
| **Interviews** | Create, edit and delete interviews linked to an application. Upcoming interviews are sorted by date, and interviews within 48 hours are highlighted as **SOON**. |
| **Reminders** | Follow-up date per application and a reminder per interview, delivered as **local notifications** (permission is requested when you first turn a reminder on). |
| **Career profile** | Name, email, phone, university, degree, graduation year, skills, summary and work experience. Editable and saved. |
| **Interview preparation** | HR, Behavioral, Technical and Internship questions loaded from `interview_questions.json`. Includes tips, key points, sample answers and favorites. |
| **History** | All applications grouped by month. Search by company or position, filter by status, sort newest or oldest. |
| **Analytics** | Count per status, interview conversion rate, acceptance rate, status distribution bars and job-type bars, all drawn with native SwiftUI shapes. |
| **Demo Mode** | Runs with local sample data when Firebase is not configured. |

## Technologies

- Swift 5.7, SwiftUI, iOS 16 deployment target, Xcode 14.0
- Firebase Apple SDK **10.9.0**, added with Swift Package Manager (products `FirebaseAuth` and `FirebaseFirestore`)
- UserNotifications (local notifications)
- Codable / JSONDecoder / JSONSerialization
- No other third-party libraries

> **Why Firebase 10.9.0?** Firebase **10.10.0** was the first release to require Xcode 14.1, and later releases require even newer Xcode versions. Version 10.9.0 uses `swift-tools-version:5.6`, which Xcode 14.0 can resolve. The version is pinned as an **exact version** in the project file, so Xcode will not upgrade it on its own.

## Screens

1. Login / Register (with the Demo Mode button)
2. Dashboard → Analytics, History, application details
3. Applications list → Application details → Edit / Schedule interview
4. Interviews (Upcoming · Past · Follow-ups) → Interview form
5. Preparation → Category → Question details (favorites)
6. Profile → Edit profile, History, Analytics, Log out

## Folder structure

```
CareerTrack/
├── CareerTrack.xcodeproj
├── CareerTrack/
│   ├── App/            CareerTrackApp, AppRootView, MainTabView
│   ├── Models/         JobApplication, Interview, CareerProfile, InterviewQuestion, UserSession
│   ├── ViewModels/     Auth, Application, Interview, Profile, Preparation
│   ├── Services/       FirebaseService, AuthService, FirestoreService, LocalDataService,
│   │                   QuestionBankService, NotificationService
│   ├── Utilities/      Theme, Validation, DateFormatting, AppRoute
│   ├── Views/
│   │   ├── Authentication/  LoginView, RegisterView
│   │   ├── Dashboard/       DashboardView
│   │   ├── Applications/    ApplicationListView, ApplicationFormView,
│   │   │                    ApplicationDetailView, ApplicationHistoryView
│   │   ├── Interviews/      InterviewListView, InterviewFormView
│   │   ├── Profile/         ProfileView, ProfileEditView
│   │   ├── Preparation/     InterviewPreparationView, QuestionListView, QuestionDetailView
│   │   ├── Analytics/       AnalyticsView
│   │   └── Components/      StatCard, StatusBadge, ApplicationCard, InterviewCard, SectionHeader,
│   │                        EmptyStateView, PrimaryButton, StatusFilterBar, DemoModeBanner, DetailRow
│   └── Resources/      interview_questions.json, Assets.xcassets
├── Firebase/           firestore.rules, GoogleService-Info_PLACEHOLDER.md
├── README.md  SETUP_GUIDE.md  PROJECT_OVERVIEW.md
└── .gitignore
```

## Swift / SwiftUI concepts demonstrated

| Concept | Where |
|---|---|
| `@State` | Form fields, filters, sheet flags (e.g. `ApplicationFormView`, `ApplicationListView`) |
| `@Binding` | `StatusFilterBar(selection:)`, `AuthTextField(text:)`, `DashboardView(selectedTab:)` |
| `@StateObject` | `CareerTrackApp` creates and owns all view models |
| `@EnvironmentObject` + `.environmentObject()` | View models are injected once in `CareerTrackApp` and read by every screen |
| `@ObservedObject` | `QuestionDetailView` receives `PreparationViewModel` as a parameter |
| `ObservableObject` / `@Published` | All 5 view models |
| `NavigationStack`, `NavigationLink(value:)`, `navigationDestination` | Every tab; `AppRoute` + `.withAppRoutes()` |
| `NavigationPath` | `DashboardView`: after Quick Add saves, the new application's details are pushed in code |
| `TabView` | `MainTabView` (5 tabs) |
| `sheet`, `alert`, `confirmationDialog`, `toolbar`, `searchable`, `swipeActions` | Lists and forms |
| `onAppear`, `onDisappear`, `task(id:)`, `onChange` | Data loading, animations, permission requests |
| Animation | Filter chips, analytics bars and rings, revealing the sample answer |
| `async/await` | Firebase calls in the services and view models |
| `Codable`, `JSONDecoder` | Question bank and Firestore conversion |

## Firebase configuration (short version)

Create a Firebase project, enable **Email/Password** sign-in, create a **Firestore** database, publish `Firebase/firestore.rules`, and add `GoogleService-Info.plist` to the app. Full steps are in **SETUP_GUIDE.md**.

Data is stored per user:

```
users/{uid}/applications/{applicationId}
users/{uid}/interviews/{interviewId}
users/{uid}/profile/main
```

## JSON parsing

`Resources/interview_questions.json` has a nested structure:

```json
{ "version": 1,
  "categories": [
    { "id": "hr", "name": "HR Questions", "icon": "...", "description": "...",
      "tips": ["..."],
      "questions": [ { "id": "hr-1", "question": "...", "difficulty": "Easy",
                       "tip": "...", "sampleAnswer": "...", "keyPoints": ["..."] } ] } ] }
```

`QuestionBankService` finds the file in the bundle, reads it into `Data` and decodes it with `JSONDecoder` into `QuestionBank → [QuestionCategory] → [InterviewQuestion]`. A missing file or invalid JSON (missing key, wrong type, corrupted data) becomes a readable `QuestionBankError`, which the Preparation tab shows with a **Try Again** button.

## How to run

1. Open `CareerTrack.xcodeproj` in Xcode 14.0.
2. Wait for Swift Package Manager to download Firebase 10.9.0. This needs internet and takes a few minutes the first time.
3. Choose an iPhone simulator (for example, iPhone 14) and press **⌘R**.
4. Without `GoogleService-Info.plist`, tap **Explore Demo Mode**. With it, register a new account.

## Demo Mode

- Start it with the **Explore Demo Mode** button on the login screen.
- Loads 6 sample applications, 3 interviews and a sample profile.
- Every screen works, including create, edit, delete, search, analytics and preparation.
- An orange banner shows that **data is local only**. Nothing is sent to Firebase, and the data resets when you exit Demo Mode or restart the app.
