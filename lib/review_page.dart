import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedStation = "";
  int starRating = 0;
  List<String> comments = [];
  Color successfulChargeButtonColor = Colors.transparent;
  Color reportIssueButtonColor = Colors.transparent;

  void _navigateToAddComment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCommentPage(onSubmit: (comment) {
        setState(() {
          comments.add(comment);
        });
      })),
    );
  }

  void _navigateToEditInformation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditInformationPage(comments: comments)),
    );
  }

  void _navigateToAddPhoto(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPhotoPage()),
    );
  }

  void _sendButtonPressed() {
    // "Send" button action can be defined here
    print("Send button pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Action'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              child: Text(selectedStation, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            actionButton(context, Icons.check_circle_outline, 'Successful Charge', () {
              setState(() {
                successfulChargeButtonColor = successfulChargeButtonColor == Colors.transparent ? Colors.green : Colors.transparent;
              });
            }, color: successfulChargeButtonColor),
            actionButton(context, Icons.report_problem, 'Report Issue', () {
              setState(() {
                reportIssueButtonColor = reportIssueButtonColor == Colors.transparent ? Colors.red : Colors.transparent;
              });
            }, color: reportIssueButtonColor),
            actionButton(context, Icons.comment, 'Add Comment', () => _navigateToAddComment(context)),
            actionButton(context, Icons.add_a_photo, 'Add Photo', () => _navigateToAddPhoto(context)),
            actionButton(context, Icons.edit, 'Edit Information', () => _navigateToEditInformation(context)),
            ratingBar(),
            sendButton(),
          ],
        ),
      ),
    );
  }

  Widget actionButton(BuildContext context, IconData icon, String text, VoidCallback onPressed, {Color color = Colors.transparent}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextButton.icon(
        icon: Icon(icon),
        label: Text(text),
        onPressed: onPressed,
      ),
    );
  }

  Widget ratingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < starRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() {
              starRating = index + 1;
            });
          },
        );
      }),
    );
  }

  Widget sendButton() {
    return ElevatedButton(
      onPressed: _sendButtonPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 67.0, vertical: 12.0),
        child: Text(
          'Send',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class AddCommentPage extends StatelessWidget {
  final Function(String) onSubmit;

  AddCommentPage({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Comment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: 'Enter your comment here',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  onSubmit(commentController.text);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Submit Comment'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditInformationPage extends StatefulWidget {
  final List<String> comments;

  EditInformationPage({required this.comments});

  @override
  _EditInformationPageState createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = widget.comments.map((comment) => TextEditingController(text: comment)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Information'),
      ),
      body: ListView.builder(
        itemCount: widget.comments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: controllers[index],
              decoration: InputDecoration(
                hintText: 'Edit your comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          );
        },
      ),
    );
  }
}

class AddPhotoPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Gallery'),
                onTap: () {
                  _imgFromGallery(context);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  _imgFromCamera(context);
                  Navigator.of(context). pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _imgFromCamera(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      Navigator.of(context).pop();
    }
  }

  _imgFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Photo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showPicker(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            shape: CircleBorder(),
            padding: EdgeInsets.all(24),
          ),
          child: Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}