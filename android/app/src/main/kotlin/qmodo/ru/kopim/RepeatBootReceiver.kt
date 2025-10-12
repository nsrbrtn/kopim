package qmodo.ru.kopim

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import dev.fluttercommunity.workmanager.WorkManagerWrapper
import dev.fluttercommunity.workmanager.pigeon.ExistingWorkPolicy
import dev.fluttercommunity.workmanager.pigeon.OneOffTaskRequest

class RepeatBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            return
        }

        try {
            scheduleOneOff(
                context = context,
                uniqueName = "boot_recurring_generate_window",
                taskName = "recurring_generate_window",
                delaySeconds = 30L,
            )
            scheduleOneOff(
                context = context,
                uniqueName = "boot_upcoming_apply_rules_once",
                taskName = "upcoming_apply_rules_once",
                delaySeconds = 45L,
            )
        } catch (error: Exception) {
            Log.w(TAG, "Failed to enqueue boot reschedule tasks", error)
        }
    }

    private fun scheduleOneOff(
        context: Context,
        uniqueName: String,
        taskName: String,
        delaySeconds: Long,
    ) {
        val wrapper = WorkManagerWrapper(context)
        val request = OneOffTaskRequest(
            uniqueName,
            taskName,
            null,
            delaySeconds,
            null,
            null,
            null,
            ExistingWorkPolicy.REPLACE,
            null,
        )
        wrapper.enqueueOneOffTask(request)
    }

    companion object {
        private const val TAG = "RepeatBootReceiver"
    }
}
