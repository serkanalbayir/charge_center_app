import 'package:flutter/material.dart';

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
  String selectedStation = "TR-ANK-037 Mengler, Ankara";
  List<String> comments = [];

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
            actionButton(context, Icons.support_agent, 'Get live support', () => _navigateToAddComment(context)),
            actionButton(context, Icons.check_circle_outline, 'Successful charge', () => _navigateToAddComment(context)),
            actionButton(context, Icons.report_problem, 'Report Issue', () => _navigateToAddComment(context)),
            actionButton(context, Icons.comment, 'Add Comment', () => _navigateToAddComment(context)),
            actionButton(context, Icons.add_a_photo, 'Add photo', () => _navigateToAddComment(context)),
            actionButton(context, Icons.edit, 'Edit information', () => _navigateToEditInformation(context)),
            ratingBar(),
          ],
        ),
      ),
    );
  }

  Widget actionButton(BuildContext context, IconData icon, String text, VoidCallback onPressed) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextButton.icon(
        icon: Icon(icon),
        label: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        onPressed: onPressed,
      ),
    );
  }

  Widget ratingBar() {
    int starRating = 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        backgroundColor: Colors.lightGreen,
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
                onSubmit(commentController.text);
                Navigator.pop(context); // Return to previous screen after submission
              },
              child: Text('Submit Comment'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen),
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
        backgroundColor: Colors.lightGreen,
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