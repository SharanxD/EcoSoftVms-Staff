
import 'package:ecosoftvmsstaff/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../modals/userclass.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class StaffDashBoard extends StatefulWidget {
  const StaffDashBoard({super.key});

  @override
  State<StaffDashBoard> createState() => _StaffDashBoardState();
}

class _StaffDashBoardState extends State<StaffDashBoard> {
  int reqcount=0;
  int visitorscheckedin=0;
  int requestspending=0;
  final Services _s=Services();
  bool logbookvisible=false;
  var filtername = TextEditingController();
  List<Requests> req=[];
  List<LogBook> log=[];
  List<LogBook> check=[];
  final TextEditingController _emailcontroller= TextEditingController();
  TextEditingController datecontroller = TextEditingController();
  bool emailgiven=false;
  //NotificationApi notificationApi = NotificationApi();
  Future<void> getlog() async{
    List<LogBook> temp= await _s.getstafflog(FirebaseAuth.instance.currentUser!.displayName!) as List<LogBook>;
    List<LogBook> temp2=[];
    if(mounted){

      setState(() {
        log=temp;

        log.sort((a,b)=> b.Checkedin.compareTo(a.Checkedin));
      });
    }
    for(var a in temp){
      if(a.Checkedout==""){
        temp2.add(a);
      }
    }
    if(mounted){
      setState(() {
        check=temp2;
      });

    }
  }
  Future<void> getreq() async{
    List<Requests> temp= await _s.getstaffreq(FirebaseAuth.instance.currentUser!.displayName!) as List<Requests>;
    if(mounted){

      setState(() {
        req=temp;
        req.sort((a,b)=> b.ReqTime.compareTo(a.ReqTime));

      });
    }

  }
  Future<void> sendapprovedmail(String email,String Name) async{
    final Staffname = FirebaseAuth.instance.currentUser!.displayName;
    String token="wbzu hfiq oyad sftv";
    final smtpServer = gmail('testsptest223@gmail.com',token);

    final message1 = Message()
      ..from = Address(FirebaseAuth.instance.currentUser!.email.toString())
      ..recipients.add(email)
      ..subject = 'Appointment Approved'
      ..text= ""
      ..html = "Hello $Name\n, Your appointment with $Staffname has been approved.Please verify at the gate on the date of appointment to visit.";
    try{
      await send(message1, smtpServer);
      print("Successs");
    }catch(e){
      print(e.toString()+"hello");
    }

  }
  Future<void> checkifnew() async{
    if(reqcount<req.length){
      //notificationApi.sendNotification("Visitor Request", "You have a visitor request from ${req.first.Name}");
      if(mounted){

        setState(() {
          reqcount=req.length;
        });
      }
    }

  }
  Future<void> getcheckin() async{

    int count=0;
    for(var a in log){
      if(a.Checkedout==""){
        count++;
      }
    }
    if(mounted){

      setState(() {
        visitorscheckedin=count;
      });
    }
  }

  @override
  void initState(){
    getlog();
    getreq();
    reqcount=req.length;
    getcheckin();
    //notificationApi.initialiseNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    getlog();
    getreq();
    checkifnew();
    getcheckin();
    return SizedBox(
      height: size.height*0.6,
      width: size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width,
                height: size.height * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(

                        height: size.height * 0.2,
                        width: size.width * 0.4,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                              ),
                              BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(req.length.toString(),style: GoogleFonts.questrial(fontSize: 90,fontWeight: FontWeight.bold),),
                              Text("Requests",style: GoogleFonts.questrial(fontSize: 20),),
                              Text("Pending",style: GoogleFonts.questrial(fontSize: 17),),

                            ],

                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: size.height * 0.2,
                        width: size.width * 0.4,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                              ),
                              BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                            ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(visitorscheckedin.toString(),style: GoogleFonts.questrial(fontSize: 90,fontWeight: FontWeight.bold),),
                            Text("Visitors",style: GoogleFonts.questrial(fontSize: 20),),
                            Text("Checked In",style: GoogleFonts.questrial(fontSize: 17),),

                          ],

                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: size.width*0.4,
            height: 50,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                  ),
                  BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                ]
            ),
            child: InkWell(
              onTap: (){
                showDialog(context: context, builder: (BuildContext context){
                  return StatefulBuilder(builder: (context,setState){
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text("New Visitor",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 32),),
                      content: SizedBox(
                        width: size.width*0.7,
                        height: size.height*0.24,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Material(
                              elevation: 4.0,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: TextField(
                                  onChanged: (value){

                                    setState(() {
                                      emailgiven=true;
                                    });
                                  },
                                  controller: _emailcontroller,
                                  style: GoogleFonts.questrial(fontSize: 24),
                                  decoration: InputDecoration(
                                      hintText: 'Email-Id',
                                      hintStyle: GoogleFonts.questrial(fontSize: 24),
                                      border: InputBorder.none,
                                      icon: const Icon(Icons.email_outlined,color: Colors.black,)

                                  ),
                                ),
                              ),
                            ),
                            Material(
                              elevation: 4.0,
                              shadowColor: Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: TextField(

                                  readOnly: true,
                                  onTap: ()async{
                                    DateTime? pickedDate = await showDatePicker(

                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2030));
                                    if(pickedDate!=null){
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      setState(() {
                                        datecontroller.text=formattedDate;
                                      });
                                    }

                                  },
                                  onChanged: (value){
                                  },
                                  controller: datecontroller,
                                  style: GoogleFonts.questrial(fontSize: 24),
                                  decoration: InputDecoration(
                                      hintText: "Schedule Date",
                                      hintStyle: GoogleFonts.questrial(fontSize: 24),
                                      border: InputBorder.none,
                                      icon: const Icon(Icons.calendar_today,color: Colors.black,)

                                  ),
                                ),
                              ),
                            ),
                            Text("Send Link to the Visitor?",style: GoogleFonts.questrial(fontSize: 28),)
                          ],

                        ),
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () async{
                            final Staffname = FirebaseAuth.instance.currentUser!.displayName;
                            String token="wbzu hfiq oyad sftv";
                            final smtpServer = gmail('testsptest223@gmail.com',token);

                            final message = Message()
                              ..from = Address(FirebaseAuth.instance.currentUser!.email.toString())
                              ..recipients.add(_emailcontroller.text)
                              ..subject = 'Appointment Registration'
                              ..text= ""
                              ..html = "Hello\n, Your invited for an appointment with $Staffname on ${datecontroller.text}.Please register in this link. <a href='https://fir-test-1ed02.web.app/'>https://fir-test-1ed02.web.app/</a>\nThe session wil end in 30 minutes.";

                            try {
                              await send(message, smtpServer);
                              await _s.startlink();
                              //notificationApi.sendNotification("Invitation", "The Invitation has been successfully sent");
                              //FloatingSnackBar(message: "Invitation Sent", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                              _emailcontroller.clear();
                              datecontroller.clear();
                              Navigator.pop(context);
                            } on MailerException catch (e) {
                              if (kDebugMode) {
                                print(e.toString());
                              }
                            }
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
                                  "Yes",
                                  style: GoogleFonts.questrial(
                                      fontSize: 24,
                                      color: Colors.grey.shade200,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            //FloatingSnackBar(message: "message", context: context);
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

                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.add),
                  ),
                  Text("New Visitor",style: GoogleFonts.questrial(fontSize: 26,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              width: size.width*0.9,
              height: size.height*0.22,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                    ),
                    BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                  ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pending Requests",style: GoogleFonts.questrial(fontSize: 32,fontWeight: FontWeight.bold),),
                    const Divider(),
                    SizedBox(
                      width: size.width*0.8,
                      height: size.height*0.12,
                      child: req.isEmpty?Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.dashboard,size: 80,color: Colors.grey,),
                            Text("No Pending Requests...",style: GoogleFonts.questrial(fontSize: 24,color: Colors.grey),),
                          ],
                        ),
                      ):ListView.builder(
                          itemCount: req.length,
                          itemBuilder: (BuildContext context,int index){
                            return Padding(
                              padding: const EdgeInsets.only(bottom:10.0),
                              child: Container(
                                width: size.width*0.7,
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.all(Radius.circular(20))
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      ClipRect(child: Image.asset("assets/profile.png",width: 60,),),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(req[index].Name,style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 28),),
                                              Text(req[index].Purpose.length>15?"${req[index].Purpose.substring(0,15)}..":req[index].Purpose,style: GoogleFonts.questrial(fontSize: 20),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(onPressed: (){
                                            Uri url = Uri.parse("tel:${req[index].phoneno}");
                                            UrlLauncher.launchUrl(url);


                                          }, icon: const Icon(Icons.call)),

                                          IconButton(onPressed: () async{
                                            await _s.checkin(req[index]);
                                            print(req[index].Name+" "+req[index].EmailId);
                                            //await sendapprovedmail(req[index].EmailId, req[index].Name);
                                            //notificationApi.sendNotification("Visitor Approved", "The visitor has been approved");
                                            //FloatingSnackBar(message: "Visitor Approved", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                                            //saveQr(req[index].id , req[index]);
                                          }, icon: const Icon(Icons.check)),

                                          IconButton(onPressed: () async{
                                            _s.denyreq(req[index]);

                                            //notificationApi.sendNotification("Visitor Declined", "The visitor's request has been declined");
                                            //FloatingSnackBar(message: "Request Denied", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                                          }, icon: const Icon(Icons.highlight_off))
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            );

                          }),
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
              width: size.width,
              child: Center(
                child: Container(
                  width: size.width*0.9,
                  height: size.height*0.235,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(color: Colors.grey,blurRadius: 10,offset: Offset(5,5)
                        ),
                        BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5,-5))
                      ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0,left: 15,right: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Visitors-In",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 32),),
                        const Divider(),
                        SizedBox(
                            width: size.width*0.9,
                            height: size.height*0.15,
                            child: check.isEmpty?Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.dashboard,color: Colors.grey,size: 80,),
                                Text("No Visitors in...",style: GoogleFonts.questrial(fontSize: 24,color: Colors.grey),)
                              ]
                              ,),):
                            ListView.builder(
                                itemCount: check.length,
                                itemBuilder: (BuildContext context,int index){
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom:10.0),
                                    child: Container(
                                      width: size.width*0.7,
                                      height: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: const BorderRadius.all(Radius.circular(20))
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRect(child: Image.asset("assets/profile.png",width: 60,),),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(check[index].VisitorName,style: GoogleFonts.questrial(fontWeight: FontWeight.bold,fontSize: 28),),

                                                    Text(check[index].Purpose.length>15?"${check[index].Purpose.substring(0,15)}..":check[index].Purpose,style: GoogleFonts.questrial(fontSize: 20),)
                                                  ],
                                                ),
                                              ),
                                            ),SizedBox(width: size.width*0.1),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                TextButton(onPressed: () async{
                                                  await _s.checkout(check[index].id);
                                                  //notificationApi.sendNotification("Visitor Checkedout", "Visitor has been successfully checked out");
                                                  //FloatingSnackBar(message: "Visitor Checked out", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                                                }, child: Text("Checkout",style: GoogleFonts.questrial(fontSize: 24,color: Colors.grey,fontWeight: FontWeight.bold),))
                                              ],
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          )],
      ),
    );
  }
}

