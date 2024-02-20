import 'dart:io';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:validator_regex/validator_regex.dart';
import 'package:flutter/material.dart';

class MemeGeneratorScreen extends StatefulWidget {
  const MemeGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<MemeGeneratorScreen> createState() => _MemeGeneratorScreenState();
}

class _MemeGeneratorScreenState extends State<MemeGeneratorScreen> {
  late final TextEditingController _textController;
  late final TextEditingController _urlController;

  String _url = '';

  bool isImageSelected = false;
  File? imageFile;

  @override
  void initState() {
    _textController = TextEditingController();
    _urlController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    final decoration = BoxDecoration(
      border: Border.all(
        color: Colors.white,
        width: 2,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: ColoredBox(
              color: Colors.black,
              child: DecoratedBox(
                  decoration: decoration,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.3,
                          child: DecoratedBox(
                            decoration: decoration,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: isImageSelected
                                  ? Image.file(imageFile!, fit: BoxFit.cover,)
                                  : Image.network(_url,
                                loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : const Center(
                                    child: CircularProgressIndicator()
                                ),
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: height * 0.1,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: height * 0.2,
                            maxHeight: height * 0.5,
                            maxWidth: double.infinity,
                          ),
                          child: AutoSizeTextField(
                            keyboardType: TextInputType.text,
                            controller: _textController,
                            maxLines: null,
                            minFontSize: 8,
                            decoration: InputDecoration(
                              hintText: "Здесь мог бы быть ваш мем",
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              hintMaxLines: 3,
                              border: InputBorder.none,
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)
                ),
                child: const Icon(
                  Icons.open_in_browser,
                  size: 30,
                ),
                onPressed: () {
                  _getUrl(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10)
                ),
                child: const Icon(
                  Icons.photo,
                  size: 30,
                ),
                onPressed: () {
                  _pickImageFromGallery();
                },
              ),
            ],
          )
        ]
      ),
    );
  }

  Future<void> _getUrl(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paste image url'),
          content: TextFormField(
            keyboardType: TextInputType.url,
            controller: _urlController,
            decoration: const InputDecoration(hintText: "Image url"),
            autovalidateMode:
            AutovalidateMode.onUserInteraction,
            validator: (value) {
              return value != null && !Validator.url(value)
                  ? "Enter correct url"
                  : null;
            },
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel")
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    isImageSelected = false;
                    _url = _urlController.text;
                    _urlController.text = '';
                  });
                  Navigator.pop(context);
                },
                child: const Text("Ok")
            ),
          ],
        );
      },
    );
  }

  void _pickImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker()
          .pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          imageFile = File(pickedImage.path);
          isImageSelected = true;
        });
      } else {
        debugPrint("User didn't pick any image.");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
