import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/model/booking_model.dart';
import 'package:bookit/model/services_model.dart';
import 'package:bookit/state/state_management.dart';
import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../cloud_firestore/services_ref.dart';
import '../utils/utils.dart';

class DoneService extends ConsumerWidget {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  finishService(BuildContext context, WidgetRef ref) {
    var batch = FirebaseFirestore.instance.batch();
    var serviceBook = ref.read(selectedBooking);

    var userBook = FirebaseFirestore.instance
        .collection('User')
        .doc('${serviceBook.customerPhone}')
        .collection('Booking_${serviceBook.customerId}')
        .doc(
            '${serviceBook.serviceId}_${DateFormat('dd_MM_yyyy').format(DateTime.fromMillisecondsSinceEpoch(serviceBook.timeStamp))}_${serviceBook.time.substring(0, serviceBook.time.indexOf('-') - 1)}');

    Map<String, dynamic> updateDone = new Map();
    updateDone['done'] = true;
    updateDone['services'] = convertServices(ref.read(selectedServices));
    updateDone['totalPrice'] = ref
        .read(selectedServices)
        .map((e) => e.price)
        .fold(0, (previousValue, element) => double.parse(previousValue.toString()) + element);

    batch.update(userBook, updateDone);
    batch.update(serviceBook.reference!, updateDone);

    batch.commit().then((value) {
      ScaffoldMessenger.of(scaffoldKey.currentContext!)
          .showSnackBar(SnackBar(
            content: Text('Успешно закрыто!'),
          ))
          .closed
          .then((v) => Navigator.of(context).pop());
    });
  }

  @override
  Widget build(BuildContext context, ref) {
    ref.read(selectedServices).clear();
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Выполненые заказы'),
            backgroundColor: Colors.orange,
          ),
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: FutureBuilder(
                  future: getDetailOfBooking(context, ref.read(selectedTimeSlot), ref),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var bookingModel = snapshot.data as BookingModel;
                      return Card(
                        elevation: 8,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    child: Icon(
                                      Icons.account_box_rounded,
                                      color: Colors.white,
                                    ),
                                    backgroundColor: Colors.black,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${bookingModel.customerName}',
                                        style: GoogleFonts.robotoMono(
                                            fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${bookingModel.customerPhone}',
                                        style: GoogleFonts.robotoMono(fontSize: 16),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Divider(
                                thickness: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer(builder: (context, ref, _) {
                                    var servicesSelected = ref.watch(selectedServices);
                                    var totalPrice = servicesSelected
                                        .map((item) => item.price)
                                        .fold(
                                            0,
                                            (value, element) =>
                                                double.parse(value.toString()) + element);
                                    return Text(
                                      'Цена: ${ref.read(selectedBooking).totalPrice == 0 ? totalPrice : ref.read(selectedBooking).totalPrice}',
                                      style: GoogleFonts.robotoMono(fontSize: 22),
                                    );
                                  }),
                                  ref.read(selectedBooking).done
                                      ? Chip(
                                          label: Text('Завершено'),
                                        )
                                      : Container()
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: FutureBuilder(
                      future: getServices(context, ref),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          var services = snapshot.data as List<ServicesModel>;
                          return Consumer(builder: (context, ref, _) {
                            var servicesWatch = ref.watch(selectedServices);
                            return SingleChildScrollView(
                                child: Column(
                              children: [
                                ChipsChoice<ServicesModel>.multiple(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  wrapped: true,
                                  value: servicesWatch,
                                  onChanged: (val) =>
                                      ref.read(selectedServices.notifier).state = val,
                                  choiceStyle: C2ChoiceStyle(elevation: 8, color: Colors.blue),
                                  choiceItems: C2Choice.listFrom<ServicesModel, ServicesModel>(
                                      source: services,
                                      value: (index, value) => value,
                                      label: (index, value) => '${value.name} (${value.price})'),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: ref.read(selectedBooking).done
                                        ? null
                                        : servicesWatch.length > 0
                                            ? () => finishService(context, ref)
                                            : null,
                                    child: Text(
                                      'Завершить',
                                      style: GoogleFonts.robotoMono(),
                                    ),
                                  ),
                                )
                              ],
                            ));
                          });
                        }
                      }),
                ),
              )
            ],
          )),
    );
  }
}
