import 'package:bookit/cloud_firestore/user_ref.dart';
import 'package:bookit/model/user_model.dart';
import 'package:bookit/screens/booking_screen.dart';
import 'package:bookit/screens/home_screen.dart';
import 'package:bookit/state/state_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'user_history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  displayProfilePage(BuildContext context) {
    return FutureBuilder(
      future: getUserProfiles(context, FirebaseAuth.instance.currentUser!.phoneNumber!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var userModel = snapshot.data as UserModel;
          return Container(
            decoration: BoxDecoration(color: Color(0xFF383838)),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                  maxRadius: 30,
                  backgroundColor: Colors.black,
                ),
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${userModel.name}',
                        style: GoogleFonts.robotoMono(
                            fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${userModel.email}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.robotoMono(
                            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      context.read(userLogged).state = null;
                      context.read(forceReload).state = false;
                      Navigator.of(context).pushNamed('/');
                    })
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildCoverImage() => Container(
        child: Image.network(
          'https://themusicnetwork.com/wp-content/uploads/entertainment-industry-australia.png',
          width: double.infinity,
          height: 280,
          fit: BoxFit.fill,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        foregroundColor: Colors.black26,
        backgroundColor: Colors.orange,
        radius: 72,
        child: Image.asset(
          'assets/images/person.png',
          color: Colors.white,
        ),
      );

  Widget buildTop(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 8),
            child: Container()),
        Padding(padding: EdgeInsets.only(top: 50.0), child: buildProfileImage())
      ],
    );
  }

  @override
  Widget build(BuildContext context, watch) {
    // TODO: implement build
    int _selectedIndex = 3;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: getUserProfiles(context, '+77713346401'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var userModel = snapshot.data as UserModel;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTop(context),
                  Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        userModel.name,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black26),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        userModel.email,
                        style: TextStyle(fontSize: 20, color: Colors.black12),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(10.0))),
                      child: InkWell(
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          context.read(userLogged).state = null;
                          context.read(forceReload).state = false;
                          Navigator.of(context).pushNamed('/');
                        },
                        child: Center(
                          child: Text(
                            'Выход',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 24.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
          }),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.orange,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => UserHistory()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen()));
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Бронь',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
