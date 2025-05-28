import 'package:flutter/material.dart';

import '../components/my_back_button.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Theme.of(context).colorScheme.surface,
     body: Column(
       children: [
         // back button
         Padding(
           padding: const EdgeInsets.only(
               top: 50,
               left: 10
           ),
           child: Row(
             children: [
               MyBackButton(),
             ],
           ),
         ),
       ],
     ),
   );
  }
}
