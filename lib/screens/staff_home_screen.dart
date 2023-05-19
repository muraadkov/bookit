import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/model/service_model.dart';
import 'package:bookit/state/state_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../model/category_model.dart';
import '../model/facility_model.dart';
import '../utils/utils.dart';

class StaffHome extends ConsumerWidget {
  displayCategory(WidgetRef ref) {
    return FutureBuilder(
      future: getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var categories = snapshot.data as List<CategoryModel>;
          if (categories == null || categories.length == 0) {
            return Center(
              child: Text('Не могу загрузить спиок категорий('),
            );
          } else {
            return ListView.builder(
              itemCount: categories.length,
              //gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => ref.read(selectedCategory.notifier).state = categories[index],
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      height: 100.0,
                      child: Card(
                        elevation: 4.0,
                        shape: ref.read(selectedCategory).name == categories[index].name
                            ? RoundedRectangleBorder(
                                side: BorderSide(color: Colors.orange, width: 4),
                                borderRadius: BorderRadius.circular(5))
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            categories[index].name == 'Боулинг'
                                ? Image.asset(
                                    'assets/images/bowling.png',
                                    color: Colors.black,
                                  )
                                : categories[index].name == 'Бильярд'
                                    ? Image.asset(
                                        'assets/images/billiard.png',
                                        color: Colors.black,
                                      )
                                    : categories[index].name == 'Караоке'
                                        ? Image.asset(
                                            'assets/images/karaoke.png',
                                            color: Colors.black,
                                          )
                                        : categories[index].name == 'Анти-кафе'
                                            ? Image.asset(
                                                'assets/images/anti-cafe.png',
                                                color: Colors.black,
                                              )
                                            : Image.asset(''),
                            SizedBox(
                              width: 20.0,
                            ),
                            Text('${categories[index].name}',
                                style: GoogleFonts.openSans(fontSize: 24.0)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  displayFacility(String categoryName, WidgetRef ref) {
    return FutureBuilder(
      future: getFacilitiesByCategory(categoryName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var facilities = snapshot.data as List<FacilityModel>;
          if (facilities == null || facilities.length == 0) {
            return Center(
              child: Text('Не могу загрузить спиок заведений('),
            );
          } else {
            return ListView.builder(
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => ref.read(selectedFacility.notifier).state = facilities[index],
                  child: Card(
                    child: ListTile(
                      shape: ref.read(selectedFacility).name == facilities[index].name
                          ? RoundedRectangleBorder(
                              side: BorderSide(color: Colors.orange, width: 4),
                              borderRadius: BorderRadius.circular(5))
                          : null,
                      leading: Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                      ),
                      trailing: ref.read(selectedFacility).docId == facilities[index].docId
                          ? Icon(Icons.check)
                          : null,
                      title: Text(
                        '${facilities[index].name}',
                        style: GoogleFonts.robotoMono(),
                      ),
                      subtitle: Text(
                        '${facilities[index].address}',
                        style: GoogleFonts.robotoMono(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  displayService(FacilityModel facilityModel, WidgetRef ref) {
    return FutureBuilder(
      future: getServicesByFacilities(facilityModel),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var services = snapshot.data as List<ServiceModel>;
          if (services == null || services.length == 0) {
            return Center(
              child: Text('Не могу загрузить спиок услуг('),
            );
          } else if (FirebaseAuth.instance.currentUser!.uid != ref.read(selectedFacility).docId) {
            return Center(
              child: Text('Вы не относитесь к этому заведению!'),
            );
          } else {
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => ref.read(selectedService.notifier).state = services[index],
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.sell,
                        color: Colors.black,
                      ),
                      trailing: ref.read(selectedService).docId == services[index].docId
                          ? Icon(Icons.check)
                          : null,
                      title: Text(
                        '${services[index].name} \n'
                        'Цена: ${services[index].price}',
                        style: GoogleFonts.robotoMono(),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        }
      },
    );
  }

  displayBooking(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
        future: checkThisFacility(context, ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            var result = snapshot.data as bool;
            if (result) {
              return displaySlot(context, ref);
            } else {
              return Center(
                child: Text('Вы не относитесь к этому заведению!'),
              );
            }
          }
        });
  }

  displaySlot(BuildContext context, WidgetRef ref) {
    var now = ref.read(selectedDate);
    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        '${DateFormat.MMMM().format(now)}',
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      ),
                      Text(
                        '${now.day}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        '${DateFormat.EEEE().format(now)}',
                        style: GoogleFonts.robotoMono(color: Colors.white54),
                      )
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime.now(),
                      maxTime: now.add(Duration(days: 31)),
                      onConfirm: (date) => ref.read(selectedDate.notifier).state = date);
                },
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: FutureBuilder(
          future: getMaxAvailiableTimeSlot(ref.read(selectedDate)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var maxTimeSlot = snapshot.data as int;
              return FutureBuilder(
                future: getBookingSlot(
                    context, DateFormat('dd_MM_yyyy').format(ref.read(selectedDate)), ref),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    var listTimeSlot = snapshot.data as List<int>;
                    return GridView.builder(
                      itemCount: TIME_SLOT.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: (!listTimeSlot.contains(index))
                            ? null
                            : () => processDoneServices(context, index, ref),
                        child: Card(
                          color: listTimeSlot.contains(index)
                              ? Colors.white10
                              : (maxTimeSlot > index)
                                  ? Colors.white60
                                  : ref.read(selectedTime) == TIME_SLOT.elementAt(index)
                                      ? Colors.white54
                                      : Colors.white,
                          child: GridTile(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${TIME_SLOT.elementAt(index)}'),
                                  Text(listTimeSlot.contains(index)
                                      ? 'Бронь'
                                      : (maxTimeSlot > index)
                                          ? 'Недоступно'
                                          : 'Доступно'),
                                ],
                              ),
                            ),
                            header: ref.read(selectedTime) == TIME_SLOT.elementAt(index)
                                ? Icon(Icons.check)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }
          },
        ))
      ],
    );
  }

  processDoneServices(BuildContext context, int index, WidgetRef ref) {
    ref.read(selectedTimeSlot.notifier).state = index;
    Navigator.of(context).pushNamed('/doneServices');
  }

  @override
  Widget build(BuildContext context, ref) {
    var currentStaffStep = ref.watch(staffStep);
    var categoryWatch = ref.watch(selectedCategory);
    var facilityWatch = ref.watch(selectedFacility);
    var serviceWatch = ref.watch(selectedService);
    var dateWatch = ref.watch(selectedDate);
    var selectedTimeWatch = ref.watch(selectedTime);
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(currentStaffStep == 1
                ? 'Выберите категорию'
                : currentStaffStep == 2
                    ? 'Выберите заведение'
                    : currentStaffStep == 3
                        ? 'Выберите сервис'
                        : currentStaffStep == 4
                            ? 'Ваши заказы'
                            : 'Админ панель'),
            backgroundColor: Colors.orange,
            actions: [
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    ref.read(userLogged.notifier).state = null;
                    ref.read(forceReload.notifier).state = false;
                    Navigator.of(context).pushNamed('/');
                  },
                  icon: Icon(Icons.logout))
            ],
          ),
          body: Center(
              child: Column(
            children: [
              Expanded(
                child: currentStaffStep == 1
                    ? displayCategory(ref)
                    : currentStaffStep == 2
                        ? displayFacility(categoryWatch.name, ref)
                        : currentStaffStep == 3
                            ? displayService(facilityWatch, ref)
                            : currentStaffStep == 4
                                ? displayBooking(context, ref)
                                : Container(),
                flex: 10,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: currentStaffStep == 1
                                ? null
                                : () => ref.read(staffStep.notifier).state--,
                            child: Text('Назад'),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (currentStaffStep == 1 && ref.read(selectedCategory).name == '') ||
                                        (currentStaffStep == 2 &&
                                            ref.read(selectedFacility).docId == '') ||
                                        (currentStaffStep == 3 &&
                                            ref.read(selectedService).docId == '') ||
                                        currentStaffStep == 4
                                    ? null
                                    : () => ref.read(staffStep.notifier).state++,
                            child: Text('Далее'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ))),
    );
  }
}
