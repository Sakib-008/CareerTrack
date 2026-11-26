import SwiftUI

/// Create or edit an interview. It can be linked to an existing application.
struct InterviewFormView: View {
    let existing: Interview?
    let preselectedApplicationId: String?

    @EnvironmentObject private var interviews: InterviewViewModel
    @EnvironmentObject private var applications: ApplicationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var applicationId: String?
    @State private var company = ""
    @State private var position = ""
    @State private var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var type: InterviewType = .online
    @State private var locationOrLink = ""
    @State private var preparationNotes = ""
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var validationMessage: String?
    @State private var showingDeleteAlert = false
    @State private var didLoad = false

    init(existing: Interview?, preselectedApplicationId: String? = nil) {
        self.existing = existing
        self.preselectedApplicationId = preselectedApplicationId
    }

    private var sortedApplications: [JobApplication] {
        applications.applications.sorted { $0.companyName < $1.companyName }
    }

    private var locationPlaceholder: String {
        switch type {
        case .online: return "Meeting link"
        case .phone: return "Phone number"
        case .onSite: return "Address"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Application", selection: $applicationId) {
                        Text("Not linked").tag(String?.none)
                        ForEach(sortedApplications) { app in
                            Text("\(app.companyName) – \(app.position)").tag(String?.some(app.id))
                        }
                    }
                    TextField("Company", text: $company)
                    TextField("Position", text: $position)
                } header: {
                    Text("Application")
                } footer: {
                    Text("Choosing an application fills in the company and position.")
                }

                Section("When & where") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                    Picker("Type", selection: $type) {
                        ForEach(InterviewType.allCases) { Label($0.rawValue, systemImage: $0.iconName).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    TextField(locationPlaceholder, text: $locationOrLink)
                }

                Section("Reminder") {
                    Toggle("Remind me", isOn: $hasReminder.animation())
                    if hasReminder {
                        DatePicker("Reminder", selection: $reminderDate, in: Date()...,
                                   displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section("Preparation notes") {
                    TextEditor(text: $preparationNotes)
                        .frame(minHeight: 90)
                }

                if let message = validationMessage {
                    Section { ErrorText(message: message) }
                }

                if existing != nil {
                    Section {
                        Button("Delete Interview", role: .destructive) { showingDeleteAlert = true }
                    }
                }
            }
            .navigationTitle(existing == nil ? "New Interview" : "Edit Interview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
            }
            .onAppear(perform: loadInitialValues)
            .onChange(of: applicationId) { newId in
                fillFromApplication(id: newId)
            }
            .onChange(of: hasReminder) { isOn in
                if isOn {
                    NotificationService.shared.requestPermission()
                    // Default reminder: 1 hour before the interview (or soon, if that is already past).
                    let oneHourBefore = date.addingTimeInterval(-3600)
                    reminderDate = max(oneHourBefore, Date().addingTimeInterval(60))
                }
            }
            .alert("Delete this interview?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let interview = existing {
                        Task { await interviews.delete(interview) }
                    }
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func loadInitialValues() {
        guard !didLoad else { return }
        didLoad = true

        if let interview = existing {
            applicationId = interview.applicationId
            company = interview.company
            position = interview.position
            date = interview.date
            type = interview.type
            locationOrLink = interview.locationOrLink
            preparationNotes = interview.preparationNotes
            if let reminder = interview.reminderDate {
                hasReminder = true
                reminderDate = reminder
            }
        } else if let preselected = preselectedApplicationId {
            applicationId = preselected
            fillFromApplication(id: preselected)
        }
    }

    private func fillFromApplication(id: String?) {
        guard let id = id, let app = applications.application(withId: id) else { return }
        company = app.companyName
        position = app.position
    }

    private func save() {
        if Validation.isBlank(company) || Validation.isBlank(position) {
            withAnimation { validationMessage = "Company and position are required." }
            return
        }
        if Validation.isBlank(locationOrLink) {
            withAnimation { validationMessage = "Please enter a location, meeting link or phone number." }
            return
        }
        if hasReminder && reminderDate > date {
            withAnimation { validationMessage = "The reminder should be before the interview." }
            return
        }

        var interview = existing ?? Interview(company: "", position: "", date: date, locationOrLink: "")
        interview.applicationId = applicationId
        interview.company = company.trimmingCharacters(in: .whitespaces)
        interview.position = position.trimmingCharacters(in: .whitespaces)
        interview.date = date
        interview.type = type
        interview.locationOrLink = locationOrLink.trimmingCharacters(in: .whitespaces)
        interview.preparationNotes = preparationNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        interview.reminderDate = hasReminder ? reminderDate : nil

        let saved = interview
        let isNew = existing == nil
        Task {
            await interviews.save(saved)
            // A newly scheduled interview moves an early-stage application to "Interview".
            if isNew, let appId = saved.applicationId,
               let app = applications.application(withId: appId),
               app.status == .applied || app.status == .shortlisted {
                await applications.updateStatus(of: appId, to: .interview)
            }
        }
        dismiss()
    }
}
