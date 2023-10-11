import 'dart:io';

import 'package:csv/csv.dart';
import 'package:ecosoftvmsstaff/modals/userclass.dart';
import 'package:ecosoftvmsstaff/services/services.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void exportdata(List<LogBook> listdata,context) async{
  Services firebaseservices= Services();
  List<List<dynamic>> data = List<List<dynamic>>.empty(growable: true);
  data.add(["Visitor Name","Company Name","Contact Details","Email Id","Purpose of Visit","In Time","Out Time"]);
  List<ExportDataform> alldata= [];
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  for(var a in listdata){
    List details= await firebaseservices.getlogpreview(a.id) as List<String>;
    String intime="";
    String outtime="";
    if(a.Checkedout==""){
      outtime="Still In";
    }else{
      List l = a.Checkedout.split('&');
      outtime=l[0]+" "+l[1];
    }
    List l1= a.Checkedin.split('&');
    intime=l1[0]+" "+l1[1];
    ExportDataform obj= ExportDataform(Name: a.VisitorName, CompanyName: details[1], phoneno: details[2], Purpose: details[3], Emailid: details[4], Indatetime: intime, Outdatetime: outtime);
    data.add([obj.Name,obj.CompanyName,obj.phoneno,obj.Emailid,obj.Purpose,obj.Indatetime,obj.Outdatetime]);
    alldata.add(obj);
  }
  String dir = (await getDownloadsDirectory())!.path + "/logreports.csv";
  String file = "$dir";
  File f = new File(file);
  String csv= ListToCsvConverter().convert(data);
  f.writeAsString(csv);
  //FloatingSnackBar(message: "Exported", context: context);



}