import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/viewModel/providers/uploadProvider/backgroundUpload_provider.dart';
import 'package:provider/provider.dart';

/// Floating stack of "Uploading… 42%" chips, mounted once at the app root
/// (see main.dart) so it stays visible across every screen — including
/// after the seller navigates away from the form that started the upload.
class UploadProgressOverlay extends StatelessWidget {
  const UploadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Consumer<BackgroundUploadManager>(
        builder: (context, manager, _) {
          final jobs = manager.jobs;
          if (jobs.isEmpty) return const SizedBox.shrink();

          return Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: jobs
                      .map((job) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _UploadChip(job: job),
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UploadChip extends StatelessWidget {
  final UploadJob job;
  const _UploadChip({required this.job});

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (job.status) {
      UploadJobStatus.uploading => AppColor.primaryColor,
      UploadJobStatus.success => Colors.green,
      UploadJobStatus.error => Colors.redAccent,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: BoxConstraints(maxWidth: 320.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xff1A1009),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: accent.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22.w,
            height: 22.w,
            child: switch (job.status) {
              UploadJobStatus.uploading => Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: job.progress,
                      strokeWidth: 2.2,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                    Text(
                      "${(job.progress * 100).round()}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 6.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              UploadJobStatus.success => Icon(
                  Icons.check_circle_rounded,
                  color: accent,
                  size: 22.sp,
                ),
              UploadJobStatus.error => Icon(
                  Icons.error_rounded,
                  color: accent,
                  size: 22.sp,
                ),
            },
          ),
          SizedBox(width: 10.w),
          Flexible(
            child: Text(
              switch (job.status) {
                UploadJobStatus.uploading =>
                  "${job.title} — ${(job.progress * 100).round()}%",
                UploadJobStatus.success => "${job.title} — Done ✓",
                UploadJobStatus.error => "${job.title} — Failed",
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
