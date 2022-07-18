import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../pages/order_detail_page.dart';
import 'package:flutter_session/flutter_session.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List users = [];
  bool isLoading = false;
  String siteUrl = "";

  @override
  void initState(){
    super.initState();
    getSessionDetails();
    fetchUser();
  }

  getSessionDetails() async{
    //setState(() async {
    siteUrl = await FlutterSession().get("site_url");
    //});

    print("URL"+siteUrl.toString());
    // token = await FlutterSession().get("token");
  }

  fetchUser() async{
    setState(() {
      isLoading = true;
    });
    print("fetching.......");

    // var url = "https://randomuser.me/api/?results=10";
    // var response = await http.get(Uri.parse(url));
    // if (response.statusCode == 200) {
    //   print(response.body);
    //   var items = json.decode(response.body)['results'];
    //   print (items);
    //   users = items;
    // }

    String basicAuth = "token 7c8964dcbfd0d56:71a57dff3e276c8";
    //request.headers.addAll(headers);
    var headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };
    var url = 'http://192.168.83.177:8000/api/resource/Purchase Order?fields=["name", "supplier","total_qty","grand_total"]';
    var request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();


    //print(response.statusCode);
    if (response.statusCode == 200) {
      final apiRespStr = await response.stream.bytesToString();
      print(apiRespStr);
      var items = json.decode(apiRespStr)['data'];
      print(items);
      setState(() {
        users = items;
        isLoading = false;
      });
      print(users);
    }else{
      setState(() {
        users = [];
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/pages.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title : const Center( child: Text("Orders")),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: (){
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const HomePage()),
                  // );
                  //Navigator.pop(context);
                },
                icon: const Icon(Icons.account_circle_outlined)
            ),
            IconButton(
                onPressed: (){
                  //FlutterSession().set('token', '');
                  Navigator.pushNamed(context, 'login');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const HomePage()),
                  // );
                  //Navigator.pop(context);
                },
                icon: const Icon(Icons.power_settings_new_sharp)
            ),
          ],
        ),
        body: getBody(),
      ),
    );
  }

  Widget getBody() {
    if(users.contains(null) || users.length < 0 || isLoading ){
      return Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),));
    }

    print(users.length);
    var len = users.length;
    return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index){
      return getCard(users[index]);//Text("test $index");
    });
  }

  Widget getCard(index) {
    var docName = index['name'];
    var supplier = index['supplier'];
    double totalQty = index['total_qty'];
    var grandTotal = index['grand_total'];
    print(docName);
    return Card(
      color: Colors.blueGrey.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          trailing: Icon(Icons.arrow_forward_rounded),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> OrderDetailPage(docName: docName)));
          },
          title: Row(
            children: <Widget>[
              // Container(
              //   width: 60,
              //   height: 60,
              //   // decoration: BoxDecoration(
              //   //   color: Colors.blue.withOpacity(0.4),
              //   // ),
              // ),
              //SizedBox(height: 20,),
              Column(
                children: <Widget>[
                  Text(
                    docName,
                    style: TextStyle(
                      color : Colors.black,
                    ),
                  ),
                  //SizedBox(height: 20,),
                  Text(supplier.toString(),
                    style: const TextStyle(
                      color : Colors.black,
                      fontSize: 10,
                    ),
                  ),
                  Text('Qty: '+totalQty.toString()+'   Grand Total:' + grandTotal.toString(),
                    style: const TextStyle(
                      color : Colors.black,
                      fontSize: 12,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
