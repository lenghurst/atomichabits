package co.thepact.app

import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "co.thepact/usage_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getUsageEvents" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0L
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()

                    try {
                        val events = getUsageEvents(startTime, endTime)
                        result.success(events)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "Usage access permission not granted", null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "getAppSessions" -> {
                    val startTime = call.argument<Long>("startTime") ?: 0L
                    val endTime = call.argument<Long>("endTime") ?: System.currentTimeMillis()
                    val packageFilter = call.argument<List<String>>("packages")

                    try {
                        val sessions = getAppSessions(startTime, endTime, packageFilter?.toSet())
                        result.success(sessions)
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "Usage access permission not granted", null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Get raw usage events (foreground/background transitions)
     * Returns list of maps with: packageName, eventType, timestamp
     */
    private fun getUsageEvents(startTime: Long, endTime: Long): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)
        val result = mutableListOf<Map<String, Any>>()

        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)

            // Only capture foreground/background events
            val eventType = event.eventType
            if (eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                eventType == UsageEvents.Event.MOVE_TO_BACKGROUND ||
                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
                    (eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                     eventType == UsageEvents.Event.ACTIVITY_PAUSED))) {

                result.add(mapOf(
                    "packageName" to event.packageName,
                    "eventType" to eventType,
                    "timestamp" to event.timeStamp
                ))
            }
        }

        return result
    }

    /**
     * Calculate app sessions from usage events
     * Returns list of maps with: packageName, startTime, endTime, durationMs
     */
    private fun getAppSessions(
        startTime: Long,
        endTime: Long,
        packageFilter: Set<String>?
    ): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(startTime, endTime)

        // Track active sessions: packageName -> startTimestamp
        val activeSessions = mutableMapOf<String, Long>()
        val completedSessions = mutableListOf<Map<String, Any>>()

        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val pkg = event.packageName

            // Apply package filter if provided
            if (packageFilter != null && pkg !in packageFilter) continue

            when (event.eventType) {
                UsageEvents.Event.MOVE_TO_FOREGROUND,
                UsageEvents.Event.ACTIVITY_RESUMED -> {
                    // App moved to foreground - start session
                    if (!activeSessions.containsKey(pkg)) {
                        activeSessions[pkg] = event.timeStamp
                    }
                }
                UsageEvents.Event.MOVE_TO_BACKGROUND,
                UsageEvents.Event.ACTIVITY_PAUSED -> {
                    // App moved to background - end session
                    val sessionStart = activeSessions.remove(pkg)
                    if (sessionStart != null) {
                        val duration = event.timeStamp - sessionStart
                        if (duration > 1000) { // Ignore sessions < 1 second
                            completedSessions.add(mapOf(
                                "packageName" to pkg,
                                "startTime" to sessionStart,
                                "endTime" to event.timeStamp,
                                "durationMs" to duration
                            ))
                        }
                    }
                }
            }
        }

        // Handle still-active sessions (app currently in foreground)
        val now = System.currentTimeMillis()
        for ((pkg, sessionStart) in activeSessions) {
            completedSessions.add(mapOf(
                "packageName" to pkg,
                "startTime" to sessionStart,
                "endTime" to now,
                "durationMs" to (now - sessionStart),
                "isActive" to true
            ))
        }

        return completedSessions.sortedBy { it["startTime"] as Long }
    }
}
