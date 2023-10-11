// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../modals/userclass.dart';

class Services{
  final FirebaseFirestore firestore=FirebaseFirestore.instance;
  Future<void> addStaff(Staff s) async{
    Map<String,dynamic> obj={
      "UserName": s.UserName,
      "EmailId": s.EmailId,
      "Phoneno": s.phoneno

    };
    String docId= s.UserName;
    final DocumentReference tasksRef=firestore.collection("Staff").doc(docId);
    await tasksRef.set(obj);
  }
  Future<void> checkout(String id) async{

    var currentdate= DateFormat("dd-MM-yyyy").format(DateTime.now());
    var currenttime = DateFormat.Hm().format(DateTime.now());

    final snapshot=await firestore.collection("Checked-In").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["id"]==id){
        Map<String,dynamic> obj={
          "VisitorName": element["VisitorName"],
          "CompanyName": element["CompanyName"],
          "Phoneno": element["Phoneno"],
          "Emailid": element["Emailid"],
          "Purpose": element["Purpose"],
          "id": element["id"],
          "Staff": element["Staff"],
          "checkedindatetime": element["checkedindatetime"],
          "checkedoutdatetime": "$currentdate&$currenttime"
        };
        final DocumentReference tasksref=firestore.collection("LogBook").doc(id+obj["checkedindatetime"]);
        await tasksref.set(obj);
        await FirebaseFirestore.instance.collection("Checked-In").doc(id).delete();
      }
    }

  }
  Future<void> addVisitor(Visitor newVisitor) async{

    var currentdate= DateFormat("dd-MM-yyyy").format(DateTime.now());
    var currenttime = DateFormat.Hm().format(DateTime.now());
    Map<String,dynamic> obj={
      "VisitorName": newVisitor.Name,
      "CompanyName": newVisitor.CompanyName,
      "Phoneno": newVisitor.phoneno,
      "Emailid": newVisitor.EmailId,
      "Purpose": newVisitor.Purpose,
      "id": newVisitor.id,
      "aadharnumber": newVisitor.aadharnumber,
      "requesteddatetime": "$currentdate&$currenttime",
      "Staff": newVisitor.staff
    };
    Map<String,dynamic> obj2={
      "VisitorName": newVisitor.Name,
      "CompanyName": newVisitor.CompanyName,
      "Phoneno": newVisitor.phoneno,
      "Emailid": newVisitor.EmailId,
      "aadharnumber": newVisitor.aadharnumber,
      "id": newVisitor.id,
      "lastvisit": currentdate
    };

    String docId= newVisitor.id;
    final DocumentReference tasksRef=firestore.collection("Requested").doc(docId);
    final DocumentReference tasksRef2=firestore.collection("AllVisitors").doc(docId);
    await tasksRef.set(obj);
    await tasksRef2.set(obj2);
  }

  Future<List> readVisitors() async{
    List<Visitor> visitors=[];
    final snapshot=await firestore.collection("AllVisitors").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      visitors.add(Visitor(Name: element["VisitorName"],aadharnumber: element["aadharnumber"], CompanyName: element["CompanyName"], phoneno: element["Phoneno"], EmailId: element["Emailid"], Purpose:"", id: element["id"],staff: ""));
    }
    return visitors;


  }
  Future<List> getstaffreq(String StaffName) async{
    List<Requests> v= [];
    final snapshot = await firestore.collection("Requested").get();
    final List<DocumentSnapshot> documents=snapshot.docs;
    for(DocumentSnapshot s in documents){
      if(s["Staff"]==StaffName){
        v.add(Requests(ReqTime: s["requesteddatetime"],Name: s["VisitorName"], CompanyName: s["CompanyName"], phoneno: s["Phoneno"], EmailId: s["Emailid"], Purpose: s["Purpose"], id: s["id"], staff: s["Staff"]));}
    }
    return v;


  }

  Future<void> denyreq(Requests visitor) async{

    String docId= visitor.Name+visitor.phoneno;
    await FirebaseFirestore.instance.collection("Requested").doc(docId).delete();


  }
  Future<List> gecheckin() async{
    List<LogBook> temp= [];
    final snapshot = await firestore.collection("Checked-In").get();
    final List<DocumentSnapshot> documents= snapshot.docs;
    for(DocumentSnapshot s in documents){
      temp.add(LogBook(VisitorName: s["VisitorName"], Purpose: s["Purpose"],Checkedin: s["checkedindatetime"], Checkedout: "Still in", id: s["id"]));
    }
    return temp;
  }

  Future<void> checkin(Requests newVisitor) async{

    var currentdate= DateFormat("dd-MM-yyyy").format(DateTime.now());
    var currenttime = DateFormat.Hm().format(DateTime.now());
    Map<String,dynamic> obj={
      "VisitorName": newVisitor.Name,
      "CompanyName": newVisitor.CompanyName,
      "Phoneno": newVisitor.phoneno,
      "Emailid": newVisitor.EmailId,
      "Purpose": newVisitor.Purpose,
      "id": newVisitor.id,
      "checkedindatetime": "$currentdate&$currenttime",
      "Staff": newVisitor.staff
    };
    String docId= newVisitor.id;
    Map<String,dynamic> obj2={
      "VisitorName": newVisitor.Name,
      "CompanyName": newVisitor.CompanyName,
      "Phoneno": newVisitor.phoneno,
      "Emailid": newVisitor.EmailId,
      "Purpose": newVisitor.Purpose,
      "id": newVisitor.id,
      "checkedindatetime": "$currentdate&$currenttime",
      "checkedoutdatetime": "",
      "Staff": newVisitor.staff
    };
    final DocumentReference tasksRef=firestore.collection("Checked-In").doc(docId);
    await tasksRef.set(obj);

    final DocumentReference tasksRef2=firestore.collection("LogBook").doc(docId+obj2["checkedindatetime"]);
    await tasksRef2.set(obj2);
    await FirebaseFirestore.instance.collection("Requested").doc(docId).delete();
  }
  Future<List> getstafflog(String Staffname) async{
    List<LogBook> logs=[];
    final snapshot = await firestore.collection("LogBook").get();
    final List<DocumentSnapshot> documents=snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["Staff"]==Staffname){
        logs.add(LogBook(VisitorName: element["VisitorName"], Purpose: element["Purpose"],Checkedin: element["checkedindatetime"], Checkedout: element["checkedoutdatetime"], id: element["id"]));
      }
    }
    return logs;

  }
  Future<String> getemail(String staff) async{
    String temp="";
    final snapshot = await firestore.collection("Staff").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["UserName"]==staff){
        temp=element["EmailId"];
      }
    }
    return temp;
  }

  Future<List> getallstaff() async{
    List<Staff> staffs=[];
    final snapshot=await firestore.collection("Staff").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      staffs.add(Staff(EmailId: element["EmailId"], UserName: element["UserName"],phoneno: element["Phoneno"]));
    }
    return staffs;
  }
  Future<List> getlogpreview(String id) async{
    List<String> temp=[];
    final snapshot = await firestore.collection("LogBook").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["id"]==id){
        temp=[element["VisitorName"],element["CompanyName"],element["Phoneno"],element["Purpose"],element["Emailid"]];

      }
    }
    return temp;


  }

  Future<Staff> getprofile(String email) async{
    Staff s = Staff(EmailId: "Loading..", UserName: "loading..", phoneno: "Loading..");
    final snapshot = await firestore.collection("Staff").get();
    final List<DocumentSnapshot> documents = snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["EmailId"]==email){
        s= Staff(EmailId: element["EmailId"], UserName: element["UserName"], phoneno: element["Phoneno"]);

      }
    }
    return s;
  }
  Future<List> validqr(String id) async{
    List temp=[false,null];
    final snapshot=await firestore.collection("Checked-In").get();
    final List<DocumentSnapshot> documents=snapshot.docs;
    for(DocumentSnapshot element in documents){
      if(element["id"]==id){
        temp=[true,Visitor(Name: element["VisitorName"],aadharnumber: "", CompanyName: element["CompanyName"], phoneno: element["Phoneno"], EmailId: element["Emailid"], Purpose:"", id: element["id"],staff: element["Staff"])];
      }
    }
    return temp;
  }
}