# Where to put GoogleService-Info.plist

This project does **not** include a real Firebase configuration file (it contains your project's API keys and is ignored by `.gitignore`).

1. Download `GoogleService-Info.plist` from the Firebase console
   (Project settings → Your apps → iOS app with bundle ID `com.student.CareerTrack`).
2. In Xcode, drag the file into the **`CareerTrack/CareerTrack/`** group (next to the `App` folder).
3. In the dialog, tick **Copy items if needed** and make sure the **CareerTrack** target is checked.
4. Build and run. The login screen should no longer show "Firebase is not configured".

Expected location on disk:

```
CareerTrack/
└── CareerTrack/
    ├── App/
    ├── ...
    └── GoogleService-Info.plist   ← here
```

If the file is missing, the app still runs: it shows a notice on the login screen and you can use **Demo Mode**.

> Because the file is ignored by Git, every machine (e.g. the university lab Mac) needs its own copy. Keep it out of public repositories.
