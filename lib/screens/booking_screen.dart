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
import 'package:flutter/material.dart';
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
  displayCategoriesList(WidgetRef ref) {
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
                    onTap: () => ref.read(selectedCategory.notifier).state = categories[index],
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
                          trailing: ref.read(selectedCategory).name == categories[index].name
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
  displayFacilities(String categoryName, WidgetRef ref) {
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
                      leading: Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                      ),
                      trailing:
                          ref.read(selectedFacility.notifier).state.docId == facilities[index].docId
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
                      trailing:
                          ref.read(selectedService.notifier).state.docId == services[index].docId
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
  displayTimeSlot(BuildContext context, ServiceModel serviceModel, WidgetRef ref) {
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
                future: getTimeSlotOfService(
                    serviceModel, DateFormat('dd_MM_yyyy').format(ref.read(selectedDate))),
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
                                ref.read(selectedTime.notifier).state = TIME_SLOT.elementAt(index);
                                ref.read(selectedTimeSlot.notifier).state = index;
                              },
                        child: Card(
                          color: listTimeSlot.contains(index)
                              ? Colors.white10
                              : (maxTimeSlot > index)
                                  ? Colors.white60
                                  : ref.read(selectedTime) == TIME_SLOT.elementAt(index)
                                      ? Colors.white54
                                      : Colors.white,
                          child: GridTile(
                            header: ref.read(selectedTime) == TIME_SLOT.elementAt(index)
                                ? Icon(Icons.check)
                                : null,
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
  confirmBooking(BuildContext context, WidgetRef ref) {
    var hour = ref.read(selectedTime).length <= 10
        ? int.parse(ref.read(selectedTime).split(':')[0].substring(0, 1))
        : int.parse(ref.read(selectedTime).split(':')[0].substring(0, 2));
    var minutes = ref.read(selectedTime).length <= 10
        ? int.parse(ref.read(selectedTime).split(':')[1].substring(0, 1))
        : int.parse(ref.read(selectedTime).split(':')[1].substring(0, 2));
    var timeStamp = DateTime(
      ref.read(selectedDate).year,
      ref.read(selectedDate).month,
      ref.read(selectedDate).day,
      int.parse(ref.read(selectedTime).split(':')[0].substring(0, 2)),
      int.parse(ref.read(selectedTime).split(':')[1].substring(0, 2)),
    ).millisecondsSinceEpoch;
    var bookingModel = BookingModel(
        serviceId: ref.read(selectedService).docId!,
        serviceName: ref.read(selectedService).name,
        categoryBook: ref.read(selectedCategory).name,
        customerId: FirebaseAuth.instance.currentUser!.uid,
        customerName: ref.read(userInformation).name,
        customerPhone: FirebaseAuth.instance.currentUser!.phoneNumber!,
        done: false,
        totalPrice: 0,
        facilityAddress: ref.read(selectedFacility).address,
        facilityId: ref.read(selectedFacility).docId!,
        facilityName: ref.read(selectedFacility).name,
        slot: ref.read(selectedTimeSlot),
        timeStamp: timeStamp,
        time: '${ref.read(selectedTime)} - ${DateFormat('dd/MM/yyyy').format(
          ref.read(selectedDate),
        )}');

    var batch = FirebaseFirestore.instance.batch();

    DocumentReference facilityBooking = ref
        .read(selectedService)
        .reference!
        .collection('${DateFormat('dd_MM_yyyy').format(ref.read(selectedDate))}')
        .doc(ref.read(selectedTimeSlot).toString());
    DocumentReference userBooking = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber!)
        .collection('Booking_${FirebaseAuth.instance.currentUser!.uid}')
        .doc(
            '${ref.read(selectedService).docId}_${DateFormat('dd_MM_yyyy').format(ref.read(selectedDate))}_${ref.read(selectedTime).toString()}');

    batch.set(facilityBooking, bookingModel.toJson());
    batch.set(userBooking, bookingModel.toJson());
    batch.commit().then((value) {
      ref.read(isLoading.notifier).state = true;
      var notificationPayload = NotificationPayloadModel(
          to: '/topics/${ref.read(selectedFacility).docId}',
          notificationContent: NotificationContent(
              title: 'Новая бронь',
              body: 'Вам пришла новая бронь от ${FirebaseAuth.instance.currentUser!.phoneNumber}'));

      sendNotification(notificationPayload).then((value) {
        ref.read(isLoading.notifier).state = false;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text('Успешно забронировано'),
        ));
        ref.read(selectedDate.notifier).state = DateTime.now();
        ref.read(selectedService.notifier).state = ServiceModel();
        ref.read(selectedCategory.notifier).state = CategoryModel(name: '');
        ref.read(selectedFacility.notifier).state = FacilityModel(
            address: '',
            name: '',
            cheque: 0,
            city: '',
            isPopular: false,
            details: '',
            imageUrl: '');
        ref.read(currentStep.notifier).state = 1;
        ref.read(selectedTime.notifier).state = '';
        ref.read(selectedTimeSlot.notifier).state = -1;

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
  displayBooking(BuildContext context, WidgetRef ref) {
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
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            '${ref.read(selectedTime)} - ${DateFormat('dd/MM/yyyy').format(ref.read(selectedDate))}',
                            style: GoogleFonts.robotoMono(),
                          )
                        ],
                      ),
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
                          '${ref.read(selectedService).name.toUpperCase()}',
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
                          '${ref.read(selectedFacility).name.toUpperCase()}',
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
                          '${ref.read(selectedFacility).address.toUpperCase()}',
                          style: GoogleFonts.robotoMono(),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => confirmBooking(context, ref),
                        child: Text('Забронировать'),
                        style:
                            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black26)),
                      ),
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
  Widget build(BuildContext context, ref) {
    var step = ref.watch(currentStep);
    var categoryWatch = ref.watch(selectedCategory);
    var facilityWatch = ref.watch(selectedFacility);
    var serviceWatch = ref.watch(selectedService);
    var dateWatch = ref.watch(selectedDate);
    var timeWatch = ref.watch(selectedTime);
    var timeSlotWatch = ref.watch(selectedTimeSlot);

    var isLoadingWatch = ref.watch(isLoading);

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
                  ? displayCategoriesList(ref)
                  : step == 2
                      ? displayFacilities(categoryWatch.name, ref)
                      : step == 3
                          ? displayService(facilityWatch, ref)
                          : step == 4
                              ? displayTimeSlot(context, serviceWatch, ref)
                              : step == 5
                                  ? isLoadingWatch
                                      ? MyLoadingWidget(text: 'Ваше бронирование подтверждается...')
                                      : displayBooking(context, ref)
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
                          onPressed:
                              step == 1 ? null : () => ref.read(currentStep.notifier).state--,
                          child: Text('Назад', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: (step == 1 && ref.read(selectedCategory).name == '') ||
                                  (step == 2 && ref.read(selectedFacility).docId == '') ||
                                  (step == 3 && ref.read(selectedService).docId == '') ||
                                  (step == 4 && ref.read(selectedTimeSlot) == -1)
                              ? null
                              : step == 5
                                  ? null
                                  : () => ref.read(currentStep.notifier).state++,
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
