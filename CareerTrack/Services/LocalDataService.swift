import Foundation

/// Sample data used in Demo Mode. Nothing here is stored in Firebase.
enum LocalDataService {

    private static func daysFromNow(_ days: Int, hour: Int = 10) -> Date {
        let calendar = Calendar.current
        let base = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: base) ?? base
    }

    static func sampleApplications() -> [JobApplication] {
        [
            JobApplication(id: "demo-app-1", companyName: "Google", position: "Software Engineering Intern",
                           jobType: .internship, status: .interview, applicationDate: daysFromNow(-20),
                           location: "Singapore", jobURL: "https://careers.google.com",
                           salary: "$4,000 / month", notes: "Referred by a senior from the CSE club.",
                           followUpDate: daysFromNow(3), createdAt: daysFromNow(-20)),
            JobApplication(id: "demo-app-2", companyName: "Grameenphone", position: "Junior iOS Developer",
                           jobType: .fullTime, status: .shortlisted, applicationDate: daysFromNow(-12),
                           location: "Dhaka", notes: "Online assessment completed.",
                           followUpDate: daysFromNow(5), createdAt: daysFromNow(-12)),
            JobApplication(id: "demo-app-3", companyName: "Pathao", position: "Mobile App Intern",
                           jobType: .internship, status: .applied, applicationDate: daysFromNow(-4),
                           location: "Dhaka (Hybrid)", jobURL: "https://pathao.com/careers",
                           notes: "Applied through the careers page.", createdAt: daysFromNow(-4)),
            JobApplication(id: "demo-app-4", companyName: "Brain Station 23", position: "Trainee Software Engineer",
                           jobType: .fullTime, status: .accepted, applicationDate: daysFromNow(-45),
                           location: "Dhaka", salary: "BDT 35,000 / month",
                           notes: "Offer letter received. Reply before the deadline.", createdAt: daysFromNow(-45)),
            JobApplication(id: "demo-app-5", companyName: "Shopify", position: "Part-time QA Tester",
                           jobType: .partTime, status: .rejected, applicationDate: daysFromNow(-30),
                           location: "Remote", notes: "Rejected after the first round. Ask for feedback.",
                           createdAt: daysFromNow(-30)),
            JobApplication(id: "demo-app-6", companyName: "bKash", position: "Product Design Intern",
                           jobType: .internship, status: .interview, applicationDate: daysFromNow(-9),
                           location: "Dhaka", notes: "Portfolio review requested.", createdAt: daysFromNow(-9))
        ]
    }

    static func sampleInterviews() -> [Interview] {
        [
            Interview(id: "demo-int-1", applicationId: "demo-app-1", company: "Google",
                      position: "Software Engineering Intern", date: daysFromNow(1, hour: 15),
                      locationOrLink: "https://meet.google.com/abc-defg-hij", type: .online,
                      preparationNotes: "Revise arrays, hash maps and BFS/DFS. Prepare 2 STAR stories.",
                      reminderDate: daysFromNow(1, hour: 9)),
            Interview(id: "demo-int-2", applicationId: "demo-app-6", company: "bKash",
                      position: "Product Design Intern", date: daysFromNow(6, hour: 11),
                      locationOrLink: "bKash HQ, Gulshan", type: .onSite,
                      preparationNotes: "Bring printed portfolio. Explain design process for 2 projects."),
            Interview(id: "demo-int-3", applicationId: "demo-app-4", company: "Brain Station 23",
                      position: "Trainee Software Engineer", date: daysFromNow(-35, hour: 14),
                      locationOrLink: "+880 1700-000000", type: .phone,
                      preparationNotes: "HR screening call.")
        ]
    }

    static func sampleProfile(email: String) -> CareerProfile {
        CareerProfile(fullName: "Demo Student", email: email, phone: "+880 1700-000000",
                      university: "Sample University", degree: "B.Sc. in Computer Science & Engineering",
                      graduationYear: "2027",
                      skills: ["Swift", "SwiftUI", "Firebase", "Git", "Problem Solving"],
                      summary: "Final-year CSE student interested in iOS development and building useful mobile apps.",
                      workExperience: "Teaching Assistant, Programming Lab (2025 – present)\nVolunteer, University Tech Fest (2024)")
    }
}
