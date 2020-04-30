import 'package:flutter/material.dart';
import 'package:wp_json_api/enums/WPAuthType.dart';
import 'package:wp_json_api/models/responses/WPUserInfoResponse.dart';
import 'package:wp_json_api/models/responses/WPUserLoginResponse.dart';
import 'package:wp_json_api/wp_json_api.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WooSignal Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'WooSignal Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _tfEmailController;
  TextEditingController _tfPasswordController;

  @override
  void initState() {
    super.initState();

    // INSTALL THE WP JSON API PLUGIN
    // FIRST ON YOUR WORDPRESS STORE
    // LINK https://woosignal.com/plugins/wordpress/wpapp-json-api

    WPJsonAPI.instance.initWith(baseUrl: "http://mysite.com");

    _tfEmailController = TextEditingController();
    _tfPasswordController = TextEditingController();
  }

  _login() async {
    String email = _tfEmailController.text;
    String password = _tfPasswordController.text;

    // LOGIN
    WPUserLoginResponse wpUserLoginResponse =
        await WPJsonAPI.instance.api((request) {
      return request.wpLogin(
          email: email, password: password, authType: WPAuthType.WpEmail);
    });

    if (wpUserLoginResponse != null) {
      print(wpUserLoginResponse.data.userToken);
      print(wpUserLoginResponse.data.userId);

      // GET USER INFO
      WPUserInfoResponse wpUserInfoResponse =
          await WPJsonAPI.instance.api((request) {
        return request.wpGetUserInfo(wpUserLoginResponse.data.userToken);
      });

      if (wpUserInfoResponse != null) {
        print(wpUserInfoResponse.data.firstName);
        print(wpUserInfoResponse.data.lastName);
      } else {
        print("something went wrong");
      }
    } else {
      print("invalid login details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _tfEmailController,
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _tfPasswordController,
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
            MaterialButton(
              child: Text("Login"),
              onPressed: _login,
            )
          ],
        ),
      ),
    );
  }
}
