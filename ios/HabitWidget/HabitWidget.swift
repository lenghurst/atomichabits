import WidgetKit
import SwiftUI

/// Phase 9: Home Screen Widgets
/// Main widget implementation using WidgetKit
/// 
/// Features:
/// - Shows habit name with emoji
/// - Shows current streak or Graceful Score
/// - Complete button for one-tap habit completion
/// - Updates visual state when completed

// MARK: - Timeline Entry
struct HabitEntry: TimelineEntry {
    let date: Date
    let habitId: String?
    let habitName: String
    let habitEmoji: String
    let identity: String
    let isCompletedToday: Bool
    let currentStreak: Int
    let gracefulScore: Double
    let tinyVersion: String
    
    static var placeholder: HabitEntry {
        HabitEntry(
            date: Date(),
            habitId: nil,
            habitName: "Read 1 page",
            habitEmoji: "📚",
            identity: "a reader",
            isCompletedToday: false,
            currentStreak: 5,
            gracefulScore: 75.0,
            tinyVersion: "Read 1 page"
        )
    }
    
    static var empty: HabitEntry {
        HabitEntry(
            date: Date(),
            habitId: nil,
            habitName: "No habit set",
            habitEmoji: "",
            identity: "",
            isCompletedToday: false,
            currentStreak: 0,
            gracefulScore: 0,
            tinyVersion: ""
        )
    }
}

// MARK: - Timeline Provider
struct HabitTimelineProvider: TimelineProvider {
    // App Group ID for shared data (must match Flutter side)
    private let appGroupId = "group.com.atomichabits.hook.widget"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }
    
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry.placeholder
    }
    
    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        let entry = loadHabitData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let entry = loadHabitData()
        
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadHabitData() -> HabitEntry {
        guard let defaults = userDefaults else {
            return HabitEntry.empty
        }
        
        let habitId = defaults.string(forKey: "habit_id")
        let habitName = defaults.string(forKey: "habit_name") ?? "No habit set"
        let habitEmoji = defaults.string(forKey: "habit_emoji") ?? ""
        let identity = defaults.string(forKey: "identity") ?? ""
        let isCompleted = defaults.bool(forKey: "is_completed_today")
        let streak = defaults.integer(forKey: "current_streak")
        let score = defaults.double(forKey: "graceful_score")
        let tinyVersion = defaults.string(forKey: "tiny_version") ?? ""
        
        return HabitEntry(
            date: Date(),
            habitId: habitId,
            habitName: habitName,
            habitEmoji: habitEmoji,
            identity: identity,
            isCompletedToday: isCompleted,
            currentStreak: streak,
            gracefulScore: score,
            tinyVersion: tinyVersion
        )
    }
}

// MARK: - Widget View
struct HabitWidgetView: View {
    var entry: HabitEntry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    // Deep purple brand color
    private let primaryColor = Color(red: 103/255, green: 58/255, blue: 183/255)
    private let completedColor = Color(red: 76/255, green: 175/255, blue: 80/255)
    
    var body: some View {
        VStack(spacing: 8) {
            // Habit name with emoji
            HStack(spacing: 4) {
                if !entry.habitEmoji.isEmpty {
                    Text(entry.habitEmoji)
                        .font(.title3)
                }
                Text(entry.habitName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            
            // Stats
            Text(statsText)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Complete button
            if let habitId = entry.habitId {
                Link(destination: URL(string: "atomichabits://complete_habit?id=\(habitId)")!) {
                    Text(entry.isCompletedToday ? "Done today!" : "Complete")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(entry.isCompletedToday ? completedColor : primaryColor)
                        .cornerRadius(18)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .containerBackground(.fill, for: .widget)
    }
    
    private var statsText: String {
        if entry.currentStreak > 0 {
            return "\(entry.currentStreak) day streak"
        } else {
            return "Score: \(Int(entry.gracefulScore))%"
        }
    }
}

// MARK: - Widget Configuration
@main
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track and complete your habit with one tap")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    HabitWidget()
} timeline: {
    HabitEntry.placeholder
    HabitEntry(
        date: Date(),
        habitId: "123",
        habitName: "Read 1 page",
        habitEmoji: "📚",
        identity: "a reader",
        isCompletedToday: true,
        currentStreak: 7,
        gracefulScore: 85.0,
        tinyVersion: "Read 1 page"
    )
}
