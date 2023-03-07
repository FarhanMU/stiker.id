import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_name/context.dart';
import 'package:flutter_merraland_online_new/theme.dart';


Widget header_layout_arrow(String Title, Color color, String kindOfButton, BuildContext context)
{
    return 
    kindOfButton == 'arrow' ?
    Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: color,
      ),
      child: 
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset('assets/images/back_arrow_orange.png', width: 10,)
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child:  Text(
              Title, 
              style: TextStyleNunitoBoldBlack16,
            )
          )
        ],
      ) 
      
    ):
    Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: color,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset('assets/images/back_arrow_black_circle.png', width: 25,)
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child:  Text(
              Title, 
              style: TextStyleNunitoBoldBlack16,
            )
          )
        ],
      ) 
    );
    
}