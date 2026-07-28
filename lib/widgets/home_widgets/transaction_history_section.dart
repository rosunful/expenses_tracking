import 'package:flutter/material.dart';

class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 225, 225, 225),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    SizedBox(width: 6),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Whole Foods Market",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Text("Food - Today", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text(
                  "-\$64.20",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    SizedBox(width: 6),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Whole Foods Market",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Text("Food - Today", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text(
                  "-\$64.20",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),


              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    SizedBox(width: 6),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Whole Foods Market",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Text("Food - Today", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text(
                  "-\$64.20",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),


              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //ICON
                    Icon(Icons.person),

                    SizedBox(width: 6),

                    //MIDDLE TEXT PART
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Whole Foods Market",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Text("Food - Today", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),

                //AMOUNT OF USER
                Text(
                  "-\$64.20",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),



            

        
         
          ],
        ),
      ),
    );
  
  
  
  }
}
