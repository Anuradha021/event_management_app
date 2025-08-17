// import 'package:flutter/material.dart';

// class Home extends StatefulWidget {
//   const Home({super.key});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xffe3e6ff),
//               Color(0xfff1f3ff),
//               Colors.white,
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.location_on_outlined),
//                   Text(
//                     "Jaipur",
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 20.0,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 5.0),
//               Text(
//                 "Hello, Anuradha",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 22.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10.0),
//               Text(
//                 "Discover exciting events around you!",
//                 style: TextStyle(
//                   color: Color(0xff6351ec),
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               Container(
//                 margin: EdgeInsets.only(right: 20.0),
//                 padding: EdgeInsets.only(left: 20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(15),
//                   boxShadow: [
//                     BoxShadow(
//                     color: Colors.grey.withValues(red:128,green: 128,blue: 128,alpha: 51),
//                       blurRadius: 10,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     suffixIcon: Icon(Icons.search_outlined),
//                     border: InputBorder.none,
//                     hintText: "Search for music, festivals, and more...",
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Explore Categories",
//                     style: TextStyle(
//                       fontSize: 20.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("See All"),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10.0),
//               Container(
//                 height: 100,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildCategoryCard("Music", "images/music.png"),
//                     _buildCategoryCard("Clothing", "images/tshirt.jpeg"),
//                     _buildCategoryCard("Festival", "images/festival.png"),
//                     _buildCategoryCard("Food", "images/food.png"),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Upcoming Events",
//                     style: TextStyle(
//                       fontSize: 22.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {},
//                     child: Text("See All"),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15.0),
//               _buildUpcomingEvent(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Function for category card
//   Widget _buildCategoryCard(String title, String image) {
//     return Container(
//       margin: EdgeInsets.only(right: 15.0),
//       child: Material(
//         elevation: 3.0,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 90,
//           padding: EdgeInsets.all(10.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset(image, height: 30, width: 30, fit: BoxFit.cover),
//               SizedBox(height: 5.0),
//               Text(
//                 title,
//                 style: TextStyle(color: Colors.black, fontSize: 16.0),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Function for upcoming event card
//   Widget _buildUpcomingEvent() {
//     return Container(
//       margin: EdgeInsets.only(right: 20.0),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withValues(red:128,green: 128,blue: 128,alpha: 51),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               "images/event.jpg",
//               height: 200,
//               width: MediaQuery.of(context).size.width,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: 10,
//             left: 10,
//             child: Container(
//               padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 "June\n17",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10,
//             left: 15,
//             child: Text(
//               "Arijit Singh Concert",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.bold,
//                 shadows: [
//                   Shadow(
//                      color: Colors.black.withValues( red: 0,green: 0,blue: 0,alpha: 178,),
//                     offset: Offset(0, 1),
//                     blurRadius: 5,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 10,
//             right: 15,
//             child: Text(
//               "Price: \$20",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//                 shadows: [
//                   Shadow(
//                    color: Colors.black.withValues( red: 0,green: 0,blue: 0,alpha: 178,),
//                     offset: Offset(0, 1),
//                     blurRadius: 5,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
