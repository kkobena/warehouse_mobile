import 'package:warehouse_mobile/src/models/summary_data.dart';
import 'package:flutter/material.dart';


class SummaryItem extends StatelessWidget {
  final SummaryData data;
  final VoidCallback onTap;

  const SummaryItem({
    required this.data,
    required this.onTap,
  });




  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child:Padding(padding: EdgeInsets.all(4.0) ,
      child:  Container(

        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green.shade100,
              child: Icon(data.icon, size: 24, color: Colors.green),
            ),

            //   Text on the right
            Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.start, // Align text to the right
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.details.map((pair) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pair.code,
                            style: TextStyle(
                              fontSize: 16,
                             // style: const TextStyle(fontSize: 14, color: Colors.grey),
                             color:  Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            pair.value,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                             // color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      ),
      )


    );
  }
}
