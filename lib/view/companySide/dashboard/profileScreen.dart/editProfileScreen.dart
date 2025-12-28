import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_brand/models/profile/getSingleProfile_model.dart';
import 'package:new_brand/resources/appColor.dart';
import 'package:new_brand/resources/global.dart';
import 'package:new_brand/resources/toast.dart';
import 'package:new_brand/viewModel/providers/profileProvider/getProfile_provider.dart';
import 'package:new_brand/viewModel/providers/profileProvider/updateProfile_provider.dart';
import 'package:new_brand/widgets/customBgContainer.dart';
import 'package:new_brand/widgets/customButton.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController address;
  late TextEditingController description;

  File? imageFile;

  @override
  void initState() {
    name = TextEditingController(text: widget.profile.name ?? "");
    email = TextEditingController(text: widget.profile.email ?? "");
    phone = TextEditingController(text: widget.profile.phone ?? "");
    address = TextEditingController(text: widget.profile.address ?? "");
    description = TextEditingController(text: widget.profile.description ?? "");
    super.initState();
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => imageFile = File(img.path));
  }

  InputDecoration field(String title) {
    return InputDecoration(
      labelText: title,
      filled: true,
      fillColor: Colors.grey.withOpacity(0.15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appimagecolor,
      appBar: AppBar(
        title: Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColor.primaryColor,
      ),

      body: CustomBgContainer(
        child: Consumer<EditProfileProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 10),

                  // Image
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColor.primaryColor.withOpacity(0.2),
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : NetworkImage(
                              Global.imageUrl + widget.profile.image!,
                            ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Fields
                  TextField(controller: name, decoration: field("Full Name")),

                  SizedBox(height: 15),
                  TextField(controller: phone, decoration: field("Phone")),
                  SizedBox(height: 15),
                  TextField(controller: address, decoration: field("Address")),
                  SizedBox(height: 15),
                  TextField(
                    controller: description,
                    maxLines: 3,
                    decoration: field("Description"),
                  ),

                  SizedBox(height: 35),

                  provider.loading
                      ? SpinKitThreeBounce(
                          color: AppColor.primaryColor,
                          size: 30.0,
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: CustomButton(
                            text: "Save Changes",
                            onTap: () async {
                              await provider.updateProfile(
                                profileId: widget.profile.sId!,
                                name: name.text,
                                email: email.text,
                                phone: phone.text,
                                address: address.text,
                                description: description.text,
                                image: imageFile,
                              );

                              if (provider.error != null) {
                                AppToast.error(provider.error.toString());
                              } else {
                                await Provider.of<ProfileFetchProvider>(
                                  context,
                                  listen: false,
                                ).getProfileOnce(refresh: true);

                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
