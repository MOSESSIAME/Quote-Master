// import 'package:flutter/material.dart';

// class CompanyHeader extends StatelessWidget {
//   const CompanyHeader({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
//       decoration: BoxDecoration(
//         border: Border(
//           top: BorderSide(color: Colors.black, width: 2),
//           bottom: BorderSide(color: Colors.black, width: 2),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Left vertical black border
//           Container(width: 2, height: 90, color: Colors.black),
//           // Logo and company text
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Logo
//                 Image.asset(
//                   'assets/logo.png',
//                   height: 70,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(width: 6),
//                 // Company name
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     Text(
//                       "Wilhoete Ltd",
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                     ),
//                     Text(
//                       "Glass &",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                         height: 1.0,
//                       ),
//                     ),
//                     Text(
//                       "Aluminium",
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                         height: 1.0,
//                       ),
//                     ),
//                     Text(
//                       "Sales, Design ,Fitting",
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Red vertical divider
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 12),
//             height: 90,
//             width: 2,
//             color: Colors.red,
//           ),
//           // Address and contact
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8, top: 2, right: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: const [
//                   Text(
//                     "Address: Plot 1206 Makishi Road, Emmasdale\nLusaka, Zambia",
//                     style: TextStyle(fontSize: 13),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     "Cell No: +260 0973296683,+260760 756 809",
//                     style: TextStyle(fontSize: 13),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     "Email: wilhoete@gmail.com",
//                     style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Right vertical black border
//           Container(width: 2, height: 90, color: Colors.black),
//         ],
//       ),
//     );
//   }
// }