import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';

/// `Task.group` values used across the app — one per upload flow, so each
/// can get its own native notification wording via
/// `FileDownloader().configureNotificationForGroup(...)` (see main.dart).
class UploadGroups {
  static const addProduct = 'addProduct';
  static const editProduct = 'editProduct';
  static const replyReview = 'replyReview';
}

enum UploadJobStatus { uploading, success, error }

/// One in-flight (or just-finished) background upload — e.g. "adding a
/// product with a video", "replying to a review with images". Purely a
/// view-model for [UploadProgressOverlay]; it has no idea what kind of
/// upload it represents.
class UploadJob {
  final String id;
  final String title;
  double progress; // 0.0–1.0
  UploadJobStatus status;

  UploadJob({
    required this.id,
    required this.title,
    this.progress = 0,
    this.status = UploadJobStatus.uploading,
  });
}

/// Thin wrapper around `background_downloader`'s OS-managed upload queue
/// (WorkManager on Android, a background `URLSession` on iOS).
///
/// Enqueuing a [Task] here hands the actual file transfer to the OS: it
/// keeps going if the seller leaves the screen, backgrounds the app, loses
/// signal (the OS waits for connectivity to return and resumes — no manual
/// retry logic needed), or — on Android — force-kills the app. The
/// completion notification is generated *natively* (see
/// `configureNotificationForGroup` in main.dart), not by this class, so it
/// fires even when no Dart isolate is alive to see it.
///
/// This class is only a window into whatever's alive to observe right now
/// — it drives the in-app progress overlay while the app is running. It is
/// NOT the source of truth for "did the upload succeed": that's the native
/// notification (always fires, on Android even after a kill) plus,
/// whenever the app is next opened, the relevant screen re-fetching from
/// the server like it always does — so nothing here needs to survive an
/// app restart.
class BackgroundUploadManager extends ChangeNotifier {
  final Map<String, UploadJob> _jobs = {};
  final Map<String, void Function(TaskStatusUpdate update)> _onDone = {};
  late final StreamSubscription<TaskUpdate> _sub;

  BackgroundUploadManager() {
    _sub = FileDownloader().updates.listen(_onUpdate);
  }

  List<UploadJob> get jobs => List.unmodifiable(_jobs.values);

  /// Enqueues [task] with the OS-level background uploader and returns
  /// immediately — does not wait for the transfer to finish.
  ///
  /// [onDone], if given, fires with the final [TaskStatusUpdate] only if
  /// this app process is still alive when the upload finishes — use it for
  /// in-memory follow-up (e.g. refreshing a list, rolling back an
  /// optimistic UI change on failure). Never rely on it as the only place
  /// that applies an effect: if the app was killed mid-upload it won't
  /// fire, so anything it does must also naturally happen on the next
  /// normal server fetch.
  Future<void> enqueueUpload(
    Task task, {
    required String title,
    void Function(TaskStatusUpdate update)? onDone,
  }) async {
    _jobs[task.taskId] = UploadJob(id: task.taskId, title: title);
    if (onDone != null) _onDone[task.taskId] = onDone;
    notifyListeners();
    await FileDownloader().enqueue(task);
  }

  void _onUpdate(TaskUpdate update) {
    final job = _jobs[update.task.taskId];
    if (job == null) return; // not one of ours (or from a prior app run)

    if (update is TaskProgressUpdate) {
      if (update.progress >= 0) {
        job.progress = update.progress.clamp(0.0, 1.0);
        notifyListeners();
      }
      return;
    }

    if (update is TaskStatusUpdate) {
      switch (update.status) {
        case TaskStatus.complete:
          job.status = UploadJobStatus.success;
          notifyListeners();
          _onDone.remove(job.id)?.call(update);
          _scheduleRemoval(job.id);
        case TaskStatus.failed:
        case TaskStatus.notFound:
        case TaskStatus.canceled:
          job.status = UploadJobStatus.error;
          notifyListeners();
          _onDone.remove(job.id)?.call(update);
          _scheduleRemoval(job.id);
        default:
          break; // enqueued / running / paused — not a terminal state yet
      }
    }
  }

  void _scheduleRemoval(String id) {
    // Keep the finished chip visible briefly (so a quick glance still
    // shows "done"/"failed") before it drops off the overlay.
    Future.delayed(const Duration(seconds: 3), () {
      _jobs.remove(id);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
