import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/viewModel/providers/courierProvider/leopards_tracking_provider.dart';
import 'package:provider/provider.dart';

class LeopardsTrackingScreen extends StatefulWidget {
  final String trackNumber;
  const LeopardsTrackingScreen({super.key, required this.trackNumber});

  @override
  State<LeopardsTrackingScreen> createState() => _LeopardsTrackingScreenState();
}

class _LeopardsTrackingScreenState extends State<LeopardsTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeopardsTrackingProvider>().fetchTracking(
        widget.trackNumber,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Track Parcel",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<LeopardsTrackingProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 60.sp,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "No tracking history found",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Track #: ${widget.trackNumber}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                if (_shouldShowPickupButton(provider))
                  _buildPickupBanner(provider),
                SizedBox(height: 24.h),
                Text(
                  "Shipment Journey",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.history.length,
                  itemBuilder: (context, index) {
                    final item = provider.history[index];
                    final isFirst = index == 0;
                    final isLast = index == provider.history.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 14.w,
                                height: 14.w,
                                decoration: BoxDecoration(
                                  color: isFirst
                                      ? AppColor.primaryColor
                                      : Colors.grey[400],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isFirst
                                        ? AppColor.primaryColor.withOpacity(0.2)
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2.w,
                                    color: Colors.grey[300],
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 24.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.status ?? "N/A",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: isFirst
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isFirst
                                          ? AppColor.primaryColor
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (item.trackLocation?.isNotEmpty ==
                                      true) ...[
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 12.sp,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          item.trackLocation!,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  SizedBox(height: 4.h),
                                  Text(
                                    "${item.trackDate} | ${item.trackTime}",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.local_shipping_rounded,
              color: Colors.blue,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tracking Number",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  widget.trackNumber,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowPickupButton(LeopardsTrackingProvider provider) {
    return provider.history.any(
      (item) =>
          item.status?.toLowerCase().contains("pickup request not send") ??
          false,
    );
  }

  Widget _buildPickupBanner(LeopardsTrackingProvider provider) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[800], size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Leopards is waiting for a pickup request. Please generate the load sheet to notify the courier.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.amber[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.loading
                  ? null
                  : () => provider.requestPickup(widget.trackNumber),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: provider.loading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                provider.loading ? "Requesting..." : "Request Pickup Now",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
