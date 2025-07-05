



import 'dart:io';
import 'package:flutter/services.dart';
import 'package:jessy_cabs/Screens/TripDetailsPreview/TripDetailsPreview.dart';
import 'package:jessy_cabs/Utils/AllImports.dart';
import 'package:jessy_cabs/Networks/Api_Service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jessy_cabs/Screens/SignatureEndRide/SignatureEndRide.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jessy_cabs/Bloc/App_Bloc.dart';
import 'package:jessy_cabs/Bloc/AppBloc_State.dart';
import 'package:jessy_cabs/Bloc/AppBloc_Events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jessy_cabs/GlobalVariable/global_variable.dart' as globals;
import 'package:jessy_cabs/Utils/AllImports.dart';

class TripDetailsUpload extends StatefulWidget {
  final String tripId;
  const TripDetailsUpload({Key? key, required this.tripId}) : super(key: key);

  @override
  State<TripDetailsUpload> createState() => _TripDetailsUploadState();
}

class _TripDetailsUploadState extends State<TripDetailsUpload> {

  bool isStartKmEnabled = true; // Only Start KM and Close KM are enabled
  bool isCloseKmEnabled = true;

  double? distance;
  String? timeDuration;

  final TextEditingController startKmController = TextEditingController();
  // final TextEditingController closeKmController = TextEditingController();

  TextEditingController guestNameController = TextEditingController();
  TextEditingController tripIdController = TextEditingController();
  TextEditingController guestMobileController = TextEditingController();
  TextEditingController vehicleTypeController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController closeDateController = TextEditingController();
  TextEditingController closeKmController = TextEditingController();

  // late TextEditingController closeKmController;

  // File? _selectedImage1;
  File? _selectedImage2;
  int? _lastSelectedButton; // Tracks which button was last used
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? tripDetails;
  String? duty;
  int? hcl;
  late TripUploadBloc _tripUploadBloc;
  bool _isLoading = false; // Add this in your state
  bool _hasLoadedOnce = false;
  String? fetchedHybridData;
  String? startkmvalue;
  String? fetchdestination;
  String? fetchGuestEail;
  String? senderEmail;
  String? senderPass;
  String? fetchVechName;
  String? fetchVechNum;
  String? fetchdutyType;
  String? fetchaddress;
  String? fetchStart;
  String? fetchClose;
  static const MethodChannel _trackingChannel = MethodChannel('com.example.jessy_cabs/tracking');

  double totalDistanceInKm = 0.0;




  String setFormattedDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Not available"; // Handle null case

    try {
      DateTime parsedDate = DateTime.parse(dateStr); // Parse the date from DB
      return DateFormat('dd-MM-yyyy').format(parsedDate); // Format to dd/MM/yyyy
    } catch (e) {
      return "Invalid date"; // Handle errors
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
    closeKmController = TextEditingController();
    context.read<SenderInfoBloc>().add(FetchSenderInfo());
    _tripUploadBloc = TripUploadBloc();
    BlocProvider.of<GettingClosingKilometerBloc>(context).add(FetchClosingKilometer(widget.tripId));
    _loadTripSheetDetailsByTripId();
    context.read<GetDurationBloc>().add(FetchDuration(tripId: widget.tripId));
    saveScreenData();

    _reloadScreen();

    loadSavedDistance();

  }





  void _reloadScreen() {
    if (!_hasLoadedOnce) {
      // Perform the reload or initialization logic here
      print("Screen reloaded one time!");
      // Simulate data fetching or any necessary operation
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _hasLoadedOnce = true;
        });
      });
    }
    loadSavedDistance();

  }


  Future<void> saveScreenData() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('last_screen', 'TripDetailsUpload');

    await prefs.setString('trip_id', widget.tripId);





    print('Saved screen data:');

    print('last_screen: TripDetailsUpload');

    print('trip_id: ${widget.tripId}');



  }


  Future<void> _fetchTripDetails() async {
    BlocProvider.of<GettingClosingKilometerBloc>(context).add(FetchClosingKilometer(widget.tripId));
    _loadTripSheetDetailsByTripId();
    _StartCloseKm();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tripDetailsJson = prefs.getString('tripDetails');

    if (tripDetailsJson != null) {
      Map<String, dynamic> tripDetails = json.decode(tripDetailsJson);

      hcl = tripDetails['Hybriddata']; // Assuming `hcl` is part of the trip details
      duty = tripDetails['duty']; // Assuming `duty` is part of the trip details
      setState(() {


      });
    } else {
      print('No trip details found in shared preferences.');
    }
  }


  Future<void> _loadTripSheetDetailsByTripId() async {
    try {
      // Fetch trip details from the API
      final tripDetails = await ApiService.fetchTripDetails(widget.tripId);
      print('Trip details fetchedddd: $tripDetails');
      if (tripDetails != null) {

        fetchedHybridData = tripDetails['Hybriddata'].toString();
        var fetchedStartkmvalue = tripDetails['startkm'].toString();
        var fetcheddestination = tripDetails['useage'].toString();
        var fetchedtripid = tripDetails['tripid'].toString();

        var fetchedguestname = tripDetails['guestname'].toString();

        var fetchedguestmobile = tripDetails['guestmobileno'].toString();

        var fetchedvechtype = tripDetails['vehicleName'].toString();

        var fetchedStartdate = tripDetails['startdate'].toString();

        var fetchedClosedate = tripDetails['closedate'].toString();

        var fetchedClosedkm = tripDetails['closekm'].toString();
        var fetchedGuestemail = tripDetails['email'].toString();
        var fetchedVechName = tripDetails['vehicleName'].toString();
        var fetchedVechNum = tripDetails['vehRegNo'].toString();
        var fetchedDutyType = tripDetails['duty'].toString();
        var fetchedAddress = tripDetails['address1'].toString();
        var fetchedstarttime = tripDetails['starttime'].toString();
        var fetchedclosetime = tripDetails['closetime'].toString();


        print('Fetched startkmvalue: $fetchedStartkmvalue');
        if (!mounted) return;
        setState(() {
          print('aaaaaaaaaaaaaaaaaaaaa');


           startkmvalue = fetchedStartkmvalue;

           // double startKm = double.parse(fetchedStartkmvalue);
           // double endKm = double.parse(fetchedClosedkm);
           //
           // distance = startKm - endKm;

          try {
            double startKm = double.tryParse(fetchedStartkmvalue) ?? 0;
            double endKm = double.tryParse(fetchedClosedkm) ?? 0;
            distance = startKm - endKm;
            print('Distance: $distance');
          } catch (e) {
            print('❌ Error parsing km values: $e');
          }




          // print('between distance${distance}');


            fetchGuestEail = fetchedGuestemail ?? '';
            fetchdestination = fetcheddestination ?? '';
            fetchVechName = fetchedVechName ?? '';
           fetchVechNum = fetchedVechNum ?? '';
           fetchdutyType = fetchedDutyType ?? '';
           fetchaddress = fetchedAddress ?? '';
           fetchStart = fetchedstarttime ?? '';
           fetchClose = fetchedclosetime ?? '';

           print('between distance${fetchGuestEail}');
           print('between distance${fetchdestination}');
           print('between distance${fetchVechName}');
           print('between distance${fetchVechNum}');
           print('between distance${fetchdutyType}');

           print('between distance${fetchaddress}');
           print('between distance${fetchStart}');
           print('between distance${fetchClose}');



           tripIdController.text = fetchedtripid ?? '';

           guestNameController.text = fetchedguestname ?? '';

           guestMobileController.text = fetchedguestmobile ?? '';

           vehicleTypeController.text = fetchedvechtype ?? '';

           // startDateController.text = fetchedStartdate ?? '';

           // closeDateController.text = fetchedguestmobile ?? '';

           closeKmController.text = fetchedClosedkm ?? '';
          // Populate the form fields with the fetched data

          // startKmController.text = startkmvalue ?? '';

           var fetchStartDate = fetchedStartdate ?? '';

           List<String> parts = fetchStartDate.split('-');

           final formStartDate = "${parts[2]}-${parts[1]}-${parts[0]}";

           startDateController.text = formStartDate;

           print("FormDate Start $formStartDate");

           var fetchCloseDate = fetchedClosedate ?? '';

           List<String> partss = fetchCloseDate.split('-');

           final formCloseDate = "${partss[2]}-${partss[1]}-${partss[0]}";

           closeDateController.text = formCloseDate;



        });
        _StartCloseKm();


      } else {
        print('No trip details found.');
      }
    } catch (e) {
      print('Error loading trip details: $e');
    }
  }

  Future<void> _StartCloseKm() async {
    int roundedDistance = globals.savedTripDistance.round();
    // int roundedDistance = 13;
    print('Rounded Trip Distance: $roundedDistance');

    if (startkmvalue != null) {
      // Use startkmvalue as needed
      print('Using startkmvalue in another function: $startkmvalue');

      int startKmInt = int.parse(startkmvalue!); // Convert string to int
      int totalDistance = startKmInt + roundedDistance;
      print('Total Distance (start + rounded): $totalDistance');
      closeKmController.text = totalDistance.toString();

      // closeKmController = TextEditingController(text: totalDistance.toString());
    } else {
      print('startkmvalue is not available.');
    }
  }

  Future<void> clearSavedDistance() async {
    try {
      await _trackingChannel.invokeMethod("clearSavedDistance");
      print("✅ SharedPreferences cleared");
      setState(() {
        totalDistanceInKm = 0.0;
      });
    } catch (e) {
      print("❌ Failed to clear distance: $e");
    }
  }


  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    closeKmController.dispose();
    super.dispose();
  }

    // Future<void> _handleSubmitStartClose() async {
  //   bool result = await ApiService.updateTripDetailsStartandClosekm(
  //     tripid: widget.tripId, // Pass the trip ID
  //     startingkm: startKmController.text,
  //     closigkm: closeKmController.text,
  //   );
  //
  //   // _handleStartingKmSubmit();
  //   _handleClosingKmSubmit();
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signatureendride(tripId: widget.tripId,)));
  //
  // }


  //
  // Future<void> _loadTripDetails() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   // Retrieve the JSON string
  //   String? tripDetailsJson = prefs.getString('tripDetails');
  //
  //   if (tripDetailsJson != null) {
  //     setState(() {
  //       // Decode the JSON string into a Dart map
  //       tripDetails = json.decode(tripDetailsJson);
  //       // tripIdController.text = tripDetails['tripid'] ?? 'Not available';
  //
  //     });
  //   } else {
  //     print('No trip details found in local storage.');
  //   }
  // }






  // @override
  // Widget build(BuildContext context) {
  //   return BlocProvider(
  //       create: (context) => _tripUploadBloc,
  //       child:
  //     Scaffold(
  //     appBar: AppBar(
  //       title: const Text("Trip Details Upload"),
  //     ),
  //       body: BlocListener<TripUploadBloc, TripUploadState>(
  //           listener: (context, state) {
  //             if (state is TripUploadSuccess) {
  //
  //               showSuccessSnackBar(context, state.message);
  //             } else if (state is TripUploadFailure) {
  //
  //               showFailureSnackBar(context, state.error);
  //             }
  //           },
  //           child:
  //            RefreshIndicator(
  //           onRefresh: _fetchTripDetails, // Calls the function to reload data
  //           child: SingleChildScrollView(
  //             physics: const AlwaysScrollableScrollPhysics(), // Enables scroll even when content is less
  //
  //             child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           children: [
  //             // Trip ID
  //
  //             TextField(
  //               controller: tripIdController,
  //               enabled: false,
  //               decoration: const InputDecoration(
  //                 // labelText: "Trip ID",
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Guest Name
  //             TextField(
  //               controller: guestNameController,
  //               enabled: false,
  //               decoration: const InputDecoration(
  //                 labelText: "Guest Name",
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Guest Mobile Number
  //             TextField(
  //               controller: guestMobileController,
  //               enabled: false,
  //               decoration: const InputDecoration(
  //                 labelText: "Guest Mobile Number",
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Vehicle Type
  //             TextField(
  //               controller: vehicleTypeController,
  //               enabled: false,
  //               decoration: const InputDecoration(
  //                 labelText: "Vehicle Type",
  //                 border: OutlineInputBorder(),
  //               ),
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Starting Date
  //             TextField(
  //               readOnly: true,
  //               enabled: false,
  //               controller: startDateController,
  //               decoration: const InputDecoration(
  //                 labelText: "Starting Date",
  //                 border: OutlineInputBorder(),
  //               ),
  //
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Closing Date
  //             TextField(
  //               readOnly: true,
  //               enabled: false,
  //               controller: closeDateController,
  //               decoration: const InputDecoration(
  //                 labelText: "Closing Date",
  //                 border: OutlineInputBorder(),
  //               ),
  //
  //
  //             ),
  //             const SizedBox(height: 16),
  //
  //             // Closing Kilometer
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: TextField(
  //                     controller: closeKmController,
  //                     enabled: isCloseKmEnabled,
  //                     decoration: const InputDecoration(
  //                       labelText: "Closing Kilometer",
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                     ),
  //                   ),
  //                   onPressed: () => _chooseOption(context, 2),
  //                   child: const Text("Upload Image"),
  //                 ),
  //               ],
  //             ),
  //             _selectedImage2 != null
  //                 ? Image.file(
  //               _selectedImage2!,
  //               width: 200,
  //               height: 200,
  //               fit: BoxFit.cover,
  //             )
  //                 : const Text("No image selected for Button 2"),
  //             const SizedBox(height: 16),
  //
  //
  //             Padding(
  //               padding: const EdgeInsets.only(top: 16.0),
  //               child: SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   // onPressed: () async {
  //                   //   // Validate the Starting Kilometer and Closing Kilometer fields and images
  //                   //
  //                   //
  //                   //   // if (closeKmController.text.isEmpty) {
  //                   //   //   ScaffoldMessenger.of(context).showSnackBar(
  //                   //   //     const SnackBar(content: Text("Please enter the Closing Kilometer")),
  //                   //   //   );
  //                   //   //   return;
  //                   //   // }
  //                   //   //
  //                   //   // if (_selectedImage2 == null) {
  //                   //   //   ScaffoldMessenger.of(context).showSnackBar(
  //                   //   //     const SnackBar(content: Text("Please upload an image for Closing Kilometer")),
  //                   //   //   );
  //                   //   //   return;
  //                   //   // }
  //                   //
  //                   //
  //                   //   _handleClosingKmTextSubmit();
  //                   //   _handleClosingKmSubmit();
  //                   //   _handleSignatureStatus();
  //                   //
  //                   //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Signatureendride(tripId: widget.tripId,)));
  //                   //
  //                   // },
  //                   onPressed: () {
  //                     // if (closeKmController.text.isEmpty || _selectedImage2 == null) {
  //                     //
  //                     //   showWarningSnackBar(context, 'Please upload closing kilometer and image');
  //                     //   return;
  //                     // }
  //                     //
  //                     // _tripUploadBloc.add(UploadClosingKmText(tripId: widget.tripId));
  //                     // _tripUploadBloc.add(UploadClosingKmImage(tripId: widget.tripId, image: _selectedImage2!));
  //                     // final dutyValue = duty ?? ""; // Use the fetched duty value (default to "Local" if null)
  //                     // final hclValue = hcl ?? 0; //
  //                     // _tripUploadBloc.add(UpdateSignatureStatus(
  //                     //   tripId: widget.tripId,
  //                     //   closeKm: closeKmController.text,
  //                     //   duty: dutyValue,
  //                     //   hcl: hclValue,
  //                     // ));
  //
  //
  //                     _tripUploadBloc.add(UploadClosingKmText(tripId: widget.tripId));
  //
  //                                               if (_selectedImage2 != null) {
  //                                                 _tripUploadBloc.add(UploadClosingKmImage(tripId: widget.tripId, image: _selectedImage2!));
  //                                               }
  //
  //                                               final dutyValue = duty ?? "";
  //                                               final hclValue = hcl ?? 0;
  //
  //                                               _tripUploadBloc.add(UpdateSignatureStatus(
  //                                                 tripId: widget.tripId,
  //                                                 closeKm: closeKmController.text,
  //                                                 duty: dutyValue,
  //                                                 hcl: hclValue,
  //                                               ));
  //
  //                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TripDetailsPreview(tripId: widget.tripId,)));
  //
  //
  //                   },
  //                   child: Text("Upload Toll and Parking Data"),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ))),
  //   )
  //   );
  // }

  // Function to pick image from camera or gallery
  Future<void> _pickFile(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() {
        _selectedImage2 = File(file.path);
      });
    }
  }
  Future<void> loadSavedDistance() async {
    try {
      final savedDistance = await _trackingChannel.invokeMethod("getSavedDistance");
      setState(() {
        totalDistanceInKm = (savedDistance as num?)?.toDouble() ?? 0.0;
        totalDistanceInKm /= 1000; // convert meters to kilometers
      });

      print('✅ Distance loaded from native: $totalDistanceInKm km');

    } catch (e) {
      print('❌ Error loading distance: $e');

    }

  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _tripUploadBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Uploading Closing Kilometers"),
          automaticallyImplyLeading: false,

        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<TripUploadBloc, TripUploadState>(
              listener: (context, state) {
                if (state is TripUploadSuccess) {
                  showSuccessSnackBar(context, state.message);
                } else if (state is TripUploadFailure) {
                  showFailureSnackBar(context, state.error);
                }
              },
            ),
            BlocListener<GettingClosingKilometerBloc, GettingClosingKilometerState>(
              listener: (context, state) {
                if (state is ClosingKilometerLoaded) {
                  print("object is coming inside");

                } else if (state is ClosingKilometerError) {
                  print("Error fetching closing kilometerrrs: ${state.error}");
                }
              },
            ),
            BlocListener<EmailBloc, EmailState>(
              listener: (context, state) {
                if (state is EmailSent) {
                  print("yeeeee");
                  showSuccessSnackBar(context, "✅ Email Sent Successfully");
                } else if (state is EmailFailed) {
                  print("neeeee");

                  showFailureSnackBar(context, "❌ Email Sending Failed");
                }
              },
            ),
            BlocListener<SenderInfoBloc, SenderInfoState>(
              listener: (context, state) {
                if (state is SenderInfoSuccess) {
                  setState(() {
                    senderEmail = state.senderMail;
                    senderPass = state.senderPass;
                    print('In tracking page setState ${state.senderMail}');
                    print('In tracking page setState ${state.senderPass}');
                  });
                }
                },
            ),

            BlocListener<GetDurationBloc, GetDurationState>(
                listener: (context, state){
                  if(state is GetDurationSuccess){
                    print("Duration is: ${state.data}");
                    setState(() {
                      timeDuration = state.data;
                    });
                  }
                })

          ],
          child: RefreshIndicator(
            onRefresh: _fetchTripDetails, // Calls the function to reload data
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: tripIdController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Trip Id",


                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: guestNameController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Guest Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: guestMobileController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Guest Mobile Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: vehicleTypeController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Vehicle Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      enabled: false,
                      controller: startDateController,
                      decoration: const InputDecoration(
                        labelText: "Starting Date",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      enabled: false,
                      controller: closeDateController,
                      decoration: const InputDecoration(
                        labelText: "Closing Date",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    //  Text(
                    //   "Stored Distance: ${globals.savedTripDistance.toStringAsFixed(2)} km",
                    //   style: TextStyle(fontSize: 18),
                    // ),
                    // const SizedBox(height: 16),
                    //
                    // Text(
                    //   "Rounded Distance : ${globals.savedTripDistance.round()} km",
                    //   style: TextStyle(fontSize: 18),
                    // ),


                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: fetchedHybridData !='1' ? false : true,  // is this value will be 0 we can write
                            enabled: fetchedHybridData != '1',  // expected : enable = 0;
                            controller: closeKmController,
                            // enabled: isCloseKmEnabled,
                            decoration: const InputDecoration(
                              labelText: "Closing Kilometer",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // onPressed: () => _chooseOption(context, 2),
                          onPressed: () => _pickFile(ImageSource.camera),

                          child: const Text("Upload Image"),
                        ),
                      ],
                    ),
                    // _selectedImage2 != null
                    //     ? Image.file(
                    //   _selectedImage2!,
                    //   width: 200,
                    //   height: 200,
                    //   fit: BoxFit.cover,
                    // )
                    //     : const Text("No image selected for Button 2"),

                    if (_selectedImage2 != null)
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage2!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Selected Image",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Text(
                          "No file selected",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.Navblue1, // Navy blue
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _isLoading = true;
                            });

                            // if (closeKmController.text.isEmpty || _selectedImage2 == null) {
                            //
                            //   showWarningSnackBar(context, 'Please upload closing kilometer and image');
                            //   return;
                            // }
                            // _tripUploadBloc.add(UploadClosingKmText(tripId: widget.tripId));
                            // _tripUploadBloc.add(UploadClosingKmImage(tripId: widget.tripId, image: _selectedImage2!));
                            // final dutyValue = duty ?? "";
                            // final hclValue = hcl ?? 0;
                            // _tripUploadBloc.add(UpdateSignatureStatus(
                            //   tripId: widget.tripId,
                            //   closeKm: closeKmController.text,
                            //   duty: dutyValue,
                            //   hcl: hclValue,
                            // ));

                            context.read<EmailBloc>().add(SendEmailEvent(
                              guestName: "${guestNameController.text}",
                              guestMobileNo: "${fetchdestination}",
                              email: "${fetchGuestEail}",
                              startKm: "${startkmvalue}",
                              closeKm: "${globals.savedTripDistance.round()}",
                              duration: "${timeDuration}",
                              senderEmail: '${senderEmail}',
                              senderPassword: '${senderPass}',
                              TripId: '${widget.tripId}',
                              dutytype: '${fetchdutyType}',
                              Vechnum: '${fetchVechNum}',
                              Endpoint: '${fetchdestination}',
                              ReleaseDate: '${closeDateController.text}',
                              ReleaseTime: '${fetchClose}',
                              ReportDate: '${startDateController.text}',
                              ReportTime: '${fetchStart}',
                              Startpoint: '${fetchaddress}',
                              Vechname: '${fetchVechName}', // Gmail App Password
                            ));

                            _tripUploadBloc.add(UploadClosingKmText(tripId: widget.tripId));

                            if (_selectedImage2 != null) {
                              _tripUploadBloc.add(UploadClosingKmImage(tripId: widget.tripId, image: _selectedImage2!));
                            }

                            final dutyValue = duty ?? "";
                            final hclValue = hcl ?? 0;

                            _tripUploadBloc.add(UpdateSignatureStatus(
                              tripId: widget.tripId,
                              closeKm: closeKmController.text,
                              duty: dutyValue,
                              hcl: hclValue,
                            ));

                          // ✅ Always navigate, no matter what


                            clearSavedDistance();
                            Future.delayed(Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripDetailsPreview(tripId: widget.tripId),
                                ),
                              );
                            });

                          },
                          // child: Text("Upload Toll and Parking Data"),
                          child:  _isLoading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Text("Next"),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}