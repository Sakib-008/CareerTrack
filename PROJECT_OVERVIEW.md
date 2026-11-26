# CareerTrack – Project Overview

## 1. Architecture

CareerTrack uses a simple **MVVM + Services** structure:

```
 Views (SwiftUI)  ──reads @Published──▶  ViewModels (ObservableObject)  ──calls──▶  Services
      ▲                                         │                                   │
      └──────── user actions (save, delete) ────┘                     Firebase / JSON / Notifications
```

- **Models** are plain `Codable` structs with no UI or Firebase code.
- **ViewModels** hold the app state, run CRUD operations and calculate statistics.
- **Services** wrap external systems:
  - `FirebaseService`: configures Firebase only if `GoogleService-Info.plist` exists.
  - `AuthService`: register, login, logout and the auth-state listener.
  - `FirestoreService`: generic fetch, save and delete per user.
  - `LocalDataService`: sample data for Demo Mode.
  - `QuestionBankService`: loads and decodes the question JSON.
  - `NotificationService`: schedules and cancels local notifications.

## 2. Data models

| Model | Key fields |
|---|---|
| `JobApplication` | `id`, `companyName`, `position`, `jobType` (Internship/Full-time/Part-time), `status` (Applied/Shortlisted/Interview/Rejected/Accepted), `applicationDate`, `location`, `jobURL?`, `salary?`, `notes`, `followUpDate?`, `createdAt`, `updatedAt` |
| `Interview` | `id`, `applicationId?`, `company`, `position`, `date` (date **and** time), `locationOrLink`, `type` (Online/On-site/Phone), `preparationNotes`, `reminderDate?`, `createdAt` |
| `CareerProfile` | `fullName`, `email`, `phone`, `university`, `degree`, `graduationYear`, `skills: [String]`, `summary`, `workExperience` |
| `QuestionBank` → `QuestionCategory` → `InterviewQuestion` | Nested JSON model (`tips: [String]`, `questions: [...]`, `keyPoints: [String]`) |
| `UserSession` | `uid`, `email`, `isDemo` |

## 3. Navigation structure

```
AppRootView
├── LoginView (NavigationStack) ──▶ RegisterView
└── MainTabView (TabView)
    ├── Dashboard   NavigationStack(path: NavigationPath)
    │     ├─▶ AppRoute.applicationDetail ─▶ ApplicationDetailView
    │     ├─▶ AppRoute.analytics         ─▶ AnalyticsView
    │     └─▶ AppRoute.history           ─▶ ApplicationHistoryView
    ├── Applications NavigationStack ─▶ ApplicationDetailView (sheet: ApplicationFormView, InterviewFormView)
    ├── Interviews   NavigationStack (sheet: InterviewFormView)
    ├── Preparation  NavigationStack ─▶ QuestionListView ─▶ QuestionDetailView
    └── Profile      NavigationStack (sheet: ProfileEditView) ─▶ History / Analytics
```

- `AppRoute` is a `Hashable` enum. `.withAppRoutes()` registers one `navigationDestination(for: AppRoute.self)` per stack, so each route maps to its screen in one place.
- **NavigationPath example:** in the Dashboard, *Add New Application* opens a sheet. When it closes after saving, `onDismiss` calls `path.append(AppRoute.applicationDetail(id:))`, which opens the new application in code. Tapping an upcoming interview also uses `path.append`.

## 4. State management flow

1. `CareerTrackApp` creates the 5 view models with `@StateObject`, so they live as long as the app.
2. It injects them with `.environmentObject(...)`.
3. Screens read them with `@EnvironmentObject` and react to `@Published` changes.
4. `MainTabView` runs `.task(id: session.uid)` to load data whenever a user signs in.
5. Local screen state (form fields, filters, sheet flags) uses `@State`. Child components receive it with `@Binding`, for example `StatusFilterBar`.
6. `QuestionDetailView` gets the `PreparationViewModel` passed directly and observes it with `@ObservedObject`.

**Saving data:** for example, `ApplicationViewModel.save(_:)`

1. Updates the local `applications` array right away, so the UI changes instantly.
2. Schedules or cancels the follow-up notification.
3. If the user is not in Demo Mode, writes to Firestore. Errors appear in `errorMessage`.

## 5. Firebase data structure

```
users (collection)
└── {uid} (document)
    ├── applications (collection)
    │   └── {applicationId}: { companyName, position, jobType, status, applicationDate, ... }
    ├── interviews (collection)
    │   └── {interviewId}:   { applicationId, company, date, type, reminderDate, ... }
    └── profile (collection)
        └── main:            { fullName, email, skills: [...], ... }
```

- Models are converted with **Codable**: `JSONEncoder` → `JSONSerialization` → `[String: Any]` → `setData`. Reading goes the other way. Dates are stored as numbers (seconds since 1970).
- `firestore.rules` allows access only when `request.auth.uid == userId`.

## 6. JSON parsing flow

```
Bundle.main.url("interview_questions.json")
   └─▶ Data(contentsOf:)
        └─▶ JSONDecoder().decode(QuestionBank.self, from:)
             └─▶ [QuestionCategory] (each with tips: [String] and questions: [InterviewQuestion])
```

Errors are mapped to `QuestionBankError` (file not found, unreadable, invalid format with the failing key or path) and shown on screen with a retry button. Favorites are saved as question IDs in `UserDefaults`.

## 7. Main features and how they work

| Feature | How it works |
|---|---|
| **Auth** | `AuthViewModel` validates input (`Validation`), calls `AuthService` with async/await, and maps Firebase error codes to friendly text. `AppRootView` switches between Login and Main based on `session`. |
| **Missing Firebase file** | `FirebaseService.configureIfPossible()` checks the bundle first, so there is no crash. Login is disabled with a notice, and Demo Mode stays available. |
| **Dashboard statistics** | `ApplicationViewModel.count(for:)` filters the real array, with no hard-coded numbers. |
| **Search / filter / sort** | A single function, `filteredApplications(searchText:field:status:order:)`, is used by both the Applications list and the History screen. |
| **Interviews** | `upcomingInterviews` are sorted ascending. `Interview.isSoon` (< 48 h) adds the orange highlight. Scheduling an interview for an *Applied/Shortlisted* application moves it to *Interview*. |
| **Reminders** | `NotificationService` uses `UNCalendarNotificationTrigger`. IDs are `followup-{id}` and `interview-{id}`, so editing replaces the old reminder and deleting cancels it. |
| **Analytics** | Interview conversion = applications with status Interview/Accepted **or** an interview logged ÷ total. Acceptance rate = Accepted ÷ total. Bars use `GeometryReader` + `Capsule`, and rings use `Circle().trim`. |
| **Demo Mode** | `UserSession.demo` (`isDemo = true`). View models load `LocalDataService` data and skip every Firestore call. |

## 8. Honest notes / limitations

- Interview "date" and "time" are stored together in one `Date` and edited with two `DatePicker`s.
- Firestore writes are optimistic: the screen updates first, and if the cloud write fails, an error message is shown.
- Favorites are stored on the device (UserDefaults), not in Firestore.
- Demo Mode data is in memory only and resets on restart.
- Notifications are local only. No push server is used.
