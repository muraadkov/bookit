import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/fcm/notification_send.dart';
import 'package:bookit/model/category_model.dart';
import 'package:bookit/model/facility_model.dart';
import 'package:bookit/model/notification_payload_model.dart';
import 'package:bookit/model/service_model.dart';
import 'package:bookit/screens/home_screen.dart';
import 'package:bookit/screens/profile_screen.dart';
import 'package:bookit/screens/user_history_screen.dart';
import 'package:bookit/widgets/my_loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

import '../model/booking_model.dart';
import '../state/state_management.dart';
import '../utils/utils.dart';

class BookingScreen extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();

  // Список Категорий
  displayCategoriesList() {
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
            return Padding(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => context.read(selectedCategory).state = categories[index],
                    child: Container(
                      child: Card(
                        child: ListTile(
                          leading: categories[index].name == 'Бильярд'
                              ? Image.asset(
                                  'assets/images/billiard.png',
                                  color: Colors.orange,
                                )
                              : categories[index].name == 'Боулинг'
                                  ? Image.asset('assets/images/bowling.png', color: Colors.orange)
                                  : categories[index].name == 'Караоке'
                                      ? Image.asset('assets/images/karaoke.png',
                                          color: Colors.orange)
                                      : categories[index].name == 'Анти-кафе'
                                          ? Image.asset('assets/images/anti-cafe.png',
                                              color: Colors.orange)
                                          : null,
                          trailing:
                              context.read(selectedCategory).state.name == categories[index].name
                                  ? Icon(Icons.check)
                                  : null,
                          title: Text(
                            '${categories[index].name}',
                            style: GoogleFonts.robotoMono(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }
      },
    );
  }

  // Список заведений
  displayFacilities(String categoryName) {
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
                  onTap: () => context.read(selectedFacility).state = facilities[index],
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                      ),
                      trailing:
                          context.read(selectedFacility).state.docId == facilities[index].docId
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

  // Список услуг
  displayService(FacilityModel facilityModel) {
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
          } else {
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => context.read(selectedService).state = services[index],
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.sell,
                        color: Colors.black,
                      ),
                      trailing: context.read(selectedService).state.docId == services[index].docId
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

  // Время для бронирования
  displayTimeSlot(BuildContext context, ServiceModel serviceModel) {
    var now = context.read(selectedDate).state;
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
                      onConfirm: (date) => context.read(selectedDate).state = date);
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
          future: getMaxAvailiableTimeSlot(context.read(selectedDate).state),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              var maxTimeSlot = snapshot.data as int;
              return FutureBuilder(
                future: getTimeSlotOfService(serviceModel,
                    DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)),
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
                        onTap: (maxTimeSlot > index || listTimeSlot.contains(index))
                            ? null
                            : () {
                                context.read(selectedTime).state = TIME_SLOT.elementAt(index);
                                context.read(selectedTimeSlot).state = index;
                              },
                        child: Card(
                          color: listTimeSlot.contains(index)
                              ? Colors.white10
                              : (maxTimeSlot > index)
                                  ? Colors.white60
                                  : context.read(selectedTime).state == TIME_SLOT.elementAt(index)
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
                                          : 'Доступно')
                                ],
                              ),
                            ),
                            header: context.read(selectedTime).state == TIME_SLOT.elementAt(index)
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

  // Подтверждение бронирования
  confirmBooking(BuildContext context) {
    var hour = context.read(selectedTime).state.length <= 10
        ? int.parse(context.read(selectedTime).state.split(':')[0].substring(0, 1))
        : int.parse(context.read(selectedTime).state.split(':')[0].substring(0, 2));
    var minutes = context.read(selectedTime).state.length <= 10
        ? int.parse(context.read(selectedTime).state.split(':')[1].substring(0, 1))
        : int.parse(context.read(selectedTime).state.split(':')[1].substring(0, 2));
    var timeStamp = DateTime(
      context.read(selectedDate).state.year,
      context.read(selectedDate).state.month,
      context.read(selectedDate).state.day,
      int.parse(context.read(selectedTime).state.split(':')[0].substring(0, 2)),
      int.parse(context.read(selectedTime).state.split(':')[1].substring(0, 2)),
    ).millisecondsSinceEpoch;
    var bookingModel = BookingModel(
        serviceId: context.read(selectedService).state.docId!,
        serviceName: context.read(selectedService).state.name,
        categoryBook: context.read(selectedCategory).state.name,
        customerId: FirebaseAuth.instance.currentUser!.uid,
        customerName: context.read(userInformation).state.name,
        customerPhone: FirebaseAuth.instance.currentUser!.phoneNumber!,
        done: false,
        totalPrice: 0,
        facilityAddress: context.read(selectedFacility).state.address,
        facilityId: context.read(selectedFacility).state.docId!,
        facilityName: context.read(selectedFacility).state.name,
        slot: context.read(selectedTimeSlot).state,
        timeStamp: timeStamp,
        time: '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(
          context.read(selectedDate).state,
        )}');

    var batch = FirebaseFirestore.instance.batch();

    DocumentReference facilityBooking = context
        .read(selectedService)
        .state
        .reference!
        .collection('${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}')
        .doc(context.read(selectedTimeSlot).state.toString());
    DocumentReference userBooking = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber!)
        .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}')
        .doc(
            '${context.read(selectedService).state.docId}_${DateFormat('dd_MM_yyyy').format(context.read(selectedDate).state)}_${context.read(selectedDate).state.hour}');

    batch.set(facilityBooking, bookingModel.toJson());
    batch.set(userBooking, bookingModel.toJson());
    batch.commit().then((value) {
      context.read(isLoading).state = true;
      var notificationPayload = NotificationPayloadModel(
          to: '/topics/${context.read(selectedFacility).state.docId}',
          notificationContent: NotificationContent(
              title: 'Новая бронь',
              body: 'Вам пришла новая бронь от ${FirebaseAuth.instance.currentUser!.phoneNumber}'));

      sendNotification(notificationPayload).then((value) {
        context.read(isLoading).state = false;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('Успешно забронировано'),
        ));
        context.read(selectedDate).state = DateTime.now();
        context.read(selectedService).state = ServiceModel();
        context.read(selectedCategory).state = CategoryModel(name: '');
        context.read(selectedFacility).state = FacilityModel(
            address: '',
            name: '',
            cheque: 0,
            city: '',
            isPopular: false,
            details: '',
            imageUrl: '');
        context.read(currentStep).state = 1;
        context.read(selectedTime).state = '';
        context.read(selectedTimeSlot).state = -1;

        // final event = Event(
        //   title: 'Бронь в заведении',
        //   description: 'Бронь в ${context.read(selectedTime).state} - '
        //       '${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}',
        //   location: '${context.read(selectedFacility).state.address}',
        //   startDate: DateTime(
        //     context.read(selectedDate).state.year,
        //     context.read(selectedDate).state.month,
        //     context.read(selectedDate).state.day,
        //     hour,
        //     minutes,
        //   ),
        //   endDate: DateTime(
        //     context.read(selectedDate).state.year,
        //     context.read(selectedDate).state.month,
        //     context.read(selectedDate).state.day,
        //     hour,
        //     minutes + 5,
        //   ),
        //   iosParams: IOSParams(reminder: Duration(minutes: 30)),
        //   androidParams: AndroidParams(emailInvites: []),
        // );
        // Add2Calendar.addEvent2Cal(event).then((value) {
        //
        // });
      });
    });
  }

  // Детали брони
  displayBooking(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Image.asset('assets/images/menuLogo.jpg'),
          ),
        ),
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Спасибо что используете наше приложение!'.toUpperCase(),
                      style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Информация брони'.toUpperCase(),
                      style: GoogleFonts.robotoMono(),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}',
                          style: GoogleFonts.robotoMono(),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(Icons.price_check),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${context.read(selectedService).state.name.toUpperCase()}',
                          style: GoogleFonts.robotoMono(),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        Icon(Icons.home),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${context.read(selectedFacility).state.name.toUpperCase()}',
                          style: GoogleFonts.robotoMono(),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${context.read(selectedFacility).state.address.toUpperCase()}',
                          style: GoogleFonts.robotoMono(),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    ElevatedButton(
                      onPressed: () => confirmBooking(context),
                      child: Text('Забронировать'),
                      style:
                          ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black26)),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var categoryWatch = watch(selectedCategory).state;
    var facilityWatch = watch(selectedFacility).state;
    var serviceWatch = watch(selectedService).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;

    var isLoadingWatch = watch(isLoading).state;

    int _selectedIndex = 2;
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            NumberStepper(
              activeStep: step - 1,
              direction: Axis.horizontal,
              enableNextPreviousButtons: false,
              enableStepTapping: false,
              numbers: [1, 2, 3, 4, 5],
              stepColor: Color(0xFFF5F5F5),
              activeStepColor: Colors.grey,
              numberStyle: TextStyle(color: Colors.black),
            ),
            // Список
            Expanded(
              flex: 10,
              child: step == 1
                  ? displayCategoriesList()
                  : step == 2
                      ? displayFacilities(categoryWatch.name)
                      : step == 3
                          ? displayService(facilityWatch)
                          : step == 4
                              ? displayTimeSlot(context, serviceWatch)
                              : step == 5
                                  ? isLoadingWatch
                                      ? MyLoadingWidget(text: 'Ваше бронирование подтверждается...')
                                      : displayBooking(context)
                                  : Container(),
            ),
            // Кнопки перехода
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
                          onPressed: step == 1 ? null : () => context.read(currentStep).state--,
                          child: Text('Назад', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (step == 1 &&
                                      context.read(selectedCategory).state.name == '') ||
                                  (step == 2 && context.read(selectedFacility).state.docId == '') ||
                                  (step == 3 && context.read(selectedService).state.docId == '') ||
                                  (step == 4 && context.read(selectedTimeSlot).state == -1)
                              ? null
                              : step == 5
                                  ? null
                                  : () => context.read(currentStep).state++,
                          child: Text(
                            'Далее',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.black,
          selectedItemColor: Colors.orange,
          currentIndex: _selectedIndex,
          onTap: (int index) {
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserHistory()));
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
