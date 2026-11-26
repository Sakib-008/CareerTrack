import SwiftUI

/// Edits a copy of the profile and saves it through ProfileViewModel.
struct ProfileEditView: View {
    @EnvironmentObject private var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var draft: CareerProfile
    @State private var skillsText: String
    @State private var validationMessage: String?

    init(profile: CareerProfile) {
        _draft = State(initialValue: profile)
        _skillsText = State(initialValue: profile.skills.joined(separator: ", "))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal") {
                    TextField("Full name", text: $draft.fullName)
                    TextField("Email", text: $draft.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Phone number", text: $draft.phone)
                        .keyboardType(.phonePad)
                }

                Section("Education") {
                    TextField("University", text: $draft.university)
                    TextField("Degree / program", text: $draft.degree)
                    TextField("Graduation year (e.g. 2027)", text: $draft.graduationYear)
                        .keyboardType(.numberPad)
                }

                Section {
                    TextField("Swift, SwiftUI, Firebase", text: $skillsText)
                } header: {
                    Text("Skills")
                } footer: {
                    Text("Separate skills with commas.")
                }

                Section("Career summary") {
                    TextEditor(text: $draft.summary).frame(minHeight: 80)
                }

                Section("Work experience") {
                    TextEditor(text: $draft.workExperience).frame(minHeight: 100)
                }

                if let message = validationMessage {
                    Section { ErrorText(message: message) }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if profileVM.isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { Task { await save() } }
                    }
                }
            }
        }
    }

    private func validate() -> String? {
        if Validation.isBlank(draft.fullName) { return "Full name is required." }
        if !Validation.isBlank(draft.email) && !Validation.isValidEmail(draft.email) {
            return "Please enter a valid email."
        }
        if !Validation.isBlank(draft.graduationYear) && !Validation.isValidYear(draft.graduationYear) {
            return "Graduation year must be a 4-digit year."
        }
        return nil
    }

    @MainActor
    private func save() async {
        if let message = validate() {
            withAnimation { validationMessage = message }
            return
        }
        var profile = draft
        profile.fullName = profile.fullName.trimmingCharacters(in: .whitespaces)
        profile.email = profile.email.trimmingCharacters(in: .whitespaces)
        profile.skills = skillsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        if await profileVM.save(profile) {
            dismiss()
        } else {
            validationMessage = profileVM.errorMessage ?? "Could not save the profile."
        }
    }
}
