import 'package:ecosoftvmsstaff/modals/userclass.dart';
import 'package:ecosoftvmsstaff/ui/SignInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/services.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final Services _s = Services();
  Staff s= Staff(EmailId: "Loading..", UserName:"Loading..", phoneno: "Loading..");

  Future<void> profile() async{
    Staff temp = await _s.getprofile(FirebaseAuth.instance.currentUser!.email.toString());
    setState(() {
      s= temp;
    });
  }
  @override
  void initState(){
    profile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height*0.9,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: size.width*0.9,height: size.height*0.7,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height*0.22,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [

                      SizedBox(width: size.width*0.12,),
                      const Icon(Icons.person_outline,size: 40,),
                      SizedBox(width: size.width*0.05,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(s.UserName,style: GoogleFonts.questrial(fontSize: 24),),
                      )
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        SizedBox(width: size.width*0.12,),
                        const Icon(Icons.email_outlined,size: 40,),

                        SizedBox(width: size.width*0.05,),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                              width: size.width*0.5,
                              height: 40,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(s.EmailId,style: GoogleFonts.questrial(fontSize: 24),))),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 40.0,bottom: 100),
                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        SizedBox(width: size.width*0.12,),
                        const Icon(Icons.phone_outlined,size: 40,),

                        SizedBox(width: size.width*0.05,),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(s.phoneno,style: GoogleFonts.questrial(fontSize: 24),),
                        )
                      ],
                    ),
                  ),
                  TextButton(onPressed: () async{
                    showDialog(context: context, builder: (BuildContext context){
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: Text("Warning",style: GoogleFonts.questrial(fontSize: 42,fontWeight: FontWeight.bold),),
                        content: Text("Are you sure you want to log out?",style: GoogleFonts.questrial(fontSize: 28),),
                        actions: [
                          TextButton(onPressed: () async{
                            try{
                              FirebaseAuth.instance.signOut().then((value){
                                Navigator.pop(context);
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const StaffLogin()));
                                //final notificationApi = NotificationApi();
                                //notificationApi.sendNotification("Signed-out", "You have successfully signed-out");

                              }).onError((error, stackTrace){
                              });


                            }catch(e){
                              if (kDebugMode) {
                                print(e.toString());
                              }
                            }

                          }, child: Text("Yes",style: GoogleFonts.questrial(fontSize: 28,color: Colors.grey),)),
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text("No",style: GoogleFonts.questrial(fontSize: 28,color: Colors.grey),)),
                        ],
                      );
                    });


                  },style: TextButton.styleFrom(backgroundColor: Colors.white), child: Text("Sign Out?",style: GoogleFonts.questrial(fontWeight: FontWeight.bold,color: Colors.grey,fontSize: 32),),)
                ],
              ),
            ),
          ),
          Positioned(
              left: (size.width-200)/2,
              top: size.height*0.02,
              child: ClipRect(
                child: Image.asset("assets/profile.png",width: 200,),
              ))
        ],
      ),
    );
  }
}
