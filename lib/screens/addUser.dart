import 'dart:io';
import 'package:contacts/model/User.dart';
import 'package:contacts/services/userService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../utilities/imageUtility.dart';


class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
   XFile? _imageFile ;
  final ImagePicker _picker = ImagePicker();

  final _userNameController = TextEditingController();
  final _userContactController = TextEditingController();

   final _user = User();

  bool _validateName = false;
  bool _validateContact = false;

  final _userService=UserService();
  var imageFile;

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
                'Add New User',
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

                          _user.name = _userNameController.text;
                          _user.contact = _userContactController.text;

                          var result = await _userService.SaveUser(_user);
                            Navigator.pop(context, result);
                        }
                      },
                      child: const Text('Save Details')),
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

  Widget ProfileImage() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60.0,
            backgroundImage:_imageFile==null ?
            const AssetImage("assets/images/profile.jpg"):Image.file(File(_imageFile!.path)).image ,

          ),
          Positioned(
            bottom: 20.0,
            right:20,
            child: GestureDetector(
              child: const Icon(
                Icons.camera_enhance_rounded,
                color: Colors.teal,
                size: 30.0,
              ),
              onTap: (){
                showModalBottomSheet(
                    context: context,
                    builder: (builder)=>bottomShhet());
              },
            ),
          )
        ],
      ),
    );
  }
  Widget bottomShhet(){
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 20.0
      ),
      child: Column(
        children: [
          const Text("Choose Profile Photo"),
          const SizedBox(height: 20.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: const Icon(size: 50.0,Icons.camera_alt_outlined,),
                onTap: (){
                  getImage("camera");
                },
              ),
              GestureDetector(
                child: const Icon(size:50.0,Icons.image,),
                onTap: (){
                  getImage("gallery");
                  },
              )
            ],
          )
        ],
      ),
    );
  }

  void getImage(String src) async{
    ImageSource source;

    src=="camera"? source=ImageSource.camera : source = ImageSource.gallery ;

    var pickedFile = await _picker.pickImage(source: source);
     imageFile = File(pickedFile!.path);

     //base64 image
     String imgString = Utility.base64String(imageFile.readAsBytesSync());

     debugPrint("ImageFile = ${imageFile.toString()}");
     debugPrint("is imageFile null : ${imageFile==null}");
     if(imageFile==null){
       final ByteData bytes = await rootBundle.load('assets/images/profile.jpg');
       imgString = Utility.base64String(bytes.buffer.asUint8List());
     }
     setState(() {
       _imageFile = pickedFile;
       _user.image=imgString;
     });
  }


}
