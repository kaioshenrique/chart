import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chart/model/task.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class HomePage extends StatefulWidget {
  
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
  
}

class _HomePageState extends State<HomePage> {
  List<charts.Series<Task, String>> _seriesPieData;
  List<Task> mydata;
  _generateData(mydata) {
    _seriesPieData = List<charts.Series<Task, String>>();
    _seriesPieData.add(
      charts.Series(
        domainFn: (Task task, _) => task.taskDetails,
        measureFn: (Task task, _) => task.taskVal,
        colorFn: (Task task, _) => 
        charts.ColorUtil.fromDartColor(Color(int.parse(task.color))),
        id: 'tasks',
        data: mydata,
        labelAccessorFn: (Task task, _) => "${task.taskVal}"
      ),
    );
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks')),
      body: _createBody(context),
    );
  }

  Widget _createBody(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('task').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          List<Task> task = snapshot.data.documents
          .map((documentSnapshot) => Task.fromMap(documentSnapshot.data))
          .toList();
          return _createChart(context, task);
        }
      }
    );
  }

  Widget _createChart(BuildContext context, List<Task> task) {
    mydata = task;
    _generateData(mydata);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: Column(
            children: <Widget> [
              Text(
                'Daily Tasks',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: charts.PieChart(
                  _seriesPieData,
                  animate: true,
                  animationDuration: Duration(seconds: 5),
                  behaviors: [
                    new charts.DatumLegend(
                      outsideJustification: charts.OutsideJustification.endDrawArea,
                      horizontalFirst: false,
                      desiredMaxRows: 2,
                      cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0, top: 4.0),
                      entryTextStyle: charts.TextStyleSpec(
                        color: charts.MaterialPalette.purple.shadeDefault,
                        fontFamily: 'Roboto',
                        fontSize: 18)
                      ),
                  ],
                  defaultRenderer: new charts.ArcRendererConfig(
                    arcWidth: 100,
                    arcRendererDecorators: [
                      new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.inside)
                    ])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}