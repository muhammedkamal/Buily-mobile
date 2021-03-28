import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/http_exceptions.dart';

class Auth with ChangeNotifier {
  String _token, _userId;
  DateTime _expiryTime;
  Timer _timer;
  bool isAuth() {
    return token != null;
  }

  String get token {
    if (_expiryTime != null &&
        _expiryTime.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<bool> tryLogIn() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedData =
        jsonDecode(prefs.getString('userData')) as Map<String, dynamic>;
    print(extractedData);
    final expiryTime = DateTime.parse(extractedData['expiryTime']);
    if (expiryTime.isBefore(DateTime.now())) return false;
    _expiryTime = expiryTime;
    _userId = extractedData['userId'];
    _token = extractedData['token'];
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> _authenticate(
      String email, String passowrd, String method) async {
    var url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$method?key=AIzaSyA0icqEmO7GXSKXB7Gm6OIY-KUufkq0Ch0');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': passowrd,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryTime = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      //print(responseData);
      notifyListeners();
      _autoLogOut();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryTime': _expiryTime.toIso8601String(),
      });
      print(userData);
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String passowrd) async {
    return _authenticate(email, passowrd, 'signUp');
  }

  Future<void> signIn(String email, String passowrd) async {
    return _authenticate(email, passowrd, 'signInWithPassword');
  }

  void logOut() {
    _userId = null;
    _expiryTime = null;
    _token = null;
    _timer.cancel();
    _timer = null;
    notifyListeners();
  }

  void _autoLogOut() {
    if (_timer != null) _timer.cancel();
    _timer = Timer(
        Duration(seconds: _expiryTime.difference(DateTime.now()).inSeconds),
        logOut);
  }
}
