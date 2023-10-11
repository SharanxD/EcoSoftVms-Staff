import 'dart:ui';

import 'package:ecosoftvmsstaff/modals/userclass.dart';
import 'package:ecosoftvmsstaff/ui/StaffHomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/services.dart';

class StaffLogin extends StatefulWidget {
  const StaffLogin({super.key});

  @override
  State<StaffLogin> createState() => _StaffLoginState();
}

class _StaffLoginState extends State<StaffLogin> {

  final _emailcontroller = TextEditingController();
  final _pwdcontroller= TextEditingController();
  bool emailvalid=false;
  bool pwdgiven=false;
  bool loading=false;
  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
              children:[
                Positioned(
                    top: 0,
                    child: Image.asset("assets/UserBG.jpeg",height: size.height,fit: BoxFit.fill,alignment: Alignment.bottomCenter,)),
                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaY: 10,sigmaX: 10),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black, Colors.black.withOpacity(0)],
                                stops: const [0.7, 0.9]).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Container(color: const Color(0xeeeeeeee)),
                        )
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width,
                  height: size.height,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height*0.1,),
                        ClipRRect(child: Image.asset("assets/vmspic.jpeg",width: 300,),borderRadius: BorderRadius.circular(100),),
                        Padding(
                          padding: const EdgeInsets.only(top :20.0,bottom: 20),
                          child: Text("Login to Network",style: GoogleFonts.questrial(fontSize: 32,fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: size.width*0.8,
                          child: Column(
                            children: [
                              Material(
                                elevation: 4.0,
                                shadowColor: Colors.black,
                                borderRadius: BorderRadius.circular(10.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: TextField(
                                    onChanged: (value){
                                      if(EmailValidator.validate(value)){
                                        setState(() {
                                          emailvalid=true;
                                        });
                                      }else{
                                        setState(() {
                                          emailvalid=false;
                                        });
                                      }
                                    },
                                    controller: _emailcontroller,
                                    decoration: InputDecoration(
                                        labelText: 'Email-Id',
                                        labelStyle: GoogleFonts.questrial(fontSize: 24),
                                        border: InputBorder.none,
                                        icon: Icon(Icons.email_outlined,color: emailvalid?Colors.green:Colors.black,)

                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Material(
                                  elevation: 4.0,
                                  shadowColor: Colors.black,
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    child: TextField(
                                      controller: _pwdcontroller,
                                      obscureText: true,
                                      onChanged: (value){
                                        if(value.length>=8){
                                          setState(() {
                                            pwdgiven=true;
                                          });
                                        }else{
                                          setState(() {
                                            pwdgiven=false;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'Password',
                                          labelStyle: GoogleFonts.questrial(fontSize: 24),
                                          border: InputBorder.none,
                                          icon: Icon(Icons.lock_outline,color: pwdgiven?Colors.green:Colors.black,)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(child: Text("Forgot Password",style: GoogleFonts.questrial(fontSize: 24,color: Colors.blue),),
                              onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordPage()));
                              },),
                            SizedBox(width: size.width*0.1,)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        GestureDetector(
                          onTap: ()async{
                            if(emailvalid && pwdgiven){
                              setState(() {
                                loading=true;
                              });
                              await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailcontroller.text, password: _pwdcontroller.text)
                                  .then((value) async{
                                    if(FirebaseAuth.instance.currentUser!.emailVerified){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StaffHomeScreen()));
                                    }else{
                                      FloatingSnackBar(message: "Please Verify your email", context: context,textStyle: GoogleFonts.questrial(fontSize: 20));
                                      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                      await FirebaseAuth.instance.signOut();
                                      setState(() {
                                        _pwdcontroller.clear();
                                        pwdgiven=false;
                                      });
                                    }
                                }).onError((error, stackTrace){
                                if(error.toString()=="[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred."){
                                  FloatingSnackBar(message: "Please Connect to Internet", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                                }
                                else if(error.toString()=="[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted." || error.toString()=="[firebase_auth/wrong-password] The password is invalid or the user does not have a password."){
                                  FloatingSnackBar(message: "Incorrect Email or password", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                                }
                                setState(() {
                                  loading=false;
                                });

                              });
                            }else if(emailvalid){
                              FloatingSnackBar(message: "Password should be atleaast 8 characters", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                            }
                            else if(pwdgiven){
                              FloatingSnackBar(message: "Please enter a valid email address", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                            }
                            else{
                              FloatingSnackBar(message: "Please enter all the details", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                            }
                            setState(() {
                              loading=false;
                            });


                          },
                          child: Container(
                            width: size.width*0.3,
                            height: 60,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey[500]!,blurRadius: 10,offset: const Offset(4,4),spreadRadius: 0.5),
                                  const BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5, -5),spreadRadius: 1)
                                ]
                            ),
                            child: Center(child: loading?const SpinKitThreeBounce(
                              color: Colors.blueGrey,
                              size: 30,

                            ):
                            Text("Sign-In",style: GoogleFonts.questrial(fontSize: 24,color: Colors.blueGrey,fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom:20.0,top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(width: size.width*0.2,height: 6,decoration:const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(Radius.circular(30))
                              ),),
                              Text("or",style: GoogleFonts.questrial(fontSize: 24,color: Colors.white),),
                              Container(width: size.width*0.2,height: 6,decoration:const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.all(Radius.circular(30))
                              ),),



                            ],
                          ),
                        ),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Dont have an account?",style: GoogleFonts.questrial(fontSize: 24,color: Colors.white),),
                              TextButton(child: Text("Create one",style: GoogleFonts.questrial(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.blue),),
                                  onPressed: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context)=>const RegisterPage()));
                                  }),
                            ],
                          ),
                        )

                      ],
                    ),
                  ),

                ),
              ])
      ),
    );
  }
}


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _usernamecontroller =TextEditingController();
  final _emailcontroller = TextEditingController();
  final _pwdcontroller=TextEditingController();
  final _confirmpwdcontroller=TextEditingController();
  final _phonecontroller=TextEditingController();
  bool namegiven=false;
  bool emailvalid=false;
  bool pwdgiven=false;
  bool cnfpwdgiven=false;
  bool phonenovalid=false;
  bool loading = false;
  final Services _s=Services();

  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: 0,
                  child: Image.asset("assets/UserBG.jpeg",height: size.height,fit: BoxFit.cover,alignment: Alignment.bottomCenter,)),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaY: 10,sigmaX: 10),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.black.withOpacity(0)],
                              stops: const [0.7, 0.9]).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Container(color: const Color(0xeeeeeeee)),
                      )
                  ),
                ),
              ),
              SizedBox(
                width: size.width,
                height: size.height,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height*0.2,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 40.0,bottom: 30),
                          child: Text("Register",style: GoogleFonts.questrial(fontSize: 32,fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: size.width*0.8,
                      height: size.height*0.45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Material(
                            elevation: 4.0,
                            shadowColor: Colors.black,
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: TextField(
                                controller: _usernamecontroller,
                                onChanged: (value){
                                  if(value.isNotEmpty){
                                    setState(() {
                                      namegiven=true;
                                    });
                                  }else{
                                    setState(() {
                                      namegiven=false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: GoogleFonts.questrial(fontSize: 18),
                                    border: InputBorder.none,
                                    icon: Icon(Icons.person_outline,color: namegiven?Colors.green:Colors.black,)
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
                                controller: _emailcontroller,
                                onChanged: (value){
                                  if(EmailValidator.validate(value)){
                                    setState(() {
                                      emailvalid=true;
                                    });
                                  }else{
                                    setState(() {
                                      emailvalid=false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Email-Id',
                                    labelStyle: GoogleFonts.questrial(fontSize: 18),
                                    border: InputBorder.none,
                                    icon: Icon(Icons.mail_outline,color: emailvalid?Colors.green:Colors.black,)
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
                                controller: _phonecontroller,
                                onChanged: (value){
                                  if(value.length==10){
                                    setState(() {
                                      phonenovalid=true;
                                    });
                                  }else{
                                    setState(() {
                                      phonenovalid=false;
                                    });
                                  }
                                },
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    labelText: 'Phone number',
                                    labelStyle: GoogleFonts.questrial(fontSize: 18),
                                    border: InputBorder.none,
                                    icon: Icon(Icons.phone_iphone,color: phonenovalid?Colors.green:Colors.black,)
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
                                controller: _pwdcontroller,
                                obscureText: true,
                                onChanged: (value){
                                  if(value.length>=8){
                                    setState(() {
                                      pwdgiven=true;
                                    });
                                  }else{
                                    setState(() {
                                      pwdgiven=false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Password',

                                    labelStyle: GoogleFonts.questrial(fontSize: 18),
                                    border: InputBorder.none,

                                    icon: Icon(Icons.lock_outline,color: pwdgiven?Colors.green:Colors.black,)
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
                                controller: _confirmpwdcontroller,
                                onChanged: (value){
                                  if(value==_pwdcontroller.text){
                                    setState(() {
                                      cnfpwdgiven=true;
                                    });
                                  }else{
                                    setState(() {
                                      cnfpwdgiven=false;
                                    });
                                  }
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                    labelText: 'Confirm Password',

                                    labelStyle: GoogleFonts.questrial(fontSize: 18),
                                    border: InputBorder.none,

                                    icon: Icon(Icons.lock_outline,color: cnfpwdgiven?Colors.green:Colors.black,)
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        onTap: () async{
                          setState(() {
                            loading=true;
                          });
                          if(namegiven && emailvalid && pwdgiven && cnfpwdgiven && phonenovalid){
                            Staff s = Staff(EmailId: _emailcontroller.text, UserName: _usernamecontroller.text,phoneno: _phonecontroller.text,ProfileLink: "");
                            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: s.EmailId, password: _pwdcontroller.text)
                                .then((value)async{
                              await FirebaseAuth.instance.currentUser?.updateDisplayName(s.UserName);
                              await FirebaseAuth.instance.currentUser?.sendEmailVerification();
                              _s.addStaff(s);
                              _usernamecontroller.clear();
                              _emailcontroller.clear();
                              _pwdcontroller.clear();
                              _confirmpwdcontroller.clear();
                              FloatingSnackBar(message: "Please find the verification in your mail", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const StaffLogin()));
                            });


                          }else if(namegiven && emailvalid && pwdgiven && phonenovalid){
                            FloatingSnackBar(message: "Re-Type the correct password", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                          }
                          else if(namegiven && emailvalid && pwdgiven){
                            FloatingSnackBar(message: "Please enter the correct Phone number", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                          }
                          else if(namegiven && emailvalid){
                            FloatingSnackBar(message: "Make sure the password has atleast 8 characters", context: context,textStyle: GoogleFonts.questrial(fontSize: 14 ));
                          }else if(namegiven){
                            FloatingSnackBar(message: "Type a valid Email address", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                          }else{
                            FloatingSnackBar(message: "Enter all the details", context: context,textStyle: GoogleFonts.questrial(fontSize: 18));
                          }
                          setState(() {
                            loading=false;
                          });

                        },
                        child: Container(
                          width: size.width*0.3,
                          height: 60,
                          decoration: BoxDecoration(
                              color: const Color(0xFFE9F3FD),
                              borderRadius: const BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(color: Colors.grey[500]!,blurRadius: 10,offset: const Offset(4,4),spreadRadius: 0.5),
                                const BoxShadow(color: Colors.white,blurRadius: 10,offset: Offset(-5, -5),spreadRadius: 1)
                              ]
                          ),
                          child: Center(child: loading?const SpinKitThreeBounce(
                            color: Colors.blueGrey,
                            size: 30,

                          ):Text("Register",style: GoogleFonts.questrial(fontSize: 24,color: Colors.blueGrey,fontWeight: FontWeight.bold),)),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool emailvalid=false;
  final emailcontroller= TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none
          ,
          children: [
            Positioned(
                top: 0,
                child: Image.asset("assets/UserBG.jpeg",height: size.height,fit: BoxFit.fill,alignment: Alignment.bottomCenter,)),
            Positioned(
              top: 0,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaY: 10,sigmaX: 10),
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black, Colors.black.withOpacity(0)],
                            stops: const [0.7, 0.9]).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Container(color: const Color(0xeeeeeeee)),
                    )
                ),
              ),
            ),
            Positioned(
                top: size.height*0.075,
                left:10,
                child: IconButton(onPressed: (){
                  Navigator.pop(context);

                },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 40,),)),
            Positioned(
                top: size.height*0.15,
                left: 30,
                child: SizedBox(
                  width: size.width*0.8,
                  height: size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Forgot Password?",style: GoogleFonts.questrial(color: Colors.black,fontSize: 50,fontWeight: FontWeight.bold),),
                        const SizedBox(height: 30,),
                        Text("If you need help resetting your password,\nwe can help by sending you a link to\nreset it",style: GoogleFonts.questrial(color: Colors.grey,fontSize: 22),),
                        const SizedBox(height: 40,),
                        TextField(
                          decoration: InputDecoration(
                            label: Text("E-Mail",style: GoogleFonts.questrial(color: Colors.black),),
                            icon: Icon(Icons.email_outlined,color: emailvalid?Colors.green:Colors.black,),
                            suffixIcon: emailvalid?const Icon(Icons.check_circle,color: Colors.green,):const SizedBox(),
                          ),
                          onChanged: (text){
                            setState(() {
                              emailvalid= EmailValidator.validate(text);
                            });
                          },
                          style: GoogleFonts.questrial(color: Colors.black,fontSize: 24),
                          controller: emailcontroller,

                        ),
                        SizedBox(height: size.height*0.07,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: (){
                                if(emailvalid){

                                  FirebaseAuth.instance.sendPasswordResetEmail(email: emailcontroller.text)
                                      .then((value){
                                        if(mounted){
                                          setState(() {
                                            emailcontroller.clear();
                                          });
                                        }
                                        Navigator.pop(context);
                                    FloatingSnackBar(message: "Mail Sent", context: context,textStyle: GoogleFonts.questrial(fontSize: 20));
                                  }).catchError((error,stacktrace){
                                    print(error);
                                    if(error.toString()=="[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted."){
                                      FloatingSnackBar(message: "User doesnt Exist.", context: context,textStyle: GoogleFonts.questrial(fontSize: 20));
                                    }

                                  });
                                }else{
                                  FloatingSnackBar(message: "Enter a valid Mail", context: context,textStyle: GoogleFonts.questrial(fontSize: 20));
                                }

                              },
                              child: Container(
                                width: size.width * 0.3,
                                height: 60,
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
                                      "Send Link",
                                      style: GoogleFonts.questrial(
                                          fontSize: 28,
                                          color: Colors.blueGrey,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                            ),
                          ],
                        ),

                      ]),
                ))

          ],
        ),
      ),
    );
  }
}


