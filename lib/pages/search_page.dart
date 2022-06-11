import 'package:flutter/material.dart';

// StatelessWidget을 상속받고, build라는 함수를 override한다.
class SearchPage extends StatelessWidget {
  //?
  final String summarizedText;

  // const Example({ Key? key }) : super(key: key);
  // constructr (생성자)
  // 기본생성자로써 Class명과 동일한 이름을 가진다.
  // super(key: key)는 부모인 StatelessWidget의 기본생성자를 호출하는 것.
  // 데이터를 전달할 Parameter가 없다면 기본생성자는 생략 가능.
  const SearchPage(this.summarizedText);

  @override
  // build
  // Widget을 리턴하는 함수로서 모든 위젯 클래스에 포함된 필수 메서드이다.
  // build가 리턴하는 Widget들로 View가 그려진다.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('검색 결과'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                '요약 : $summarizedText',
                style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.0
                ),
              ),
            )
          ]
        )
        //child: Text("요약 : $summarizedText")
        /*child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go Back!'),
        ),*/
      )
    );
  }
}