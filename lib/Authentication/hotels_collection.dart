import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Cook/cook_dashboard.dart';
import 'package:orderease/Cook/cook_welcome.dart';
import 'package:orderease/Manager/manager_table_dashboard.dart';
import 'package:orderease/Settlements/settlements_table_dashboard.dart';
import 'package:orderease/util_components/util.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orderease/main.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'dart:io'; // To use File
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orderease/Admin/admin_dashboard.dart';

// Loginsession
import 'package:shared_preferences/shared_preferences.dart';

var hotel_name, admin_email, hotel_phone, gst_number, gst_rate, hotel_address;

var hotel_area, pincode, admin_name, hotel_logo_url;

void send_data(h_n, a_n, a_e, h_p, g_n, g_r, h_ad, h_ar, pin, h_l_u) {
  hotel_name = h_n;
  admin_name = a_n;
  admin_email = a_e;
  hotel_phone = h_p;
  gst_number = g_n;
  gst_rate = g_r;
  hotel_address = h_ad;
  hotel_area = h_ar;
  pincode = pin;
  hotel_logo_url = h_l_u;
}

// Registering admin to app

Future<bool> registerUser(
    BuildContext context, String email, String password) async {
  try {
    // Attempt to create a new user
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // If successful, you can navigate or show a success message
    showSlideFromLeftSnackBar(
        context, "Hotel registration successful!", "success");

    // Creating user hotels collection
    createHotelAndUser(
        context,
        hotel_name,
        admin_name,
        admin_email,
        hotel_phone,
        gst_number,
        gst_rate,
        hotel_address,
        hotel_area,
        pincode,
        hotel_logo_url);

    return true;
  } on FirebaseAuthException catch (e) {
    // If the error is due to the email already being used
    if (e.code == 'email-already-in-use') {
      showBounceSnackBar(
          context, "The email is already in use by another account.", "fail");
      return false;
    } else {
      // Handle other errors (e.g., weak password, invalid email, etc.)
      showBounceSnackBar(context, "Error: ${e.message}", "fail");

      return false;
    }
  } catch (e) {
    // Catch any other errors and display a generic error message
    showBounceSnackBar(
        context, "An unknown error occurred. Please try again.", "fail");

    return false;
  }
}

// Login User
Future<bool> loginUser(String email, String password, String role, Object data,
    BuildContext context) async {
  try {
    // Sign in the user with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    var hotelref;
    var h_id, h_n, h_a, h_p;
    Map<String, dynamic>? UserData;
    if (data is Map<String, dynamic>) {
      UserData = data;
    }
    h_id = UserData!['hotel_id'];
    h_n = UserData!['hotel_name'].toString().toLowerCase();
    h_a = UserData!['hotel_area'].toString().toLowerCase();
    h_p = UserData!['pincode'].toString().toLowerCase();
    hotelref = "${h_id}_${h_n}_${h_a}_${h_p}";

    print("ASDSDFFGF");
    print(hotelref);
    print(h_id);
    print(email);

    // If login is successful, store user credentials in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('hotel_id', h_id.toString());
    // await prefs.setString('password', password);

    bool login_display = false;

    // Timer(Duration(seconds: 1), () async {
    // ADMIN
    if (role == "Admin") {
      print("to pass ${data}");

      await addLogEntry(
        hotelId: hotelref,
        userEmail: email,
        action: "Logged In",
        tableNumber: "", // stored as null in Firestore
        sessionId: "",
      );

      send_data_from_login(
        data,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
        (Route<dynamic> route) => false, // This removes all previous routes
      );
      login_display = true;
    }

    // MANAGER
    if (role == "Manager") {
      print("to pass ${UserData}");

      if (UserData!['working_status']) {
        await addLogEntry(
          hotelId: hotelref,
          userEmail: email,
          action: "Logged In",
          tableNumber: "", // stored as null in Firestore
          sessionId: "",
        );
        login_display = true;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ManagerPage(href: hotelref)),
          (Route<dynamic> route) => false, // This removes all previous routes
        );
      } else {
        showBounceSnackBar(
            context, "Manager is currently Off Duty, Contact Admin!", "fail");
      }
    }
    if (role == "Cook") {
      if (UserData!['working_status']) {
        await addLogEntry(
          hotelId: hotelref,
          userEmail: email,
          action: "Logged In",
          tableNumber: "", // stored as null in Firestore
          sessionId: "",
        );
        login_display = true;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Cook_Welcome(
                    hotel_loc: hotelref,
                  )),
          (Route<dynamic> route) => false, // This removes all previous routes
        );
      }
    }

    if (role == "Cashier") {
      if (UserData!['working_status']) {
        await addLogEntry(
          hotelId: hotelref,
          userEmail: email,
          action: "Logged In",
          tableNumber: "", // stored as null in Firestore
          sessionId: "",
        );
        login_display = true;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => SettlementsPage(
                    href: hotelref,
                    role: "Cashier",
                  )),
          (Route<dynamic> route) => false, // This removes all previous routes
        );
      }
    }

    // IF TRUE
    if (login_display) {
      print("ADD LOG");
      showSlideFromLeftSnackBar(context, "Login successful", "success");
      return true;
    }
    // });

    // if (login_display) {
    //   return true;
    // }
    return false;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      showBounceSnackBar(context, "No user found", "fail");
    } else if (e.code == 'wrong-password') {
      showBounceSnackBar(context, "Wrong password provided.", "fail");
    } else {
      showBounceSnackBar(context, "Error: ${e.message}", "fail");
    }
  } catch (e) {
    showBounceSnackBar(context, "An unexpected error occurred.", "fail");
  }
  return false;
}

Future<Object> validate_hotel_during_login(String email, String hotelId) async {
  try {
    // Query the Hotels collection for documents where the ID starts with the provided hotelId
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Hotels").get();
    var l, c = 0;

    for (var doc in querySnapshot.docs) {
      l = doc.id.split('_');
      if (l[0] == hotelId) {
        c = 1;
        print("Hotel ID found: $hotelId");

        // Reference to the hotel document
        DocumentReference hotelRef =
            FirebaseFirestore.instance.collection("Hotels").doc(doc.id);

        // getting Hotel data
        DocumentSnapshot documentSnapshot1 = await hotelRef.get();

        var hotel_data;
        if (documentSnapshot1.exists) {
          hotel_data = documentSnapshot1.data() as Map<String, dynamic>?;
        }

        // Try to get the user document in the Users subcollection
        DocumentSnapshot documentSnapshot =
            await hotelRef.collection("Users").doc(email).get();

        if (documentSnapshot.exists) {
          var data = documentSnapshot.data() as Map<String, dynamic>?;

          // Merging all data
          if (data != null && data.containsKey("role")) {
            data.addAll(hotel_data);
            return data; // Return the role if found
          } else {
            return {'role': "Role not found for the user"};
          }
        } else {
          return {'role': "User not found in the hotel"};
        }
      }
    }

    // If no documents are found
    if (c == 0) {
      return {'role': "Hotel not found"};
    }

    // Loop through matching documents (since it's still a query result)
    // for (var doc in querySnapshot.docs) {
    //   if (doc.id.startsWith(hotelId)) {

    //   }
    // }
  } catch (e) {
    print("Error validating hotel during login: $e");
    return {"role": "error occured"};
  }

  return {'role': "Hotel not found"};
}

Future<bool> validateHotel(
    String hotel_name, String hotel_area, String pincode, String gstno) async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection("Hotels").get();

  // Create the search string
  String search_hotel = '${hotel_name}_${hotel_area}_${pincode}';

  if (querySnapshot.size != 0)
  // Loop through documents
  {
    for (var doc in querySnapshot.docs) {
      if (doc.id.contains(search_hotel)) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Hotels")
            .doc(doc.id)
            .get();
        var data = documentSnapshot.data() as Map<String, dynamic>;
        print('Again validate register${data['gst_no']}');

        if (data["gst_no"].toString() == gstno) {
          print("VAli $search_hotel");
          // If a match is found, return true
          return true;
        }
      }
    }

    // Other hotel tries to register with same gst no
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection("Hotels")
        .where("gst_no", isEqualTo: gstno)
        .get();

    if (querySnapshot1.size != 0) {
      return true;
    }
  }
  // If no match is found, return false
  return false;
}

Future<String> uploadImageToFirebase(XFile? _selectedImage) async {
  if (_selectedImage == null) {
    print('No image selected.');
    return '';
  }

  try {
    // Firebase storage instance
    FirebaseStorage storage = FirebaseStorage.instance;

    // Create a reference for the image file
    String fileName = _selectedImage.name; // Using the name from XFile
    Reference storageRef = storage.ref().child('hotel_logos/$fileName');

    // Get the image bytes (since you can't use File on web)
    Uint8List? imageBytes = await _selectedImage.readAsBytes();

    // Upload the image using bytes
    UploadTask uploadTask = storageRef.putData(imageBytes!);

    // Wait until the upload is complete
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

    // Get the download URL
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return '';
  }
}

Future<void> createHotelAndUser(
  BuildContext context,
  hotel_name,
  admin_name,
  admin_email,
  hotel_phone,
  gst_number,
  gst_rate,
  hotel_address,
  hotel_area,
  pincode,
  hotel_logo_url,
) async {
  hotel_name = hotel_name.toString().trim();
  admin_name = admin_name.toString().trim();
  admin_email = admin_email.toString().trim();
  hotel_phone = hotel_phone.toString().trim();
  gst_number = gst_number.toString().trim();
  hotel_area = hotel_area.toString().trim();
  pincode = pincode.toString().trim();

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('Hotels').get();
  int totel_docs = querySnapshot.size;

  var hotel_id = totel_docs + 1;

  var hotel_name1 = hotel_name.toString().toLowerCase();
  var hotel_area1 = hotel_area.toString().toLowerCase();

  // Create the document ID for the Hotels collection, lower case
  String docId = '${hotel_id}_${hotel_name1}_${hotel_area1}_${pincode}';

  // Create the Hotels collection document
  DocumentReference hotelDocRef =
      FirebaseFirestore.instance.collection('Hotels').doc(docId);

  // Set the hotel document with necessary fields (add other fields as required)
  await hotelDocRef.set({
    'hotel_id': hotel_id,
    'hotel_name': hotel_name,
    'hotel_phone': hotel_phone,
    'gst_no': gst_number,
    'gst_rate': gst_rate,
    'address': hotel_address,
    'hotel_area': hotel_area,
    'pincode': pincode,
    'hotel_logo_url': hotel_logo_url
    // Add other fields as needed
  });

  // Create the Users subcollection document ID
  String userDocId = admin_email;

  // Create the Users subcollection document under the hotel document
  await hotelDocRef.collection('Users').doc(userDocId).set({
    'name': admin_name,
    'email': admin_email,
    'role': 'Admin',
  });

  print("Hotels created");
  showSlideFromLeftSnackBar(
      context,
      "Generated Hotel ID: ${hotel_id}. Please note this for future logins!",
      "success");
}
