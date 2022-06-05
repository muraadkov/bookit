import 'package:bookit/cloud_firestore/all_facilities_ref.dart';
import 'package:bookit/model/facility_model.dart';
import 'package:bookit/screens/facility_details_screen.dart';
import 'package:flutter/material.dart';

class FacilityCategoryList extends StatelessWidget {
  final String categoryName;
  const FacilityCategoryList({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(categoryName),
          backgroundColor: Colors.orange,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 15.0, top: 10.0, right: 10.0, bottom: 10.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: getFacilitiesByCategory(categoryName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var facilities = snapshot.data as List<FacilityModel>;
                      return Container(
                        height: MediaQuery.of(context).size.height - 100,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: facilities.length,
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
                                  height: 150.0,
                                  width: MediaQuery.of(context).size.width,
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
      ),
    );
  }
}
