import 'dart:convert';

import 'package:http/http.dart' as http;

class Pagella{
  String titolo;
  String html;

  Pagella({
    required this.titolo,
    required this.html,
  });

   static Future<Pagella> fromJson(Map<String, dynamic> json) async {
    return Pagella(
      titolo: json['desc'],
      html: await getHtml(json['viewLink']),
    );
  }

  static Future<String> getHtml(String url) async {
    final response = await http.get(
      Uri.parse(url),
    );
    if(response.statusCode == 200){

      return response.body;
    }else{
      return "";
    }
  }

  static Future<List<Pagella>> fromJsonList(List<dynamic> json) async {
    List<Pagella> pagelle = [];
    for (var item in json) {
      pagelle.add(await fromJson(item));
    }
    return pagelle;
  }

}