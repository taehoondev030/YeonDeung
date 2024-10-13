import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../model/wish.dart';

class MyHopePage extends StatefulWidget {
  const MyHopePage({Key? key}) : super(key: key);

  @override
  State<MyHopePage> createState() => _MyHopePageState();
}

class _MyHopePageState extends State<MyHopePage> {

  late Future<List<Hope>> futureWishes;
  @override
  void initState() {
    super.initState();
    futureWishes = fetchWishes(); // 데이터 가져오기
  }

  Future<List<Hope>> fetchWishes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/wish/wishes/'));

    if (response.statusCode == 200) {
      // 서버로부터 받은 JSON 데이터를 리스트로 디코딩
      List<dynamic> body = jsonDecode(response.body);

      // JSON 리스트를 Wish 객체 리스트로 변환
      List<Hope> wishes = body.map((dynamic item) => Hope.fromJson(item)).toList();
      return wishes;
    } else {
      throw Exception('Failed to load wishes');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("내가 띄운 등불"),),
      body: Center(
        child: FutureBuilder<List<Hope>>(
          future: futureWishes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();  // 데이터 로딩 중일 때 로딩 표시
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');  // 에러 발생 시 표시
            } else if (snapshot.hasData) {
              // 데이터가 있을 때 리스트로 표시
              List<Hope> wishes = snapshot.data!;
              return ListView.builder(
                itemCount: wishes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    //title: Text(wishes[index].message),
                    subtitle: Text('Created at: ${wishes[index].date}'),
                  );
                },
              );
            } else {
              return Text('No data found');
            }
          },
        ),
      ),
    );
  }
}
