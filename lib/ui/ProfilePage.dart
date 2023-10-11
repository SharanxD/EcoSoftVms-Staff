import 'dart:io';

import 'package:ecosoftvmsstaff/modals/userclass.dart';
import 'package:ecosoftvmsstaff/ui/SignInPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/services.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key,required this.s});
  final Staff s;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  Services _s= Services();

  @override
  Widget build(BuildContext context) {

    Size size= MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height*0.9,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top:30.0),
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
                          child: Text(widget.s.UserName,style: GoogleFonts.questrial(fontSize: 24),),
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
                                    child: Text(widget.s.EmailId,style: GoogleFonts.questrial(fontSize: 24),))),
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
                            child: Text(widget.s.phoneno,style: GoogleFonts.questrial(fontSize: 24),),
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
          ),
          Positioned(
              left: (size.width-200)/2,
              top: size.height*0.02,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: widget.s.ProfileLink==""?Image.asset("assets/profile.png",width: 200,):
                Image.network(widget.s.ProfileLink,width: 200,height: 200,fit: BoxFit.cover,),
              )),
          Positioned(
            right: (size.width-200)/2,
            top: size.height*0.02+160,
            child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child: IconButton(
                    onPressed: ()async{
                      final _firebaseStorage= FirebaseStorage.instance;
                      final _imagePicker= ImagePicker();
                      XFile? image;
                      await Permission.storage.request();
                      var permstatus = await Permission.storage.status;
                      image = await _imagePicker.pickImage(source: ImageSource.gallery);
                      var file = File(image!.path);
                      if(image!=null){
                        final staffmail = FirebaseAuth.instance.currentUser!.email;
                        print(file);
                        try{
                          var snapshot = await _firebaseStorage.ref()
                              .child('staffprofileimages/$staffmail')
                              .putFile(file);
                          var downloadUrl = await snapshot.ref.getDownloadURL();
                          print(downloadUrl);
                          _s.addprofileimage(downloadUrl, widget.s);



                        }catch(e){
                          print(e.toString());
                        }
                      }else{
                        print("No image selected");
                      }


                    },
                    icon: Icon(Icons.edit,color: Colors.white,))),

          )
        ],
      ),
    );
  }
}
