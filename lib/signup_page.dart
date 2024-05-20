import 'package:flutter/material.dart';
import 'login_page.dart';
class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color:Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ),

      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green, Colors.greenAccent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Sign up", style: TextStyle(color: Colors.white, fontSize: 50)),
                  SizedBox(height: 10),
                  Text("Create an account, It's free", style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(0, 10),
                          )]
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Username",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Email or Phone number",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!))
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(color: Colors.white),
                                  border: InputBorder.none
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Container(
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.green,
                                    Colors.greenAccent
                                  ]
                              ),
                            ),
                            child: Center(
                              child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
