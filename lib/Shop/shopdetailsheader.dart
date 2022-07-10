import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ShopDetailsHeader implements SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;
  String imageURL;
  String text;
  bool showBackButton;

  //Constructor
  ShopDetailsHeader({
    required this.minExtent, 
    required this.maxExtent, 
    required this.imageURL,
    required this.text,
    required this.showBackButton
  });


  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        //backdrop image
        Image(
          image: NetworkImage(imageURL),
          height: MediaQuery.of(context).size.height / 3.5,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            //placeholder picture in the case image cannot be displayed
            return Image(
              image: const AssetImage(
                  'assets/images/logo5.png'),
              height: MediaQuery.of(context).size.height /
                  3.5,
              width: double.infinity,
              fit: BoxFit.contain);
          },
        ),

        Padding(
          padding: EdgeInsets.all(max(10 - (shrinkOffset / maxExtent) * 5, 6)),
          child: Card(
            clipBehavior: Clip.hardEdge,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.grey[800]!.withOpacity(0.5),
            child: Padding (
              padding: EdgeInsets.all(max(10 - (shrinkOffset / maxExtent) * 5, 6)),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: max(25 - (shrinkOffset / maxExtent) * 10, 20), 
                  letterSpacing: 1, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration => null;
  
  @override
  PersistentHeaderShowOnScreenConfiguration? get showOnScreenConfiguration => null;
  
  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration => null;
  
  @override
  TickerProvider? get vsync => null;

}