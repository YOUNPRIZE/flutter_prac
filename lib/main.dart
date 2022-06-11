import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:search/pages/home_page.dart';
import 'package:search/provider/myProvider.dart';

void main() {
  runApp(MyApp());
  //runApp(MultiProvider(providers: [
    //ChangeNotifierProvider<ThemeColor>(create: (_) => ThemeColor())
  //], child: MyApp()));
}

class MyApp extends StatelessWidget {
  /*MyApp({Key? key}) : super(key: key);*/
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search',
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen
        //primaryColor: context.watch<ThemeColor>().color,
      ),
      
      /*home: const MyHomePage(title: 'Searching App'),*/
      home: MyHomePage(title: 'Searching App'),
    );
  }
}