import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class User extends ChangeNotifier{
  String fullname = '';
  String email = '';
  String token = '';
  // User({
  //   required this.fullname,
  //   required this.email,
  //   required this.token,
  // });
  //
  // factory User.fromMap(Map<String, dynamic>data){
  //   return User(fullname: data['name'] ?? '', email: data['email'] ?? '', token: data['token'] ?? '');
  // }

  String getName() => fullname;

  void update(Map<String, dynamic>data){
    this.fullname=data['name'];
    this.email=data['email'];
    this.token=data['token'];
    notifyListeners();
  }
}
