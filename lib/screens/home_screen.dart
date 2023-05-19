import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/model/facility_model.dart';
import 'package:bookit/screens/booking_screen.dart';
import 'package:bookit/screens/facility_category_list.dart';
import 'package:bookit/screens/facility_details_screen.dart';
import 'package:bookit/screens/profile_screen.dart';
import 'package:bookit/screens/user_history_screen.dart';
import 'package:bookit/state/state_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cloud_firestore/user_ref.dart';
import '../model/user_model.dart';

displayProfilePage(BuildContext context, WidgetRef ref) {
  return FutureBuilder(
    future: getUserProfiles(context, FirebaseAuth.instance.currentUser!.phoneNumber!, ref),
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
                maxRadius: 30,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    ref.read(userLogged.notifier).state = null;
                    ref.read(forceReload.notifier).state = false;
                    Navigator.of(context).pushNamed('/');
                  })
            ],
          ),
        );
      }
    },
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 0;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, top: 10.0, right: 10.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Image.asset(
                    'assets/images/menuLogo.jpg',
                    width: MediaQuery.of(context).size.width / 3,
                  ),
                ),
                // Меню
                /*Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!context.read(userInformation).state.isStaff)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/booking'),
                            child: Container(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.book_online, size: 50),
                                      Text(
                                        'Бронирование',
                                        style: GoogleFonts.robotoMono(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!context.read(userInformation).state.isStaff)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/history'),
                            child: Container(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.history, size: 50),
                                      Text(
                                        'История',
                                        style: GoogleFonts.robotoMono(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (context.read(userInformation).state.isStaff)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed('/staffHome'),
                            child: Container(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.admin_panel_settings, size: 50),
                                      Text(
                                        'Админ-панель',
                                        style: GoogleFonts.robotoMono(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),*/
                // Баннеры
                // FutureBuilder(
                //   future: getBanners(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return Center(
                //         child: CircularProgressIndicator(),
                //       );
                //     } else {
                //       var banners = snapshot.data as List<ImageModel>;
                //       return CarouselSlider(
                //           options: CarouselOptions(
                //               viewportFraction: 0.9,
                //               enlargeCenterPage: true,
                //               aspectRatio: 3.0,
                //               autoPlay: true,
                //               autoPlayInterval: Duration(seconds: 3)),
                //           items: banners
                //               .map((e) => Container(
                //                     child: ClipRRect(
                //                       borderRadius: BorderRadius.circular(8.0),
                //                       child: Image.network(e.image),
                //                     ),
                //                   ))
                //               .toList());
                //     }
                //   },
                // ),
                // Популярные
                Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Популярные заведения',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getPopularFacilities(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: 200.0,
                        child: ListView.builder(
                          itemCount: facilities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int value) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsScreen(facility: facilities[value])));
                                },
                                child: Container(
                                  height: 170.0,
                                  width: 150.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(facilities[value].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          facilities[value].name,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Colors.white),
                                            Text(
                                              facilities[value].city,
                                              style: TextStyle(fontSize: 14.0, color: Colors.white),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                //категории
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Категории',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FacilityCategoryList(categoryName: 'Бильярд'))),
                          child: Container(
                            height: 120.0,
                            child: Card(
                              color: Color(0xFFF5F5F5),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/billiard.png'),
                                    Text(
                                      'Бильярд',
                                      style: GoogleFonts.robotoMono(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FacilityCategoryList(categoryName: 'Боулинг'))),
                          child: Container(
                            height: 120.0,
                            child: Card(
                              color: Color(0xFFF5F5F5),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/bowling.png'),
                                    Text(
                                      'Боулинг',
                                      style: GoogleFonts.robotoMono(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FacilityCategoryList(categoryName: 'Караоке'))),
                          child: Container(
                            height: 120.0,
                            child: Card(
                              color: Color(0xFFF5F5F5),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/karaoke.png'),
                                    Text(
                                      'Караоке',
                                      style: GoogleFonts.robotoMono(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      FacilityCategoryList(categoryName: 'Анти-кафе'))),
                          child: Container(
                            height: 120.0,
                            child: Card(
                              color: Color(0xFFF5F5F5),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/anti-cafe.png'),
                                    Text(
                                      'Кафе',
                                      style: GoogleFonts.robotoMono(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Бильярд',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getFacilitiesByCategory('Бильярд'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: 120.0,
                        child: ListView.builder(
                          itemCount: facilities.length > 5 ? 5 : facilities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int value) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsScreen(facility: facilities[value])));
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(facilities[value].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          facilities[value].name,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Colors.white),
                                            Text(
                                              facilities[value].city,
                                              style: TextStyle(fontSize: 14.0, color: Colors.white),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Караоке',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getFacilitiesByCategory('Караоке'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: 120.0,
                        child: ListView.builder(
                          itemCount: facilities.length > 5 ? 5 : facilities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int value) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsScreen(facility: facilities[value])));
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(facilities[value].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          facilities[value].name,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Colors.white),
                                            Text(
                                              facilities[value].city,
                                              style: TextStyle(fontSize: 14.0, color: Colors.white),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Боулинг',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getFacilitiesByCategory('Боулинг'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: 120.0,
                        child: ListView.builder(
                          itemCount: facilities.length > 5 ? 5 : facilities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int value) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsScreen(facility: facilities[value])));
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(facilities[value].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          facilities[value].name,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Colors.white),
                                            Text(
                                              facilities[value].city,
                                              style: TextStyle(fontSize: 14.0, color: Colors.white),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Text(
                        'Анти-кафе',
                        style: GoogleFonts.timmana(fontSize: 18, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                FutureBuilder(
                  future: getFacilitiesByCategory('Анти-кафе'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: 120.0,
                        child: ListView.builder(
                          itemCount: facilities.length > 5 ? 5 : facilities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int value) {
                            return Padding(
                              padding: EdgeInsets.all(5.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsScreen(facility: facilities[value])));
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 250.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    image: DecorationImage(
                                      image: NetworkImage(facilities[value].imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          facilities[value].name,
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: Colors.white),
                                            Text(
                                              facilities[value].city,
                                              style: TextStyle(fontSize: 14.0, color: Colors.white),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.orange,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserHistory()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
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
              label: 'Бронирование',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
