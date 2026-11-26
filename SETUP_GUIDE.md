# CareerTrack – Setup Guide (Xcode 14.0)

## 1. Open the project in Xcode 14.0

1. Clone or pull the repository onto the Mac.
2. Double-click `CareerTrack/CareerTrack.xcodeproj` (or use Xcode → *File → Open…*).
3. Xcode starts **resolving packages** right away (see the progress in the left navigator under *Package Dependencies*). This step needs internet access to github.com.
4. If the project shows signing errors, select the **CareerTrack** target → *Signing & Capabilities* → pick your **Team** (a free Personal Team works for the simulator). You can also change the bundle identifier, but then use the new one in Firebase too.

## 2. Create a Firebase project

1. Go to <https://console.firebase.google.com> → **Add project** → name it `CareerTrack` (Google Analytics is optional).
2. Click the **iOS+** icon to add an Apple app.
3. **Bundle ID:** `com.student.CareerTrack`. It must match Xcode's *Bundle Identifier* exactly.
4. Click **Register app**.

## 3. Enable Firebase Authentication

1. Firebase console → **Build → Authentication → Get started**.
2. **Sign-in method** tab → **Email/Password** → enable the first switch → **Save**.

## 4. Create the Firestore database

1. **Build → Firestore Database → Create database**.
2. Choose a location near you (for example, `asia-south1`).
3. Start in **production mode**. The rules from step 7 will give each user access to their own data.

## 5. Add GoogleService-Info.plist

1. In the "Add Firebase to your Apple app" flow (or *Project settings → Your apps*), download **GoogleService-Info.plist**.
2. Drag it into Xcode onto the yellow **CareerTrack** group (the folder that contains `App`, `Models`…).
3. Tick **Copy items if needed** and **Add to targets: CareerTrack**.
4. Skip the "Add Firebase SDK" and "Add initialization code" steps of the Firebase wizard, because the project already does both.

> The file is in `.gitignore`. On a new machine (for example, the lab Mac), add it again after cloning. If it is missing, the app still runs and offers Demo Mode.

## 6. Firebase dependencies (already configured)

The project already references the Firebase package. Nothing needs to be added by hand:

| Setting | Value |
|---|---|
| Package URL | `https://github.com/firebase/firebase-ios-sdk` |
| Dependency rule | **Exact Version 10.9.0** |
| Products linked | `FirebaseAuth`, `FirebaseFirestore` |
| Linker flag | `-ObjC` (recommended by Firebase) |

**Do not** update the package to the latest version: Firebase 10.10.0 and later need Xcode 14.1 or newer and will fail with Xcode 14.0.

To check: select the project → **Package Dependencies** tab → `firebase-ios-sdk` should show *Exact 10.9.0*.

If you ever need to add it again by hand: *File → Add Packages…* → paste the URL above → *Dependency Rule: Exact Version* → `10.9.0` → choose **FirebaseAuth** and **FirebaseFirestore** for the CareerTrack target.

## 7. Set the Firestore security rules

1. Firebase console → **Firestore Database → Rules**.
2. Replace the contents with the text of `Firebase/firestore.rules` from this repository.
3. Click **Publish**.

These rules allow a signed-in user to read and write only `users/{their uid}/…`. All other access is denied.

## 8. Choose a simulator

Use the device menu at the top of Xcode and pick an **iOS 16** iPhone simulator, for example **iPhone 14**. The app is designed for iPhone portrait.

## 9. Run the app

1. Press **⌘R** (Product → Run).
2. **With Firebase:** tap *Register*, create an account (password ≥ 6 characters), then add applications. Check the Firestore console to see `users/{uid}/applications`.
3. **Without Firebase:** tap **Explore Demo Mode**.
4. Reminders: turn on a follow-up or interview reminder and allow notifications when asked. To test quickly, set a reminder 1–2 minutes ahead and lock the simulator with ⌘L.

## 10. Troubleshooting

| Problem | Fix |
|---|---|
| **"Firebase is not configured"** on the login screen | `GoogleService-Info.plist` is missing from the target. Add it again (step 5) and make sure *Target Membership → CareerTrack* is ticked in the File inspector. |
| **Package resolution fails / spins forever** | Check internet access to github.com. Then *File → Packages → Reset Package Caches*, then *Resolve Package Versions*. Lab proxies sometimes block Git; try another network. |
| **"package requires minimum Swift tools version 5.7.1"** or similar | The package was upgraded. Set the dependency rule back to **Exact 10.9.0** (step 6). |
| **"No such module 'FirebaseAuth'"** | Wait for package resolution to finish, then *Product → Clean Build Folder* (⇧⌘K) and build again. |
| **Signing error: "requires a development team"** | Target → *Signing & Capabilities* → choose your Personal Team. |
| **Login error: "Incorrect email or password"** | Register first, or check that Email/Password is enabled (step 3). |
| **Data does not save / "Missing or insufficient permissions"** | Publish the rules from step 7 and make sure Firestore was created. |
| **Bundle ID mismatch warning** | The Bundle ID in Firebase must equal Xcode's Bundle Identifier. Download a new plist after fixing it. |
| **Build is slow the first time** | Firestore includes C++ code (gRPC/abseil). The first build can take several minutes, and later builds are fast. |
| **Notifications do not appear** | Allow them in *Settings → CareerTrack → Notifications* in the simulator, and set the reminder time in the future. |
| **Preview canvas errors** | Previews are optional. Run the app on the simulator instead. |
