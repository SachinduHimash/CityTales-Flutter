import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


class StoryData {
  String id;
  String lat;
  String lng;
  String story;
  String image_url;

  StoryData.fromJson(Map<String, dynamic> json)
      : lng = json['lng'],
        lat = json['lat'],
        image_url =json['image_url'],
        story = json['story'],
        id =json['id'];
}

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});


  @override
  State<ViewScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ViewScreen> {
  late ARKitController arkitController;
  ARKitReferenceNode? node;
  late Position currentLocation;
  late LatLng _center;
  bool isCurrentStory = false;
  final List<StoryData> _storyList=[];
  late StoryData currentStory;

@override
  void initState() {
    super.initState();
    getUserLocation();
  }


  getUserLocation() async {
    await Geolocator.requestPermission();
    currentLocation = await locateUser();
    setState(() {
      _center = LatLng(currentLocation.latitude, currentLocation.longitude);

    });
    fetchStories();

}

Future<Position> locateUser() async {
   
  return  await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

}

fetchStories() async {
    print("Fetching Stories");
    final response =
        await http.get(Uri.parse("https://citytales-backend.onrender.com/stories"));

    if (response.statusCode == 200) {
      List<StoryData> stories = [];
      final res = jsonDecode(response.body);
      stories.addAll(List<StoryData>.from((res).map((x) => StoryData.fromJson(x))));
      setState(() {
        _storyList.addAll(stories);
      });
     setCurrentStory();


    } else {
      throw Exception('Failed to fetch');
    }
  }


  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    final node = ARKitNode(
        geometry: ARKitSphere(radius: 0.1), position: Vector3(0, 0, -0.5));
    this.arkitController.add(node);
  }
  

  Future openDialog()=>showDialog(
    context: context,
    builder: (context)=>AlertDialog(
        title: Text('Story Details'),
        content: Text(currentStory.story),
        actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(225, 225, 255,15),
                    foregroundColor:  const Color.fromARGB(224, 0, 0, 0)),
                    onPressed: () { cancelDialog();},
                    child: Text('Cancel'),
                       ),
        ],
    )
  );

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295; //conversion factor from radians to decimal degrees, exactly math.pi/180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    var radiusOfEarth = 6371;
    return radiusOfEarth * 2 * asin(sqrt(a));
  }

  void setCurrentStory(){
    print("Fetching Current Story");
    print(_storyList[0].story);
    if(!_storyList.isNotEmpty){
        for(var i = 0; i < _storyList.length; i++){
            double distance = calculateDistance(_center.latitude,_center.longitude,(_storyList[i].lat),double.parse(_storyList[i].lng));
            if(distance*1000<100){
                setState(() {
                  currentStory = _storyList[i];
                });
            }
            print(distance);
        } 
  }}

  void cancelDialog(){
    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return  Stack(
        children:[ ARKitSceneView(
            showFeaturePoints: true,
            planeDetection: ARPlaneDetection.horizontal,
            onARKitViewCreated: onARKitViewCreated,
            ),
            // Padding(
            //   padding: const EdgeInsets.all(50),
            //   child: ElevatedButton(onPressed: () { openDialog();}, child: Text('Hi')),
            // )
        ]
      );
    
  }
}