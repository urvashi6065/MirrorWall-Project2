import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class connection extends StatefulWidget {
  const connection({Key? key}) : super(key: key);

  @override
  State<connection> createState() => _connectionState();
}

class _connectionState extends State<connection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
         mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 50,),
            Text('Please Cheak Your Internet Connection')
          ],
        ),
      ),
    );
  }
}
