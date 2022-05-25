import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  DemoAppState createState() => DemoAppState();
}

class DemoAppState extends State<DemoApp> {
  String text = '';
  String subject = '';
  List<String> imagePaths = [];
  TextEditingController textdata = TextEditingController();
  final imageUrl = "https://res.cloudinary.com/practicaldev/image/fetch/s--_HBZhuhF--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://thepracticaldev.s3.amazonaws.com/i/nweeqf97l2md3tlqkjyt.jpg";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share Plus Plugin Demo',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Share Plus Plugin Demo'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  TextField(controller: textdata,
                    decoration:const  InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text("ENTER TEST NAME")
                    ),
                  ),
                  ElevatedButton(onPressed: () async {
                    if (textdata.value.text.isNotEmpty) {
                      await Share.share(textdata.text);
                    }
                  }, child: Text("Share TEST RESULT")),
                  ElevatedButton(onPressed: () async {
                    const weburl = "https://pub.dev/packages/device_info_plus/example";
                    if (textdata.value.text.isNotEmpty) {
                      await Share.share('${textdata.text}${weburl}');
                    }
                  }, child: Text("Share TEST URL")),
                  Image.network(imageUrl
                  ),
                  ElevatedButton(onPressed: () async {
                    final uri = Uri.parse(imageUrl);
                    final res = await http.get(uri);
                    final bytes = res.bodyBytes;
                    final temp = await getTemporaryDirectory();
                    final path = '${temp.path}/image.jpg';
                    File(path).writeAsBytesSync(bytes);
                    await Share.shareFiles([path]);
                  }, child: const Text("Share image ")),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter some text and/or link to share',
                    ),
                    maxLines: 2,
                    onChanged: (String value) =>
                        setState(() {
                          text = value;
                        }),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Report',
                      hintText: 'Enter Lab Reports Name',
                    ),
                    maxLines: 2,
                    onChanged: (String value) =>
                        setState(() {
                          subject = value;
                        }),
                  ),
                  Padding(padding: EdgeInsets.only(top: 12.0)),
                  // ImagePreview(imagePaths, onDelete: _onDeleteImage),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text('Add file'),
                    onTap: () async {
                      final imagePicker = ImagePicker();
                      final pickedFile = await imagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          imagePaths.add(pickedFile.path);
                        });
                      }
                    },
                  ),
                  Padding(padding: EdgeInsets.only(top: 12.0)),
                  Builder(
                    builder: (BuildContext context) {
                      return ElevatedButton(
                        onPressed: text.isEmpty && imagePaths.isEmpty
                            ? null
                            : () => _onShare(context),
                        child: Text('Share'),
                      );
                    },
                  ),
                  //To pick image from camera
                  ElevatedButton(onPressed: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.camera);
                    if (image == null) return;
                    await Share.shareFiles([image.path]);
                  }, child: Text("Share Image from Camera ")),
                  //To pick image from gallery
                  ElevatedButton(onPressed: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery);
                    if (image == null) return;
                    await Share.shareFiles([image.path]);
                  }, child: Text("Share Image from Gallery ")),
                  //To pick video from camera
                  ElevatedButton(onPressed: () async {
                    final image = await ImagePicker().pickVideo(
                        source: ImageSource.camera);
                    if (image == null) return;
                    await Share.shareFiles([image.path]);
                  }, child: Text("Share Video ")),
                  //To pick video from gallery
                  ElevatedButton(onPressed: () async {
                    final image = await ImagePicker().pickVideo(
                        source: ImageSource.gallery);
                    if (image == null) return;
                    await Share.shareFiles([image.path]);
                  }, child: Text("Share Video from Gallery ")),
                  //To pick file from mobile
                  ElevatedButton(onPressed: ()  async{
                    final result = await FilePicker.platform.pickFiles();
                    List<String>? files =result?.files.map((e) => e.path).cast<String>().toList();
                    if(files==null)return ;
                    await Share.shareFiles(files);}, child:const  Text("Pick and Share File")),
                  const Padding(padding: EdgeInsets.only(top: 12.0)),
                  Builder(
                    builder: (BuildContext context) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: text.isEmpty && imagePaths.isEmpty
                              ? null
                              : () => _onShareWithResult(context),
                          child: const Text('Share '),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }



  void _onDeleteImage(int position) {
    setState(() {
      imagePaths.removeAt(position);
    });
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (imagePaths.isNotEmpty) {
      await Share.shareFiles(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }

  void _onShareWithResult(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    ShareResult result;
    if (imagePaths.isNotEmpty) {
      result = await Share.shareFilesWithResult(imagePaths,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      result = await Share.shareWithResult(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Share result: ${result.status}"),
    ));
  }
}