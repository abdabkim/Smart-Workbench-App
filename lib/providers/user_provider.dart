import 'package:flutter/material.dart';

class User extends ChangeNotifier{
  String fullname = '';
  String email = '';
  String token = '';


  String getName() => fullname;

  void update(Map<String, dynamic>data){
    this.fullname=data['name'];
    this.email=data['email'];
    this.token=data['token'];
    notifyListeners();
  }
}
