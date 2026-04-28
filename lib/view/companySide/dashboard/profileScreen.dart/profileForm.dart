import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/local_storage.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/view/companySide/dashboard/company_home_screen.dart';
import 'package:new_brand/viewModel/providers/profileProvider/profile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:new_brand/widgets/customContainer.dart';
import 'package:new_brand/widgets/customImageContainer.dart';
import 'package:new_brand/widgets/customTextFeld.dart';
import 'package:new_brand/widgets/customValidation.dart';
import 'package:provider/provider.dart';

class ProfileFormScreen extends StatefulWidget {
  final String email;
  const ProfileFormScreen({super.key, required this.email});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _citySearchCtrl = TextEditingController();

  final ValueNotifier<File?> _selectedImage = ValueNotifier<File?>(null);

  // ✅ City state
  String? _selectedCityId;
  String? _selectedCityName;
  List<Map<String, String>> _allCities = [];
  List<Map<String, String>> _filteredCities = [];
  bool _citiesLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _fetchCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _citySearchCtrl.dispose();
    _selectedImage.dispose();
    super.dispose();
  }

  // ✅ Cities fetch karo
  Future<void> _fetchCities() async {
    setState(() => _citiesLoading = true);
    try {
      final response = await http.get(Uri.parse(Global.leopardsCities));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List cities = data['cities'] ?? [];
        setState(() {
          _allCities = cities
              .map<Map<String, String>>(
                (c) => {'id': c['id'].toString(), 'name': c['name'].toString()},
              )
              .toList();
          _filteredCities = List.from(_allCities);
        });
      }
    } catch (e) {
      print("❌ Cities error: $e");
    }
    setState(() => _citiesLoading = false);
  }

  // ✅ City search filter
  void _filterCities(String query) {
    setState(() {
      _filteredCities = _allCities
          .where((c) => c['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // ✅ City picker bottom sheet
  void _showCityPicker() {
    _citySearchCtrl.clear();
    _filteredCities = List.from(_allCities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // ✅ Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 16.h),

              // ✅ Title
              Text(
                "Select Your City",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "This will be used as Leopards origin city",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),
              SizedBox(height: 14.h),

              // ✅ Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _citySearchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search city...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _citySearchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _citySearchCtrl.clear();
                              setModal(
                                () => _filteredCities = List.from(_allCities),
                              );
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColor.primaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (v) {
                    setModal(() => _filterCities(v));
                  },
                ),
              ),
              SizedBox(height: 10.h),

              Divider(height: 1, color: Colors.grey[200]),

              // ✅ Cities list
              Expanded(
                child: _citiesLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColor.primaryColor,
                        ),
                      )
                    : _filteredCities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48.sp,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "No city found",
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredCities.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey[100]),
                        itemBuilder: (_, i) {
                          final city = _filteredCities[i];
                          final isSelected = _selectedCityId == city['id'];

                          return ListTile(
                            leading: Icon(
                              Icons.location_city_rounded,
                              color: isSelected
                                  ? AppColor.primaryColor
                                  : Colors.grey[400],
                              size: 20.sp,
                            ),
                            title: Text(
                              city['name']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColor.primaryColor
                                    : Colors.black87,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColor.primaryColor,
                                    size: 20.sp,
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCityId = city['id'];
                                _selectedCityName = city['name'];
                              });
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _selectedImage.value = File(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProfileProvider>();

    return Scaffold(
      body: CustomBgContainer(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 30.h,
            bottom: 10.h,
          ),
          child: Column(
            children: [
              Text(
                "Profile Form",
                style: TextStyle(
                  fontSize: 28.sp,
                  color: AppColor.appimagecolor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 20.h),

              Expanded(
                child: Center(
                  child: CustomAppContainer(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ✅ Image picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: ValueListenableBuilder<File?>(
                              valueListenable: _selectedImage,
                              builder: (context, image, child) {
                                return CustomImageContainer(
                                  height: 140.h,
                                  width: 140.w,
                                  child: image == null
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              color: Colors.white,
                                              size: 40.sp,
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Upload Image",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ],
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          child: Image.file(
                                            image,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 30.h),

                          CustomTextField(
                            controller: _nameController,
                            hintText: "Enter your name",
                            headerText: "Full Name",
                            validator: Validators.name,
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _emailController,
                            headerText: "Email Address",
                            readOnly: true,
                            validator: Validators.email,
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _phoneController,
                            hintText: "Enter your phone number",
                            keyboardType: TextInputType.number,
                            headerText: "Phone Number",
                            validator: Validators.phonePK,
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _addressController,
                            hintText: "Enter your address",
                            headerText: "Address",
                            validator: Validators.required,
                          ),
                          SizedBox(height: 20.h),

                          // ✅ City Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Leopards Origin City",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              GestureDetector(
                                onTap: _showCityPicker,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 14.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: _selectedCityId != null
                                          ? Colors.green
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_rounded,
                                        color: _selectedCityId != null
                                            ? Colors.green
                                            : Colors.white70,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          _selectedCityName ??
                                              "Select City (for Leopards)",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: _selectedCityName != null
                                                ? Colors.white
                                                : Colors.white60,
                                          ),
                                        ),
                                      ),
                                      _citiesLoading
                                          ? SizedBox(
                                              width: 16.w,
                                              height: 16.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white70,
                                              ),
                                            )
                                          : Icon(
                                              Icons.arrow_drop_down,
                                              color: Colors.white70,
                                            ),
                                    ],
                                  ),
                                ),
                              ),

                              // ✅ City selected confirmation
                              if (_selectedCityId != null) ...[
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "Origin city set to: $_selectedCityName",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 20.h),

                          CustomTextField(
                            controller: _descriptionController,
                            hintText: "Write something about yourself",
                            headerText: "Description",
                            validator: Validators.required,
                            maxLines: 5,
                            height: 120.h,
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: AppColor.appimagecolor,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
        child: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            return CustomButton(
              text: provider.loading ? "Saving..." : "Save Profile",
              onTap: provider.loading
                  ? null
                  : () async {
                      provider.clearError();

                      // ✅ City required check
                      if (_selectedCityId == null) {
                        AppToast.error(
                          "Please select your city for Leopards delivery",
                        );
                        return;
                      }

                      final token = await LocalStorage.getToken();
                      if (token == null || token.isEmpty) {
                        AppToast.error("Session expired. Please login again.");
                        return;
                      }

                      await provider.createProfileProvider(
                        token: token,
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        description: _descriptionController.text.trim(),
                        cityId: _selectedCityId, // ✅
                        cityName: _selectedCityName, // ✅
                        image: _selectedImage.value,
                      );

                      if (!mounted) return;

                      if (provider.profileData?.profile != null) {
                        AppToast.success("Profile created successfully");
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompanyHomeScreen(),
                          ),
                        );
                      } else {
                        AppToast.error(provider.errorMessage ?? "Failed");
                      }
                    },
            );
          },
        ),
      ),
    );
  }
}
