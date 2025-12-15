package com.example.atomic_habits_hook_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home Screen Widget Provider for Atomic Habits Hook App
 * 
 * Phase 9: Home Screen Widgets
 * 
 * Features:
 * - Shows habit name with emoji
 * - Shows current streak or Graceful Score
 * - Complete button for one-tap habit completion
 * - Updates visual state when completed
 * 
 * Layout: habit_widget.xml
 */
class HabitWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.habit_widget)
            
            // Get habit data from shared preferences
            val habitName = widgetData.getString("habit_name", "No habit set")
            val habitEmoji = widgetData.getString("habit_emoji", "")
            val isCompleted = widgetData.getBoolean("is_completed_today", false)
            val currentStreak = widgetData.getInt("current_streak", 0)
            val gracefulScore = widgetData.getFloat("graceful_score", 0f)
            val habitId = widgetData.getString("habit_id", null)
            
            // Set habit name with emoji
            val displayName = if (habitEmoji?.isNotEmpty() == true) {
                "$habitEmoji $habitName"
            } else {
                habitName ?: "No habit set"
            }
            views.setTextViewText(R.id.habit_name, displayName)
            
            // Set streak/score display
            val statsText = if (currentStreak > 0) {
                "$currentStreak day streak"
            } else {
                "Score: ${gracefulScore.toInt()}%"
            }
            views.setTextViewText(R.id.habit_stats, statsText)
            
            // Configure complete button based on completion state
            if (isCompleted) {
                views.setTextViewText(R.id.complete_button, "Done today!")
                views.setInt(R.id.complete_button, "setBackgroundResource", R.drawable.widget_button_completed)
            } else {
                views.setTextViewText(R.id.complete_button, "Complete")
                views.setInt(R.id.complete_button, "setBackgroundResource", R.drawable.widget_button_default)
            }
            
            // Set up click handlers
            if (habitId != null && !isCompleted) {
                // Complete button - sends background intent to complete the habit
                val completeUri = Uri.parse("atomichabits://complete_habit?id=$habitId")
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    completeUri
                )
                views.setOnClickPendingIntent(R.id.complete_button, backgroundIntent)
            }
            
            // Widget container click - opens the app
            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_container, launchIntent)
            
            // Update the widget
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
