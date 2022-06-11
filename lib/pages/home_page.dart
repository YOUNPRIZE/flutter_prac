import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;


import 'package:search/pages/search_page.dart';
import 'package:search/provider/myProvider.dart';
import 'package:search/main.dart';


// StatefulWidget
// State 객체를 갖는 Wideget
// State 객체의 setState method가 Widget의 상태 변화를 알려준다.
// Client의 조작으로 setState가 호출되면 Flutter가 Widget을 다시 그린다.

// StatefulWidget을 상속받는 Widget이 createState method로 State 객체를 return하고,
// State를 상속받는 객체가 build method로 Widget을 return하는 형태

class MyHomePage extends StatefulWidget {
  
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  /*  final colorList = <Color>[
    ThemeColor().red,
    ThemeColor().yellow,
    ThemeColor().green,
    ThemeColor().blue,
    ThemeColor().purple
  ];*/


  TextEditingController _textStream = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              
            }, 
            icon: Icon(Icons.logout))
        ],
      ),
      /*persistentFooterButtons: colorList
        .map<Widget>(
          (color) => GestureDetector(
            onTap: () {
              context.read<ThemeColor>().changeColor(color);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: 
                  BoxDecoration(shape: BoxShape.circle, color: color),
            )
          )
        ).toList(),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[
            const Text(
              '검색할 KEYWORD를 입력해주세요!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.0
                ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              width: 400.0,
              child: TextFormField(
                controller: _textStream,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  fillColor: Colors.black
                ),
              ),
            ),
            SizedBox(
              height: 32,
            ),
            FlatButton(
              onPressed: () async {
                if(_textStream.text.isEmpty) {
                  _showDialog("검색어가 입력되지 않았습니다.");
                }
                if(_textStream.text.isNotEmpty) {
                  try {
                    String url = await search(_textStream.text);
                    String text = await getContent(url);
                    try {
                      String last = await summary(text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(last)
                        )
                      );
                    } catch(e) {
                      _showDialog("기사 본문의 내용이 2,000자를 초과하였습니다.");
                    }
                  } catch(e) {
                    _showDialog("올바르지 않은 검색어입니다.");
                  }
                }
              }, 
              color: Colors.lightGreen,
              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        ),
              padding: EdgeInsets.all(20),
              child: Text("Search")
            ),
          ],
        ),
      ),
    );
  }

  // **Methods**
  // Naver search API -> return 값은 URL 주소
  Future<String> search(text) async {
    // API URL
    String _url = "https://openapi.naver.com/v1/search/news?query=$text&display=30";

    // Header 설정
    Map<String, String> header = {
      'X-Naver-Client-Id' : '',
      'X-Naver-Client-Secret' : '',
    };
    
    // URL 주소를 담을 변수 생성
    String result = '';

    // GET Request
    http.Response res = await http.get(Uri.parse(_url), headers: header);
    
    // json.decode(res.body)
    // {lastBuildDate: Thu, 09 Jun 2022 16:43:26 +0900, total: 0, start: 1, display: 0, items: []}
    // items: 공백이면 error 발생하므로 예외 처리

    // Naver 기사만 추출
    String naverNews =  "https://n.news.naver.com";
    for (int i = 0; i < 30; i++) {
      if (json.decode(res.body)['items'][i]['link'].contains(naverNews) == true) {
        result = json.decode(res.body)['items'][i]['link'];
        break;
      }
    }
    
    // URL 주소 return
    return result;
  }

  // search 메서드로부터 받은 URL에서 기사 본문 추출
  Future<String> getContent(str) async {

    Uri uri;

    uri = Uri.parse(str);

    // Request
    final response = await http.get(uri);

    // html parser
    final _document = html_parser.parse(response.body);

    // querySelector
    String contentText = _document.getElementsByClassName('go_trans _article_content')[0].text;

    // 공백 및 여백 제거
    String newText = contentText.replaceAll('\t', '');
    String finalText = newText.replaceAll('\n', '');

    // 기사 본문 return
    return finalText;
  }

  // CLOVA Summary API -> return 값은 요약된 본문 (3줄 요약)
  Future<String> summary(content) async {
    Uri uri;

    // API URL
    String _url = "https://naveropenapi.apigw.ntruss.com/text-summary/v1/summarize";
    
    uri = Uri.parse(_url);
    
    // Header 설정
    Map<String, String> _header = {
      "X-NCP-APIGW-API-KEY-ID" : "",
      "X-NCP-APIGW-API-KEY" : "",
      'Content-Type' : "application/json"
    };

    // POST body 설정
    final _body = {
      "document": {
        "content": '$content'
        //"content": "간편송금 이용금액이 하루 평균 2000억원을 넘어섰다. 한국은행이 17일 발표한 '2019년 상반기중 전자지급서비스 이용 현황'에 따르면 올해 상반기 간편송금서비스 이용금액(일평균)은 지난해 하반기 대비 60.7% 증가한 2005억원으로 집계됐다. 같은 기간 이용건수(일평균)는 34.8% 늘어난 218만건이었다. 간편 송금 시장에는 선불전자지급서비스를 제공하는 전자금융업자와 금융기관 등이 참여하고 있다. 이용금액은 전자금융업자가 하루평균 1879억원, 금융기관이 126억원이었다. 한은은 카카오페이, 토스 등 간편송금 서비스를 제공하는 업체 간 경쟁이 심화되면서 이용규모가 크게 확대됐다고 분석했다. 국회 정무위원회 소속 바른미래당 유의동 의원에 따르면 카카오페이, 토스 등 선불전자지급서비스 제공업체는 지난해 마케팅 비용으로 1000억원 이상을 지출했다. 마케팅 비용 지출규모는 카카오페이가 491억원, 비바리퍼블리카(토스)가 134억원 등 순으로 많았다."
        },
      "option": {"language": "ko", "model": "news"}
    };

    // POST Request
    http.Response res = await http.post(
      uri, 
      headers: _header,
      body: jsonEncode(_body)
    ); 

    // Response
    Map _result = json.decode(utf8.decode(res.bodyBytes));
    //{status: 400, error: {errorCode: E003, message: Text quota Exceeded}}
    //여기서 catch로 잡아야 함.

    String _summary = _result['summary'];

    // 공백 및 여백 제거
    String _final = _summary.replaceAll('\n', '');
    String newText = _final.replaceAll('\t', '');

    // 요약된 본문 return
    return newText;
  }

  // Alert Pop-up
  void _showDialog(string) { 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "⚠경고",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.0
              )
            ),
          content: new Text(string),
          actions: <Widget>[ 
            new FlatButton(
              color: Colors.lightGreen,
              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                        ),
              padding: EdgeInsets.all(15),
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

}
