import 'dart:io';

import 'package:contacts/model/User.dart';
import 'package:contacts/services/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../utilities/imageUtility.dart';

class EditUser extends StatefulWidget {
  final User user;
  const EditUser({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  String? imgString;
  final _user = User();
  final _userNameController = TextEditingController();
  final _userContactController = TextEditingController();

  bool _validateName = false;
  bool _validateContact = false;
  final _userService = UserService();

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  var imageFile;

  @override
  void initState() {
    setState(() {
      _userNameController.text = widget.user.name ?? '';
      _userContactController.text = widget.user.contact ?? '';
      imgString = widget.user.image!;
      debugPrint(imgString);
      // debugPrint(utf8.decode(base64.decode(imgString!)));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite CRUD"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit New User',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ProfileImage(),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Name',
                    labelText: 'Name',
                    errorText:
                        _validateName ? 'Name Value Can\'t Be Empty' : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              TextField(
                  controller: _userContactController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter Contact',
                    labelText: 'Contact',
                    errorText: _validateContact
                        ? 'Contact Value Can\'t Be Empty'
                        : null,
                  )),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.teal,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () async {
                        setState(() {
                          _userNameController.text.isEmpty
                              ? _validateName = true
                              : _validateName = false;
                          _userContactController.text.isEmpty
                              ? _validateContact = true
                              : _validateContact = false;
                        });
                        if (_validateName == false &&
                            _validateContact == false) {
                          // print("Good Data Can Save");
                          _user.id = widget.user.id;
                          _user.name = _userNameController.text;
                          _user.contact = _userContactController.text;
                          _user.image = imgString;

                          var result = await _userService.UpdateUser(_user);
                          Navigator.pop(context, result);
                        }
                      },
                      child: const Text('Update Details')),
                  const SizedBox(
                    width: 10.0,
                  ),
                  TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(fontSize: 15)),
                      onPressed: () {
                        _userNameController.text = '';
                        _userContactController.text = '';
                      },
                      child: const Text('Clear Details'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60.0,
            backgroundImage:Utility.imageFromBase64String(imgString!).image
          ),
          Positioned(
            bottom: 20.0,
            right: 20,
            child: GestureDetector(
              child: const Icon(
                Icons.camera_enhance_rounded,
                color: Colors.teal,
                size: 30.0,
              ),
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: (builder) => bottomSheet());
              },
            ),
          )
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: [
          const Text("Choose Profile Photo"),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 50.0,
                ),
                onTap: () {
                  getImage("camera", _user);
                },
              ),
              GestureDetector(
                child: const Icon(
                  Icons.image,
                  size: 50.0,
                ),
                onTap: () {
                  getImage("gallery", _user);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  void getImage(String src, User user) async {
    ImageSource source;
    src=="gallery" ? source = ImageSource.gallery : source=ImageSource.camera;
    var pickedFile = await _picker.pickImage(source:source );

    imageFile = File(pickedFile!.path);
    imgString = Utility.base64String(imageFile.readAsBytesSync());
    debugPrint("ImageFile = ${imageFile.toString()}");
    debugPrint("is imageFile null : ${imageFile == null}");
    if (imageFile == null) {
      final ByteData bytes = await rootBundle.load('assets/images/profile.jpg');
      imgString = Utility.base64String(bytes.buffer.asUint8List());
    }
    setState(() {
      _imageFile = pickedFile;
      _user.image = imgString;
    });
  }
}
