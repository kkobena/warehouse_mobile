import 'package:warehouse_mobile/src/models/summary_data.dart';
import 'package:warehouse_mobile/src/ui/home/admin/widgets/summary_item.dart';
import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final List<SummaryData> datas;

  const SummaryCard({
    required this.datas,
  });



  Widget build1(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150,minWidth: 280),
      child: CarouselView(
          itemExtent: 280,
          shrinkExtent: 150,
          children: datas.map((data) {
            return ColoredBox(
              color: Color.fromARGB(255, 248, 248, 245),
             child:
                Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
                  Expanded(child:
                  Column(
                   // crossAxisAlignment: CrossAxisAlignment.start, // Align text to the right
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: data.details
                        .map((pair) {
                          return Padding(  padding: const EdgeInsets.symmetric(vertical: 2.0,horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Text(
                                  pair.code,
                                  style: TextStyle(
                                      fontSize: 16,
                                    color: const Color.fromARGB(255, 110, 108, 108),
                                  ),
                                  textAlign: TextAlign.right,
                                ),

                                Text(
                                  pair.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          );
                    })
                        .toList(),
                  )),
                ],
              ),
            ),

            );
          }).toList()),
    );
  }



  @override
  Widget build(BuildContext context) {
  return
    GridView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.all(1),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //  maxCrossAxisExtent: 380,
      crossAxisCount:1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
   /* crossAxisSpacing: 1,
    mainAxisSpacing: 1,*/
   // childAspectRatio: 1,

  ),
    itemCount: datas.length,


    itemBuilder: (context, index) {
      return SummaryItem(
        data: datas[index],
        onTap: () {
          // Action spécifique pour chaque fonctionnalité
         // print('${datas[index].icon} tapped');
        },

      );
    }, );
  }
}

enum CardInfo {
  camera('Cameras', Icons.sell, Color(0xff2354C7), Color(0xffECEFFD)),
  lighting('Lighting', Icons.lightbulb, Color(0xff806C2A), Color(0xffFAEEDF)),
  climate('Climate', Icons.thermostat, Color(0xffA44D2A), Color(0xffFAEDE7)),
  wifi('Wifi', Icons.wifi, Color(0xff417345), Color(0xffE5F4E0)),
  media('Media', Icons.library_music, Color(0xff2556C8), Color(0xffECEFFD)),
  security(
      'Security', Icons.crisis_alert, Color(0xff794C01), Color(0xffFAEEDF)),
  safety(
      'Safety', Icons.medical_services, Color(0xff2251C5), Color(0xffECEFFD)),
  more('', Icons.add, Color(0xff201D1C), Color(0xffE3DFD8));

  const CardInfo(this.label, this.icon, this.color, this.backgroundColor);

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}
