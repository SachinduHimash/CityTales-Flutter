import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  late LatLng _center;
  late Position currentLocation;
  late CameraPosition _MyPostn ;
  bool isLoading = true;
  final List<Marker> _markerList=[];
  // List<StoryData> storyDetails = [];
  
  @override
  void initState() {
    super.initState();
    fetchMarkers();
    getUserLocation();
  }

Future<Position> locateUser() async {
   
  return  await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );

}

void openDialog(List<StoryData> storyDetails,LatLng position){
  final relatedStories = _markerList
      .where((marker) =>
          marker.position.latitude == position.latitude &&
          marker.position.longitude == position.longitude)
      .map((marker) {
        final index = int.parse(marker.markerId.value); // Get the marker index
        return storyDetails[index]; // Fetch the related story details
      })
      .toList();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Stories for this location"),
        content: SingleChildScrollView(
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: relatedStories.map((story) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (story.image_url.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: Image.network(
                            story.image_url,
                            fit: BoxFit.fill,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                      ),
                    Text(
                      story.story,
                      style: TextStyle(fontSize: 14),
                    ),
                    
                    Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
           ElevatedButton(
              style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(225, 225, 255,15),
                      foregroundColor:  Colors.black,
                     ),
                      onPressed: () {  Navigator.of(context).pop();},
                         child: Text('Close'),
                       ),
          
        ],
      );
    },
  );

}

fetchMarkers() async {
    final response =
        await http.get(Uri.parse("https://citytales-backend.onrender.com/stories"));

    if (response.statusCode == 200) {
      List<StoryData> markerDetails = [];
      List<Marker> markers = [];
      final res = jsonDecode(response.body);
      markerDetails.addAll(List<StoryData>.from(
        (res).map((x) => StoryData.fromJson(x))));
        for (var i = 0; i < markerDetails.length; i++) {
          markers.add(
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(
              double.parse(markerDetails[i].lat),
              double.parse(markerDetails[i].lng),
            ),
         onTap: () {
        openDialog(
          markerDetails,
          LatLng(
            double.parse(markerDetails[i].lat),
            double.parse(markerDetails[i].lng),
          ),
        );
      },
    ),
  );
}
      setState(() {
        _markerList.addAll(markers);
      });
    

    } else {
      throw Exception('Failed to fetch');
    }
  }



getUserLocation() async {
    await Geolocator.requestPermission();
    currentLocation = await locateUser();
    setState(() {
      // _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      _center = LatLng(46.80237, 7.15128);

    });
    _MyPostn = CameraPosition(target:_center, zoom: 15,);
    isLoading = false;
}

 void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading?Container(): GoogleMap(
        myLocationButtonEnabled: false,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        tiltGesturesEnabled: false,
        onMapCreated: _onMapCreated,
          initialCameraPosition: _MyPostn,
          markers: Set<Marker>.of(_markerList),
      ),
      
    );
  }

  
}