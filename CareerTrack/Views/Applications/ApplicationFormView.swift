import SwiftUI

/// Create (existing == nil) or edit (existing != nil) an application.
struct ApplicationFormView: View {
    let existing: JobApplication?
    var onSave: ((JobApplication) -> Void)?

    @EnvironmentObject private var applications: ApplicationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var companyName = ""
    @State private var position = ""
    @State private var jobType: JobType = .internship
    @State private var status: ApplicationStatus = .applied
    @State private var applicationDate = Date()
    @State private var location = ""
    @State private var jobURL = ""
    @State private var salary = ""
    @State private var notes = ""
    @State private var hasFollowUp = false
    @State private var followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var validationMessage: String?
    @State private var didLoadExisting = false

    init(existing: JobApplication?, onSave: ((JobApplication) -> Void)? = nil) {
        self.existing = existing
        self.onSave = onSave
    }

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Job") {
                    TextField("Company name", text: $companyName)
                    TextField("Position / job title", text: $position)
                    Picker("Job type", selection: $jobType) {
                        ForEach(JobType.allCases) { Text($0.rawValue).tag($0) }
                    }
                    TextField("Location (e.g. Dhaka, Remote)", text: $location)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(ApplicationStatus.allCases) { Text($0.rawValue).tag($0) }
                    }
                    DatePicker("Applied on", selection: $applicationDate, displayedComponents: .date)
                }

                Section("Optional details") {
                    TextField("Job URL", text: $jobURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Salary / compensation", text: $salary)
                }

                Section("Follow-up reminder") {
                    Toggle("Set follow-up date", isOn: $hasFollowUp.animation())
                    if hasFollowUp {
                        DatePicker("Follow up on", selection: $followUpDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        Text("You will get a local notification at this time.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 90)
                }

                if let message = validationMessage {
                    Section {
                        ErrorText(message: message)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Application" : "New Application")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .onAppear(perform: loadExisting)
            .onChange(of: hasFollowUp) { isOn in
                if isOn { NotificationService.shared.requestPermission() }
            }
        }
    }

    private func loadExisting() {
        guard let app = existing, !didLoadExisting else { return }
        didLoadExisting = true
        companyName = app.companyName
        position = app.position
        jobType = app.jobType
        status = app.status
        applicationDate = app.applicationDate
        location = app.location
        jobURL = app.jobURL ?? ""
        salary = app.salary ?? ""
        notes = app.notes
        if let date = app.followUpDate {
            hasFollowUp = true
            followUpDate = date
        }
    }

    private func validate() -> String? {
        if Validation.isBlank(companyName) { return "Company name is required." }
        if Validation.isBlank(position) { return "Position is required." }
        if Validation.isBlank(location) { return "Location is required." }
        if !Validation.isBlank(jobURL) && !Validation.isValidURL(jobURL) { return "Job URL is not valid." }
        if applicationDate > Date() { return "Application date cannot be in the future." }
        return nil
    }

    private func save() {
        if let message = validate() {
            withAnimation { validationMessage = message }
            return
        }

        func clean(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
        func optional(_ text: String) -> String? { clean(text).isEmpty ? nil : clean(text) }

        var app = existing ?? JobApplication(companyName: "", position: "", location: "")
        app.companyName = clean(companyName)
        app.position = clean(position)
        app.jobType = jobType
        app.status = status
        app.applicationDate = applicationDate
        app.location = clean(location)
        app.jobURL = optional(jobURL)
        app.salary = optional(salary)
        app.notes = clean(notes)
        app.followUpDate = hasFollowUp ? followUpDate : nil

        let saved = app
        Task { await applications.save(saved) }
        onSave?(saved)
        dismiss()
    }
}
