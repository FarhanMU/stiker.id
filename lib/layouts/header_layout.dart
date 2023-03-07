import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_merraland_online_new/theme.dart';

Widget header_layout(String Title, Color color, String textColor)
{
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(24, 0, 0, 0),
            spreadRadius: 0.1,
            blurRadius: 3,
            offset: Offset(0,2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Icon( 
              Icons.arrow_back_ios_rounded,
              color:  textColor == 'black' ? yellowColor : whiteColor,
              size: 15,)
          ),
          Container(
            child:  Text(
              Title, 
              style: textColor == 'black' ? TextStyleNunitoBoldBlack15 : TextStyleNunitoBoldWhite15,  textAlign: TextAlign.center,
            )
          ),
          Container(
            child:  Text('',)
          ),
        ],
      ) ,
    );
}