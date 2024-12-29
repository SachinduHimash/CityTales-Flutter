import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';    

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';

// flutter_location_search todo

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});


  @override
  State<AddScreen> createState() => _MyWidgetState();
}

class LocationDetails {
    String ?lat;
    String ?lng;
    LocationDetails({this.lat, this.lng});
  }

class _MyWidgetState extends State<AddScreen> {

  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();


  File? _image;
  final picker = ImagePicker();

  var updatedLat = '';
  var updatedLng = '';


  Future getImageGallery() async{
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      );
    setState((){
    
    if(pickedFile != null){
      _image = File(pickedFile.path);
      // widget.imgUrl = null;
    }
    else{
      if (kDebugMode) {
        print("No Image Picked");
      }
    }
  });
  }

  void updateLocation(String lng,String lat){
    setState(() {
      updatedLat = lat;
      updatedLng = lng;
    });
  }


  _postData ()async{    
    var dio = Dio();
    try {
         Map<String, dynamic> body = {
          'story': controller2.text,
          'lng': updatedLng,
          'lat': updatedLat,
          'photo': _image!.path
          // Add any other data you want to send in the body
         };
          FormData formData = FormData.fromMap(body);
          var response = await dio.post('http://localhost:4000/stories', data: formData);
          return response.data;
        } catch (e) {
          print(e);
        }
        
}

 

  
  
  @override  
  Widget build(BuildContext context) {  
    
    return
         ListView(
           children:[ Padding(
             padding: const EdgeInsets.all(30),
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Column(
                      children: [
                        Text("Add Your Story",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600
                        ),),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                          width: double.infinity,
                          child: Text(
                            "Location"
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child:placesAutoCompleteTextField()),
                      ],
                    ),
                   
                    Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      width: double.infinity,
                      child: Text(
                        "Story"
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      child: TextFormField(  
                            controller: controller2,
                            maxLines: 5,
                            decoration: const InputDecoration( 
                              border: OutlineInputBorder(), 
                              hintText: 'Enter your story',  
                            ),  
                            onTapOutside: (PointerDownEvent event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },

                          ),
                    ),
                  ],
                ),  
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                      width: double.infinity,
                      child: Text(
                        "Upload your photo"
                      ),
                    ),
                    Center(
                      child: InkWell(
                        onTap:(){
                          getImageGallery();
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.grey)
                          ),
                          child: _image != null? Image.file(_image!.absolute,fit: BoxFit.cover,)
                          :Center(
                            child: Icon(Icons.add_photo_alternate_outlined,size: 30,),
                          )
                        ),
                      ),
                    ),
                  ],
                ),
             
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                             backgroundColor: const Color.fromARGB(225, 225, 255,15),
                             foregroundColor:  Colors.black,
                         ),
                         onPressed: () { _postData();},
                         child: Text('Add'),
                       ),
                     ),
              ],
                   ),
           )],
         );
  }  

  placesAutoCompleteTextField() {
    return SizedBox(
      child: GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          googleAPIKey:"AIzaSyAmxQPFrekAdvNEcsNypJYW1PQPEhcTPmc",
          inputDecoration: InputDecoration(
            hintText: "Search your location",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          debounceTime: 400,
          countries: ["ch"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            updateLocation(prediction.lng.toString(), prediction.lat.toString());
          },
      
          itemClick: (Prediction prediction) {
            controller.text = prediction.description ?? "";
            controller.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0));
          },
          seperatedBuilder: Divider(),
          containerHorizontalPadding: 10,
      
      
          // OPTIONAL// If you want to customize list view item builder
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(
                    width: 7,
                  ),
                  Expanded(child: Text(prediction.description ?? ""))
                ],
              ),
            );
          },
      
          isCrossBtnShown: true,
      
          // default 600 ms ,
        ),
      );
  }
}