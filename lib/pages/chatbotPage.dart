import 'dart:collection';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';

import '../utils/constant.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'cordlessFour.dart';

final messageController = TextEditingController();
List<Map> messages = [];
final focusNode = FocusNode();
double containerHeight = 500;
var prevIntents = ListQueue(3);

void response(query) async {
  DialogAuthCredentials credentials = await DialogAuthCredentials.fromFile("assets/hilti.json");
  DialogFlowtter instance = DialogFlowtter(
    credentials: credentials,
  );
  QueryInput queryInput = QueryInput(
    text: TextInput(
      text: query,
      languageCode: "en",
    ),
  );

  DetectIntentResponse response = await instance.detectIntent(
    queryInput: queryInput,
  );

  String? selectedMessage = response.text;
  String? intentName = response.queryResult?.intent?.displayName;

  if (prevIntents.length == 3){
    prevIntents.removeFirst();
  }
  prevIntents.add(intentName);

  if (prevIntents.every((var element) => element == "Default Fallback Intent")) {
    messages.insert(0, {"data": 0, "message": "It seems like I may not be able to help you. You could contact us at myhilti@hilti.com for further assistance."});
  } else {
    messages.insert(0, {"data": 0, "message": selectedMessage});
  }
  print(prevIntents);

}

GestureDetector enableChatbot(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Container(
        color: hiltiRed,
        height: getScreenHeight(context) * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(left: getScreenHeight(context) * 0.05),
              child: Center(child: hiltiLogo(context, 0.5)),
            )),
            IconButton(
                icon: Icon(Icons.close),
                color: hiltiWhite,
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
      content: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
          width: getScreenWidth(context) * 0.95,
          height: containerHeight,
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: messages.length,
                      reverse: true,
                      itemBuilder: (context, index) => chat(
                          context,
                          messages[index]["message"].toString(),
                          messages[index]["data"]))),
              ListTile(
                title: Container(
                    height: getScreenHeight(context) * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromRGBO(220, 220, 220, 1),
                    ),
                    child: TextFormField(
                      controller: messageController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: "Type your question...",
                        hintStyle: TextStyle(color: Colors.black26),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: "Helvetica",
                      ),
                      cursorColor: Colors.black26,
                    )),
                trailing: Container(
                  width: getScreenWidth(context) * 0.08,
                  child: IconButton(
                    icon: Icon(Icons.send),
                    iconSize: getScreenHeight(context) * 0.04,
                    onPressed: () {
                      if (messageController.text.isEmpty) {
                        print("Empty message");
                      } else {
                        messages.insert(
                            0, {"data:": 1, "message": messageController.text});
                        response(messageController.text);
                        messageController.clear();
                      }
                      FocusScope.of(context).unfocus();
                      Future.delayed(Duration(milliseconds: 2000), () {
                        FocusScope.of(context).requestFocus(focusNode);
                      });
                    },
                  ),
                ),
              ),
            ],
          )),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: hiltiWhite,
      elevation: 10,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 20.0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      scrollable: true,
      insetPadding: EdgeInsets.all(24.0),
    ),
  );
}

Container chat(BuildContext context, String message, int data) {
  return Container(
      padding: EdgeInsets.symmetric(horizontal: getScreenWidth(context) * 0.05),
      child: data == 0
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: getScreenHeight(context) * 0.05,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("assets/images/robot.jpg"),
                  ),
                ),
                message.contains(
                        "Home Page > Cordless Tools > Cordless Drill Drivers & Screwdrivers > Cordless Drill Driver")
                    ? Column(children: [
                        chatBubble(context, message, data),
                        SizedBox(
                          height: getScreenHeight(context) * 0.01,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => cordlessFour()));
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1.0)),
                            child: Row(
                              children: [
                                Image.asset(
                                    "assets/images/drill_drivers/sf_4.jpg",
                                    width: getScreenWidth(context) * 0.1),
                                SizedBox(width: getScreenWidth(context) * 0.05),
                                Container(
                                    constraints: BoxConstraints(
                                        maxWidth: getScreenWidth(context) * 0.3),
                                    child:
                                        Text("SF 4-A22 Cordless Drill Driver")),
                              ],
                            ),
                          ),
                        ),
                      ])
                    : chatBubble(context, message, data)
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                chatBubble(context, message, data),
                Container(
                  height: getScreenHeight(context) * 0.05,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage("assets/images/default.jpg"),
                  ),
                ),
              ],
            ));
}

Padding chatBubble(BuildContext context, String message, int data) {
  return Padding(
      padding: EdgeInsets.all(getScreenWidth(context) * 0.01),
      child: Bubble(
          radius: Radius.circular(10),
          color: data == 0 ? hiltiRed : Colors.grey[700],
          child: Padding(
              padding: EdgeInsets.all(getScreenWidth(context) * 0.01),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                        constraints: BoxConstraints(
                            maxWidth: getScreenWidth(context) * 0.45),
                        child: Text(
                          message,
                          style: TextStyle(
                            fontFamily: "Helvetica",
                            color: Colors.white,
                          ),
                        )),
                  )
                ],
              ))));
}
