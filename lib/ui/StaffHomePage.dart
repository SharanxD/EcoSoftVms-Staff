import 'package:ecosoftvmsstaff/ui/LogPage.dart';
import 'package:ecosoftvmsstaff/ui/ProfilePage.dart';
import 'package:ecosoftvmsstaff/ui/StaffDashboardPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:ecosoftvmsstaff/modals/userclass.dart';
import 'package:ecosoftvmsstaff/services/services.dart';
import 'package:google_fonts/google_fonts.dart';
class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  final PageController _pagecontroller = PageController(initialPage: 1);
  final _controller =NotchBottomBarController(index: 1);
  final Services _s= Services();
  List<LogBook> log=[];
  Future<void> getlog() async{
    List<LogBook> temp= await _s.getstafflog(FirebaseAuth.instance.currentUser!.displayName!) as List<LogBook>;
    if(mounted){
      setState(() {
        log=temp;
        log.sort((a,b)=> b.Checkedin.compareTo(a.Checkedin));
      });
    }
  }
  @override
  void initState(){

    getlog();
    super.initState();
  }
  List<String> titles= ["Logbook Reports","My Dashboard","Profile"];
  @override
  Widget build(BuildContext context) {
    getlog();
    Size size= MediaQuery.of(context).size;

    List<Widget> pages = [
      LogScreen(log: log,),
      const StaffDashBoard(),
      const ProfileScreen()
    ];

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: Stack(
          clipBehavior: Clip.none,
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
              top: 0,
              child: SizedBox(
                width: size.width,
                height:size.height,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(titles[_controller.index],
                                style: GoogleFonts.questrial(
                                    fontSize: 32, fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: (){
                              _pagecontroller.jumpToPage(2);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRect(
                                child: Image.asset(
                                  "assets/profile.png",
                                  width: 50,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        width: size.width,
                        height: size.height*0.85,
                        child: PageView.builder(
                          itemCount: pages.length,
                          onPageChanged: (int value){
                            if(mounted){
                              setState(() {
                                _controller.index=value;
                              });
                            }
                          },
                          itemBuilder: (context,index){
                            return pages[index];
                          },
                          controller: _pagecontroller,
                        ),
                      )
                    ]),
              ),
            ),

          ],
        ),
        bottomNavigationBar: AnimatedNotchBottomBar(
          color: Colors.white,
          showLabel: true,
          notchColor: Colors.black,
          notchBottomBarController: _controller,
          bottomBarWidth: 500,
          durationInMilliSeconds: 300,
          bottomBarItems: [

            BottomBarItem(inActiveItem: Icon(Icons.dashboard,color: Colors.grey.shade400,), activeItem: const Icon(Icons.dashboard,color: Colors.white,),itemLabel: "LogBook"),
            BottomBarItem(inActiveItem: Icon(Icons.home_filled,color: Colors.grey.shade400,), activeItem: const Icon(Icons.home_filled,color:Colors.white,),itemLabel: "Home",),
            BottomBarItem(inActiveItem: Icon(Icons.person_outline,color: Colors.grey.shade400,), activeItem: const Icon(Icons.person_outline,color: Colors.white),itemLabel: "Profile"),

          ], onTap: (int value) {
          _pagecontroller.jumpToPage(value);
        },

        ),
      ),
    );
  }
}
