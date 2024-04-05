import 'package:animate_do/animate_do.dart';
import 'package:bitirme/main.dart';
import 'package:flutter/material.dart';

void main() => runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    )
);

class LoginPage extends StatelessWidget {


  void _loginAndNavigate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }


  @override



  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 70,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Container(
                      height: 110, // Logo yüksekliğinizi burada ayarlayabilirsiniz.
                      child: Image.asset('assets/aa.jpg'), // Logo dosya yolu burada kullanılacak.
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50,),
                      FadeInUp(duration: Duration(milliseconds: 1400), child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Color.fromRGBO(225, 255, 255, .3),
                                blurRadius: 1000,
                                offset: Offset(0, 10)
                            )]
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))
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
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white))
                              ),
                              child: TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: InputBorder.none
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      SizedBox(height: 30,),
                      FadeInUp(duration: Duration(milliseconds: 1500), child: Text("Forgot Password?", style: TextStyle(color: Colors.white),)),
                      SizedBox(height: 30,),
                      FadeInUp(duration: Duration(milliseconds: 1600), child: MaterialButton(
                        onPressed: () {},
                        height: 40,
                        // margin: EdgeInsets.symmetric(horizontal: 50),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),

                        ),
                        // decoration: BoxDecoration(
                        // ),
                        child: Center(
                          child: Text("Sign Up", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                        ),
                      )),
                      SizedBox(height: 20,),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FadeInUp(duration: Duration(milliseconds: 1800), child: MaterialButton(
                              onPressed: () => _loginAndNavigate(context),
                              height: 50,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Center(
                                child: Text("Login", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),
                              ),
                            )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

