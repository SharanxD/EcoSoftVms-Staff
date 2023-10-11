// ignore_for_file: file_names, use_build_context_synchronously, prefer_interpolation_to_compose_strings
import 'dart:async';

import 'package:ecosoftvmsstaff/services/exportmodal.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../modals/userclass.dart';
import '../services/services.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key,required this.log});

  final List<LogBook> log;

  @override
  State<LogScreen> createState() => _LogScreenState();
}
DateTime parseDate(String date){
  List a = date.split('&');
  List l = a[0].split('-');
  int day= int.tryParse(l[0])!;
  int month= int.tryParse(l[1])!;
  int year= int.tryParse(l[2])!;
  DateTime d= DateTime(year,month,day);
  return d;
}

String getdate(String checkedin){
  String temp="";
  if(checkedin==""){
    //print("hello");
    return checkedin;
  }
  List arr1= checkedin.split('&');
  temp= arr1[0]+" "+arr1[1];
  return temp;
}
class _LogScreenState extends State<LogScreen> {

  var filtername= TextEditingController();
  var fromdate = TextEditingController();
  var todate = TextEditingController();

  List<String> details =["Loading","Loading","Loading","Loading","Loading","Loading","Loading"];
  int selectedindex=-1;
  int visible=-1;

  List<LogBook> filtered=[];
  Future<void> filter()async{
    setState(() {
      filtered=widget.log;
    });
    if(filtername.text=="" && fromdate.text=="" && todate.text==""){
      setState(() {
        filtered=widget.log;
      });
    }
    else{
      if(fromdate.text!="" || todate.text!=""){
        filtered=[];
        String start= fromdate.text;
        String end= todate.text;
        if(fromdate.text==""){
          start= '01-01-1990';
        }
        if(todate.text==""){
          setState(() {
            end=DateFormat("dd-MM-yyyy").format(DateTime.now());
          });
        }
        List<LogBook> temp=[];
        for(LogBook l in widget.log){
          String out="";
          if(l.Checkedout==""){
            setState(() {
              out= "${DateFormat("dd-MM-yyyy").format(DateTime.now())}&${DateFormat.Hm().format(DateTime.now())}";
            });
          }else{
            out= l.Checkedout;
          }
          if(parseDate(l.Checkedin).isAfter(parseDate(start)) && parseDate(out).isBefore(parseDate(end)) || parseDate(l.Checkedin)==parseDate(start) || (parseDate(out)==parseDate(end))){
            temp.add(l);
          }
        }
        for(var a in temp) {
          if (!filtered.contains(a)) {
            filtered.add(a);
          }
        }
      }else if (fromdate.text==""&& todate.text==""){
        setState(() {
          filtered=widget.log;
        });

      }
      if(filtername.text!=""){
        List<LogBook> temp=[];
        for(LogBook l in filtered){
          if(l.VisitorName.toLowerCase().contains(filtername.text.toLowerCase())){
            temp.add(l);
          }
        }
        setState(() {
          filtered=temp;
        });
      }

    }

  }
  @override
  void initState(){
    setState(() {
      filtered=widget.log;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: (){
                    showDialog(context: context, builder: (BuildContext context){
                      bool visible=true;
                      return AlertDialog(
                        backgroundColor: Colors.grey.shade100,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        title: Text("Choose Filters",style: GoogleFonts.questrial(fontSize: 32,fontWeight: FontWeight.bold),),
                        content: SizedBox(
                          width: size.width*0.9,
                          height: size.height*0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Filter by Name",style: GoogleFonts.questrial(fontSize: 24),),
                              Container(
                                height: 55,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                    color: Colors.white

                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.search,size: 30,color: Colors.grey,),
                                    Padding(
                                      padding: const EdgeInsets.only(left:20.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: size.width*0.5,
                                            child: TextField(
                                              controller: filtername,
                                              style: GoogleFonts.questrial(fontSize: 24),
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Enter Name",
                                                  hintStyle: GoogleFonts.questrial(fontSize: 24,color: Colors.grey)

                                              ),

                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text("Filter by Date",style: GoogleFonts.questrial(fontSize: 24),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(width: size.width*0.33,height: 50,decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white
                                  ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:4.0,right:4),
                                      child: Center(
                                        child: TextField(
                                          controller: fromdate,
                                          readOnly: true,
                                          onTap: ()async{
                                            DateTime? pickedDate3 = await showDatePicker(

                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1990),
                                                lastDate: DateTime.now());
                                            if(pickedDate3!=null){
                                              String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate3);
                                              setState(() {
                                                fromdate.text=formattedDate;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "From Date",
                                              hintStyle: GoogleFonts.questrial(fontSize: 24,color: Colors.grey)
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: visible,
                                    child: Container(width: size.width*0.33,height: 50,decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: Colors.white
                                    ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:4.0,right:4),
                                        child: Center(
                                          child: TextField(
                                            controller: todate,
                                            readOnly: true,
                                            onTap: ()async{
                                              DateTime? pickedDate2 = await showDatePicker(

                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1990),
                                                  lastDate: DateTime.now());
                                              if(pickedDate2!=null){
                                                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate2);
                                                setState(() {
                                                  todate.text=formattedDate;
                                                });

                                              }


                                            },
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "To Date",
                                                hintStyle: GoogleFonts.questrial(fontSize: 24,color: Colors.grey)
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              SizedBox(
                                width: size.width*0.8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Reset to Default?",style: GoogleFonts.questrial(fontSize: 24,color: Colors.black),),
                                    IconButton(onPressed: (){
                                      setState(() {
                                        filtername.clear();
                                        fromdate.clear();
                                        todate.clear();
                                      });

                                    }, icon: const Icon(Icons.restart_alt,size: 30,),style: ElevatedButton.styleFrom(backgroundColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),)
                                  ],
                                ),
                              ),




                            ],
                          ),
                        ),
                        actions: [
                          GestureDetector(
                            onTap: ()async{
                              await filter();
                              Navigator.pop(context);
                              //FloatingSnackBar(message: "Filter Applied", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                            },
                            child: Container(
                              width: size.width * 0.2,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[500]!,
                                        blurRadius: 10,
                                        offset: const Offset(4, 4),
                                        spreadRadius: 0.5),
                                    const BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 10,
                                        offset: Offset(-5, -5),
                                        spreadRadius: 1)
                                  ]),
                              child: Center(
                                  child: Text(
                                    "Apply",
                                    style: GoogleFonts.questrial(
                                        fontSize: 24,
                                        color: Colors.grey.shade200,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: size.width * 0.2,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[500]!,
                                        blurRadius: 10,
                                        offset: const Offset(4, 4),
                                        spreadRadius: 0.5),
                                    const BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 10,
                                        offset: Offset(-5, -5),
                                        spreadRadius: 1)
                                  ]),
                              child: Center(
                                  child: Text(
                                    "No",
                                    style: GoogleFonts.questrial(
                                        fontSize: 24,
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),
                        ],

                      );
                    });
                  },
                  child: Container(
                    width: size.width*0.4,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                          ),
                          BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.filter_list,color: Colors.black,size: 30,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Filter Reports",style: GoogleFonts.questrial(fontSize: 26,fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    exportdata(filtered,context);
                  },
                  child: Container(
                    width: size.width*0.4,
                    height: 60,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                          ),
                          BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                        ],
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.import_export,color: Colors.black,size: 30,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text("Export Data",style: GoogleFonts.questrial(fontSize: 26,fontWeight: FontWeight.bold),),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40,),
          Container(
            width: size.width*0.9,
            height: size.height*0.66,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                  ),
                  BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                ]

            ),
            child: widget.log.isEmpty?Center(child: Text("No Visitors yet..",style: GoogleFonts.questrial(color: Colors.grey,fontSize: 32),)):filtered.isEmpty?Center(child: Text("No such Reports..",style: GoogleFonts.questrial(color: Colors.grey,fontSize: 32),)):ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: filtered.length,
                itemBuilder: (BuildContext context,int index){
                  return GestureDetector(
                    onTap: ()async{
                      Services firebaseservices= Services();
                      List<String> temp = await firebaseservices.getlogpreview(filtered[index].id) as List<String>;
                      setState((){
                        details=temp;
                        if(selectedindex!=index){
                          selectedindex=index;
                        }else{
                          selectedindex=-1;
                        }
                      });
                      //preview(filtered[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        //duration: const Duration(milliseconds: 500),
                        width: size.width*0.9,
                        height: selectedindex==index?300:100,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: const BorderRadius.all(Radius.circular(20))
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: selectedindex==index?CrossAxisAlignment.start:CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left:10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                          width: size.width*0.24,
                                          height: size.height*0.04,
                                          child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(filtered[index].VisitorName,style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 28),))),
                                      Container(height:2,width: size.width*0.25,color: Colors.black,),
                                      Text(filtered[index].Purpose,style: GoogleFonts.questrial(fontSize: 20),)

                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.only(right:10.0),
                                  child: SizedBox(
                                    width: size.width*0.55,
                                    height: 100,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [

                                              Text("Checked-In: ",style: GoogleFonts.questrial(fontSize: 20,fontWeight: FontWeight.bold),),
                                              Text(getdate(filtered[index].Checkedin),style: GoogleFonts.questrial(fontSize: 20),),
                                            ],
                                          ),
                                          Row(
                                            children: [

                                              Text("Checked-Out: ",style: GoogleFonts.questrial(fontSize: 20,fontWeight: FontWeight.bold),),
                                              Text(getdate(filtered[index].Checkedout)==""?"Still In":getdate(filtered[index].Checkedout),style: GoogleFonts.questrial(fontSize: 20),),
                                            ],
                                          )

                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Visibility(
                                visible: selectedindex==index,
                                child: SizedBox(
                                  height: 200,
                                  width: size.width,
                                  child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      Text("Company Name: ",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 24),),
                                      Text(details[1],style: GoogleFonts.questrial(fontSize: 24)),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top:10.0,bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [

                                        Text("Phone no: ",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 24),),
                                        Text(details[2],style: GoogleFonts.questrial(fontSize: 24)),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom:10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Email-Id: ",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 24),),
                                        SizedBox(
                                            width:size.width*0.5,
                                            child: SingleChildScrollView(scrollDirection:Axis.horizontal,child: Text(details[4],style: GoogleFonts.questrial(fontSize: 24)))),
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Purpose: ",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 24),),
                                    Text(filtered[index].Purpose,style: GoogleFonts.questrial(fontSize: 24)),
                                  ],
                                ),
                              ],
                            ),
                                ))

                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
