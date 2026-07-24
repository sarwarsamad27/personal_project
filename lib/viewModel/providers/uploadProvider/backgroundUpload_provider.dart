import 'package:flutter/foundation.dart';
import 'package:new_brand/resources/localNotifications.dart';

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
  String? errorMessage;

  UploadJob({
    required this.id,
    required this.title,
    this.progress = 0,
    this.status = UploadJobStatus.uploading,
    this.errorMessage,
  });
}

/// App-wide queue of uploads that keep running after the screen that
/// started them is gone — the seller can back out of "Add Product" (or
/// switch tabs, start a second product, etc.) while a video keeps
/// uploading, the same way Instagram lets you leave a post while it
/// finishes sending.
///
/// This works because it's a single instance registered once at the top of
/// the provider tree (see multiProvider.dart) — it outlives every screen,
/// so a job's `task` closure keeps running via a bare `Future` (not tied to
/// any BuildContext) even after `Navigator.pop` unmounts the screen that
/// enqueued it. It does NOT survive the app process being killed — that
/// would need a native background-task mechanism (e.g. WorkManager), which
/// is out of scope; this matches how Instagram itself behaves.
class BackgroundUploadManager extends ChangeNotifier {
  final Map<String, UploadJob> _jobs = {};

  List<UploadJob> get jobs => List.unmodifiable(_jobs.values);

  bool get hasActiveJobs =>
      _jobs.values.any((j) => j.status == UploadJobStatus.uploading);

  /// Starts [task] immediately in the background and returns its job id.
  /// [task] is handed a `reportProgress` callback (0.0–1.0) to call as
  /// bytes go out over the wire, and should throw on failure.
  ///
  /// On completion a local "done" notification fires — title/body only,
  /// deliberately no percentage (progress belongs on the in-app overlay).
  String enqueue({
    required String title,
    required Future<void> Function(void Function(double progress) reportProgress) task,
    required String successTitle,
    required String successBody,
    String failureTitle = "Upload failed",
  }) {
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final job = UploadJob(id: id, title: title);
    _jobs[id] = job;
    notifyListeners();

    _run(
      job: job,
      task: task,
      successTitle: successTitle,
      successBody: successBody,
      failureTitle: failureTitle,
    );

    return id;
  }

  Future<void> _run({
    required UploadJob job,
    required Future<void> Function(void Function(double progress) reportProgress) task,
    required String successTitle,
    required String successBody,
    required String failureTitle,
  }) async {
    try {
      await task((progress) {
        job.progress = progress.clamp(0.0, 1.0);
        notifyListeners();
      });
      job.status = UploadJobStatus.success;
      notifyListeners();
      await showUploadStatusNotification(title: successTitle, body: successBody);
    } catch (e) {
      job.status = UploadJobStatus.error;
      job.errorMessage = e.toString();
      notifyListeners();
      await showUploadStatusNotification(
        title: failureTitle,
        body: '${job.title} — tap to check and retry.',
      );
    } finally {
      // Keep the finished chip visible briefly (so a quick glance still
      // shows "done"/"failed") before it drops off the overlay.
      await Future.delayed(const Duration(seconds: 3));
      _jobs.remove(job.id);
      notifyListeners();
    }
  }
}
