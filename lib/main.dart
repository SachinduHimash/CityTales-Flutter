import 'package:city_tales_flutter/screens/addScreen.dart';
import 'package:city_tales_flutter/screens/mapScreen.dart';
import 'package:city_tales_flutter/screens/viewScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    
    final controller = Get.put(NavigationController());
 
    return  MaterialApp(
      home: Scaffold(
      bottomNavigationBar: Obx(
        ()=> Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: NavigationBar(
            height: 80,
            elevation: 50,
            selectedIndex: controller.selectedIndex.value,
            backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
            indicatorColor: Color.fromRGBO(255, 255, 255, 0.6),
            onDestinationSelected: (index)=>controller.selectedIndex.value=index,
            destinations: [
              const  NavigationDestination(icon: Icon(Icons.add), label: 'Add'),
              const  NavigationDestination(icon: Icon(Icons.camera_alt_outlined), label: 'View'),
              const  NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
            ]),
        ),
      ),
      body: Obx(()=> controller.sceens[controller.selectedIndex.value]),
    ));
  }
}


class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 1.obs;
  final sceens = [const AddScreen(),  const ViewScreen(),const MapScreen()];
}
