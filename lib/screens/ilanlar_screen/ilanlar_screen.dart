import 'package:flutter/material.dart';
import 'package:takasla/constants.dart';
import 'package:takasla/notifiers/user_notifier.dart';
import 'package:provider/provider.dart';

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class IlanlarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserNotifier userNotifier =
        Provider.of<UserNotifier>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
      title: Text(
        "İlanlar",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
      ),
      leading: InkWell(
        splashColor: kPrimaryColor,
        borderRadius: BorderRadius.circular(60),
        onTap: () {
          /*Navigator.of(context)
                .push(MaterialPageRoute(builder: (BuildContext context) {
              return ProfilePage();
            })); */
        },
        child: Padding(
          padding: EdgeInsets.all(14),
          child: CircleAvatar(
            backgroundImage: NetworkImage(userNotifier.CurrentUser!.photoUrl!),
          ),
        ),
      ),
    ));
  }
}
