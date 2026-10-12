import 'package:flutter/material.dart';
import 'package:wp_json_api/exceptions/invalid_credentials_exception.dart';
import 'package:wp_json_api/exceptions/invalid_user_token_exception.dart';
import 'package:wp_json_api/exceptions/login_blocked_exception.dart';
import 'package:wp_json_api/exceptions/too_many_attempts_exception.dart';
import 'package:wp_json_api/exceptions/wp_network_exception.dart';
import 'package:wp_json_api/exceptions/wp_server_exception.dart';
import 'package:wp_json_api/models/responses/wp_user_info_response.dart';
import 'package:wp_json_api/models/responses/wp_user_login_response.dart';
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
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _tfLoginController = TextEditingController();
  TextEditingController _tfPasswordController = TextEditingController();
  String _status = "";

  @override
  void initState() {
    super.initState();

    // INSTALL THE WP JSON API PLUGIN (v5.0 OR LATER)
    // FIRST ON YOUR WORDPRESS STORE
    // LINK https://woosignal.com/plugins/wordpress/wp-json-api

    WPJsonAPI.instance.init(baseUrl: "https://mysite.com");
  }

  _setStatus(String status) {
    setState(() => _status = status);
  }

  _login() async {
    // The user can enter their username or email
    String login = _tfLoginController.text;
    String password = _tfPasswordController.text;

    // LOGIN
    WPUserLoginResponse wpUserLoginResponse;
    try {
      wpUserLoginResponse = await WPJsonAPI.instance.api((request) =>
          request.wpLogin(
              login: login, password: password, deviceName: "Example app"));
    } on InvalidCredentialsException {
      _setStatus("The login details are incorrect");
      return;
    } on LoginBlockedException catch (e) {
      // e.g. a two-factor or login limiter plugin stopped the login
      _setStatus(e.message);
      return;
    } on TooManyAttemptsException catch (e) {
      _setStatus("Too many attempts, try again in ${e.retryAfter ?? 60}s");
      return;
    } on WPNetworkException {
      _setStatus("Check your internet connection");
      return;
    } on WPServerException catch (e) {
      _setStatus(e.message);
      return;
    } on Exception catch (e) {
      _setStatus(e.toString());
      return;
    }

    print(wpUserLoginResponse.data?.token);
    print(wpUserLoginResponse.data?.expiresAtDateTime);
    print(wpUserLoginResponse.data?.user?.id);

    // GET USER INFO
    try {
      WPUserInfoResponse wpUserInfoResponse =
          await WPJsonAPI.instance.api((request) => request.wpGetUserInfo());

      _setStatus("Hello ${wpUserInfoResponse.data?.firstName ?? ""}");
    } on InvalidUserTokenException {
      // The token expired or was revoked, ask the user to login again
      await WPJsonAPI.instance.api((request) => request.wpLogout());
      _setStatus("Please login again");
    }
  }

  _logout() async {
    // Revokes the token on the server and clears it from the device
    await WPJsonAPI.instance.api((request) => request.wpLogout());
    _setStatus("Logged out");
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
              controller: _tfLoginController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Username or email"),
            ),
            TextField(
              controller: _tfPasswordController,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),
            MaterialButton(
              child: Text("Login"),
              onPressed: _login,
            ),
            MaterialButton(
              child: Text("Logout"),
              onPressed: _logout,
            ),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
