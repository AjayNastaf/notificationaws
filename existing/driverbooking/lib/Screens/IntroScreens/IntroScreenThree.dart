import 'package:flutter/material.dart';
import 'package:jessy_cabs/Utils/AppConstants.dart';

class IntroScreenThree extends StatefulWidget {
  const IntroScreenThree({super.key});

  @override
  State<IntroScreenThree> createState() => _IntroScreenThreeState();
}

class _IntroScreenThreeState extends State<IntroScreenThree> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.intro_three), // Replace with your asset
          fit: BoxFit.contain, // Adjust the fit to your preference
          alignment: Alignment.center, // Adjust alignment
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks to fit content
                children: [
                  Text(
                    'Enjoy Your Ride',
                    style: TextStyle(
                      fontSize: 28, // Font size
                      fontWeight: FontWeight.bold, // Bold text
                      color: Colors.black, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8.0), // Space between the two texts
                  Text(
                    'Experience comfort and convenience, your way.', // Second sentence
                    style: TextStyle(
                      fontSize: 16, // Slightly smaller font
                      fontWeight: FontWeight.normal, // Normal text weight
                      color: Colors.black87, // Slightly lighter black
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

