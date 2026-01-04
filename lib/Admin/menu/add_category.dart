import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orderease/Admin/logs/log.dart';
import 'package:orderease/Admin/menu/menu.dart';
import 'package:orderease/Admin/menu/menu_dashboard.dart';
import 'package:orderease/util_components/bottom_navbar.dart';
import 'package:orderease/util_components/profile.dart';
import 'package:orderease/util_components/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewCategoryPage extends StatefulWidget {
  final String hotel_loc;
  final String label;
  final String page_label;

  NewCategoryPage(
      {required this.label, required this.hotel_loc, required this.page_label});

  @override
  _NewCategoryPageState createState() => _NewCategoryPageState();
}

TextEditingController categoryController = TextEditingController();

class _NewCategoryPageState extends State<NewCategoryPage> {
  final _formKey = GlobalKey<FormState>(); // Key to manage the form's state

  // all the input will append to it
  List<Widget> inputList = [];

  // List of all individual controllers
  List<TextEditingController> itemControllers = [];
  List<TextEditingController> priceControllers = [];
  List<String> dropDownmenuItems = ["New"];
  String selectedOption = "New";

  // Increment of items
  int count = 1;

  Timer? _saveTimer; // Store timer reference to cancel on dispose

  bool isOperationLoading = false;

  Future<void> getMenuItemsFromDB() async {
    dropDownmenuItems = ["New"];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Hotels")
        .doc(widget.hotel_loc)
        .collection("Menu")
        .get();
    print(querySnapshot.docs.toList());
    print("DROP");

    List<String> data = querySnapshot.docs.map((doc) => doc.id).toList();

    dropDownmenuItems.addAll(data);
    print(dropDownmenuItems);

    setState(() {
      dropDownmenuItems = dropDownmenuItems;
    });
  }

  void getMenuItems() async {
    await getMenuItemsFromDB();
  }

  @override
  void initState() {
    super.initState();
    addInputFields(); // Add the initial two input fields
    getMenuItems();
  }

  @override
  void dispose() {
    // Cancel any pending timers to prevent setState after dispose
    _saveTimer?.cancel();
    _saveTimer = null;
    super.dispose();
  }

  // Function to build a row with two input fields
  Widget buildInputRow() {
    TextEditingController itemController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    itemControllers.add(itemController);
    priceControllers.add(priceController);

    return Row(
      children: [
        // First input field (Item)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: itemController,
              decoration: InputDecoration(
                labelText: "Item ${count++}",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item';
                }
                return null;
              },
            ),
          ),
        ),
        // Second input field (Price)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: <flutter_services.TextInputFormatter>[
                flutter_services.FilteringTextInputFormatter
                    .digitsOnly, // Only allow digits
              ],
              decoration: InputDecoration(
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                } else if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  // Method to add more input rows when plus icon is clicked
  // Two more input wodgets will be pushed to the inputList and rebuild
  void addInputFields() {
    if (!mounted) return;
    setState(() {
      inputList.add(buildInputRow());
    });
  }

  //Preview var
  bool _previewVisible = false;

  XFile? _selectedImage; // For storing the uploaded image
  XFile? image;
  String _fileName = ''; // For displaying the file name
  bool _isImageUploaded = false;
  String downloadedURL = '';
  String fileName = "";
  String status = "";

  final int _maxSizeInBytes = 5242880;
// Image

  void _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Check platform and request permissions if on mobile
      if (!kIsWeb) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          showBounceSnackBar(context, "Storage permission denied.", "warning");
          return;
        }
      }

      // Proceed to pick an image
      image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Adjust the quality if needed
      );

      if (image != null) {
        fileName = image!.name; // Get filename with extension
        final String nameWithoutExtension =
            fileName.split('.').first; // Extract name without extension

        // Check for allowed file extensions
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        String extension = fileName.split('.').last.toLowerCase();

        print(nameWithoutExtension);

        var name_list = nameWithoutExtension.split("_");

        // validating size
        File file = File(image!.path);
        int fileSize = await file.length();
        print(fileSize);
        print("IMG SIZE");

        // if (fileSize > _maxSizeInBytes) {
        //   showBounceSnackBar(
        //       context, "Image size should not exceed 1 MB.", "warning");
        //   return; // Abort the upload process
        // }

        // Validate file name length
        // if (name_list[1].length > 10) {
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //     content: Text(
        //         "File name (without extension) must be 8 characters or less."),
        //   ));
        //   return;
        // }

        if (!allowedExtensions.contains(extension)) {
          showBounceSnackBar(
              context, "Only JPEG and PNG files are allowed.", "warning");
          return;
        }
        showSlideFromLeftSnackBar(
            context, "Image Uploaded Successfully!", "success");

        print(name_list);
        if (!mounted) return;
        setState(() {
          _selectedImage = image;
          _fileName = name_list[0]; // Store the file name with extension
          _isImageUploaded = true;
        });
      } else {
        showBounceSnackBar(context, "No image selected.", "fail");
      }
    } catch (e) {
      print("Error picking image: $e");
      showBounceSnackBar(context, "Failed to pick image.", "fail");
    }
  }

  // Function to Firebase URL for storage image
  Future<String> getCategoryImageUrl() async {
    Reference category_image_ref = FirebaseStorage.instance
        .ref()
        .child('hotels/${widget.hotel_loc}/category/${fileName}');
    await category_image_ref.putFile(File(image!.path));

    if (!mounted) return "";
    downloadedURL = await category_image_ref.getDownloadURL();
    return downloadedURL;
  }

  // Start of the Screen.
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return widget.page_label == "menu_dashboard"
        ? Scaffold(
            backgroundColor: inner_background(),
            appBar: AppBar(
              title: Text(
                "Add Category",
                style: TextStyle(
                    color: inner_background(), fontWeight: FontWeight.w600),
              ),
              foregroundColor: inner_background(),
              backgroundColor: outer_background(),
              elevation: 0,
              // centerTitle: isLandscape ? false :true,
              actions: [
                ProfileButton(
                    context: context,
                    hotelref: widget.hotel_loc,
                    isTablet: isTablet)
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category input field - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          bool isWide = constraints.maxWidth > 600;
                          return Card(
                            elevation: 2,
                            color: light_variant(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: isWide
                                    ? // 🔽 Category Row (Responsive)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Label
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Select Category',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                350
                                                            ? 16
                                                            : 20,
                                                  ),
                                                ),
                                              ),

                                              SizedBox(width: 12),

                                              // Dropdown
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    border: Border.all(
                                                        color: Colors
                                                            .grey.shade400),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<String>(
                                                      value: selectedOption,
                                                      isExpanded: true,
                                                      icon: Icon(Icons
                                                          .arrow_drop_down),
                                                      style: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                350
                                                            ? 14
                                                            : 16,
                                                        color: Colors.black,
                                                      ),
                                                      items: dropDownmenuItems
                                                          .map((category) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: category,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                category ==
                                                                        "New"
                                                                    ? Icons
                                                                        .add_circle_outline
                                                                    : Icons
                                                                        .category_rounded,
                                                                size: 20,
                                                                color:
                                                                    outer_background(),
                                                              ),
                                                              SizedBox(
                                                                  width: 10),
                                                              Text(category),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged: (value) {
                                                        setState(() =>
                                                            selectedOption =
                                                                value!);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 15),

                                          // NEW CATEGORY INPUT
                                          if (selectedOption == "New")
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Enter New Category',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                TextFormField(
                                                  controller:
                                                      categoryController,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 12),
                                                    hintText:
                                                        'e.g., Appetizers',
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter a category';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 🔽 Category Label
                                          Text(
                                            'Select Category',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),

                                          SizedBox(height: 12),

                                          // 🔽 DROPDOWN MENU
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.grey.shade400),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: selectedOption,
                                                icon:
                                                    Icon(Icons.arrow_drop_down),
                                                isExpanded: true,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                                items: dropDownmenuItems
                                                    .map((category) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: category,
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          category == "New"
                                                              ? Icons
                                                                  .add_circle_outline
                                                              : Icons
                                                                  .category_rounded,
                                                          size: 20,
                                                          color:
                                                              outer_background(),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text(category),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedOption = value!;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 15),

                                          // 🔽 SHOW TEXT FIELD ONLY IF "New" IS SELECTED
                                          if (selectedOption == "New")
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Enter New Category',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                TextFormField(
                                                  controller:
                                                      categoryController,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 12),
                                                    hintText:
                                                        'e.g., Appetizers',
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter a category';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      )),
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Category Image Section - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          bool isWide = constraints.maxWidth > 600;
                          return Card(
                            color: light_variant(),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isWide
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Category Image',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    _pickImage(context);
                                                  },
                                                  icon: Icon(Icons.upload_file,
                                                      size: 18),
                                                  label: Text("Upload Image"),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        outer_background(),
                                                    foregroundColor:
                                                        inner_background(),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 12,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: () {
                                                    print(selectedOption);
                                                    print("PREV");
                                                    if (selectedOption.length ==
                                                            0 &&
                                                        categoryController
                                                            .text.isEmpty &&
                                                        _selectedImage ==
                                                            null) {
                                                      showBounceSnackBar(
                                                        context,
                                                        "Enter category to see the preview.",
                                                        "warning",
                                                      );
                                                    } else {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _previewVisible =
                                                            !_previewVisible;
                                                      });
                                                    }
                                                  },
                                                  icon: Icon(_previewVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off),
                                                  tooltip: _previewVisible
                                                      ? 'Hide Preview'
                                                      : 'Show Preview',
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        outer_background()
                                                            .withOpacity(0.1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Category Image',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () {
                                                      _pickImage(context);
                                                    },
                                                    icon: Icon(
                                                        Icons.upload_file,
                                                        size: 18),
                                                    label: Text("Upload Image"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          outer_background(),
                                                      foregroundColor:
                                                          inner_background(),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  onPressed: () {
                                                    print(selectedOption);
                                                    print("PREv!");
                                                    if (selectedOption.length ==
                                                            0 &&
                                                        categoryController
                                                            .text.isEmpty &&
                                                        _selectedImage ==
                                                            null) {
                                                      showBounceSnackBar(
                                                        context,
                                                        "Enter category to see the preview.",
                                                        "warning",
                                                      );
                                                    } else {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        _previewVisible =
                                                            !_previewVisible;
                                                      });
                                                    }
                                                  },
                                                  icon: Icon(_previewVisible
                                                      ? Icons.visibility
                                                      : Icons.visibility_off),
                                                  tooltip: _previewVisible
                                                      ? 'Hide Preview'
                                                      : 'Show Preview',
                                                  style: IconButton.styleFrom(
                                                    backgroundColor:
                                                        outer_background()
                                                            .withOpacity(0.1),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  if (_selectedImage != null) ...[
                                    SizedBox(height: 12),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Selected: $_fileName',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green.shade900,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              if (!mounted) return;
                                              setState(() {
                                                _selectedImage = null;
                                              });
                                            },
                                            icon: Icon(Icons.close),
                                            iconSize: 20,
                                            color: Colors.green.shade900,
                                            constraints: BoxConstraints(),
                                            padding: EdgeInsets.all(4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),

                      // Preview Section
                      if (_previewVisible)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: TogglePreview(
                            preview_status: _previewVisible,
                            category_name: (selectedOption == "New")
                                ? categoryController.text
                                : selectedOption,
                            categoryController: categoryController,
                            selectedImage: _selectedImage,
                            category_status:
                                (selectedOption == "New") ? "New" : "Existing",
                          ),
                        ),

                      if (_previewVisible) SizedBox(height: 16),

                      // Items and Prices Section
                      Card(
                        elevation: 2,
                        color: light_variant(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Menu Items',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          outer_background().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${inputList.length} ${inputList.length == 1 ? 'item' : 'items'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: outer_background(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: inputList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: inputList[index],
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.add, size: 20),
                                    label: Text('Add Item'),
                                    onPressed: addInputFields,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: outer_background(),
                                      foregroundColor: inner_background(),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  if (count != 2) ...[
                                    SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.remove, size: 20),
                                      label: Text('Remove'),
                                      onPressed: () {
                                        if (count != 2) {
                                          if (!mounted) return;
                                          setState(() {
                                            inputList.removeLast();
                                            count--;
                                            itemControllers.removeLast();
                                            priceControllers.removeLast();
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Save button - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ElevatedButton(
                            onPressed: isOperationLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isOperationLoading = true;
                                    });
                                    if (_formKey.currentState!.validate()) {
                                      print("Form is valid");

                                      var category;

                                      if (selectedOption == "New") {
                                        category = categoryController.text;
                                        status = "New";
                                      } else {
                                        category = selectedOption;
                                        status = "Existing";
                                      }

                                      List<String> items = itemControllers
                                          .map((controller) => controller.text)
                                          .toList();
                                      List<String> prices = priceControllers
                                          .map((controller) => controller.text)
                                          .toList();

                                      print(category);
                                      print(selectedOption);
                                      print(items);
                                      print(prices);
                                      print(image);

                                      Map<String, dynamic> item_price_data =
                                          Map();
                                      Map<String, dynamic> item_status_data =
                                          Map();

                                      Map<String, dynamic> data_map = Map();

                                      // New Image for new category
                                      item_price_data['category_image_path'] =
                                          "";

                                      // Uploaded Image

                                      DocumentSnapshot documentSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection("Hotels")
                                              .doc(hotel_loc)
                                              .collection("Menu")
                                              .doc(category)
                                              .get();

                                      // Existing category
                                      if (documentSnapshot.exists) {
                                        data_map = documentSnapshot.data()
                                            as Map<String, dynamic>;

                                        for (int i = 0; i < items.length; i++) {
                                          data_map[items[i]] = prices[i];
                                          data_map['food_status'][items[i]] =
                                              true;
                                        }

                                        if (fileName != "" && image != null) {
                                          if (!mounted) return;
                                          downloadedURL =
                                              await getCategoryImageUrl();
                                          print(downloadedURL);
                                          print("NEW URL");
                                          data_map['category_image_path'] =
                                              downloadedURL;
                                        }
                                      }

                                      // New Category
                                      else {
                                        print("Fresh Category");

                                        for (int i = 0; i < items.length; i++) {
                                          item_price_data[items[i]] = prices[i];
                                          item_status_data[items[i]] = true;
                                        }

                                        if (fileName != "" && image != null) {
                                          if (!mounted) return;
                                          downloadedURL =
                                              await getCategoryImageUrl();
                                          print(downloadedURL);
                                          print("NEW URL");
                                          item_price_data[
                                                  'category_image_path'] =
                                              downloadedURL;
                                        }
                                      }

                                      print(
                                          "after done new data ${item_price_data}");
                                      print("After DATA existing ${data_map}");

                                      if (!mounted) return;
                                      bool res = await save_menu(
                                          context,
                                          widget.hotel_loc,
                                          category,
                                          item_price_data,
                                          item_status_data,
                                          status,
                                          data_map);

                                      if (res) {
                                        setState(() {
                                          isOperationLoading = false;
                                        });
                                      }
                                    } else {
                                      print("Form is invalid");
                                      showBounceSnackBar(
                                        context,
                                        "Please fill all required fields.",
                                        "fail",
                                      );
                                      setState(() {
                                        isOperationLoading = false;
                                      });
                                    }
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    isOperationLoading
                                        ? "Saving Category..."
                                        : "Save Category",
                                    style: font(18),
                                  ),
                                  if (isOperationLoading)
                                    ...getCircularProgressIndicator()
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: outer_background(),
                              foregroundColor: inner_background(),
                              elevation: 3,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          )

        // From inside menu items
        : Scaffold(
            appBar: AppBar(
              // centerTitle: isLandscape ? false :true,
              title: Text("Add Menu Items - (${widget.label})",
                  style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.w600)),
              foregroundColor: inner_background(),
              backgroundColor: outer_background(),
              elevation: 0,
              actions: [
                ProfileButton(
                    context: context,
                    hotelref: widget.hotel_loc,
                    isTablet: isTablet)
              ],
            ),
            body:
                // add menu item
                SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey, // Attach the form key
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Items and Prices Section
                      Card(
                        elevation: 2,
                        color: light_variant(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Menu Items',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          outer_background().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${inputList.length} ${inputList.length == 1 ? 'item' : 'items'}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: outer_background(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: inputList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: inputList[index],
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    icon: Icon(Icons.add, size: 20),
                                    label: Text('Add Item'),
                                    onPressed: addInputFields,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: outer_background(),
                                      foregroundColor: inner_background(),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  if (count != 2) ...[
                                    SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.remove, size: 20),
                                      label: Text('Remove'),
                                      onPressed: () {
                                        if (count != 2) {
                                          if (!mounted) return;
                                          setState(() {
                                            inputList.removeLast();
                                            count--;
                                            itemControllers.removeLast();
                                            priceControllers.removeLast();
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade400,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      SizedBox(height: 20),

                      // Save button - Responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return ElevatedButton(
                            onPressed: isOperationLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isOperationLoading = true;
                                    });
                                    // Validate all input fields
                                    if (_formKey.currentState!.validate()) {
                                      // If all fields are valid, save the form
                                      // Handle save logic here
                                      String email = FirebaseAuth
                                          .instance.currentUser!.email!;
                                      await addLogEntry(
                                        hotelId: widget.hotel_loc,
                                        userEmail: email,
                                        action: "New menu item added.",
                                        tableNumber: "",
                                        sessionId: "",
                                      );
                                      print("Form is valid");

                                      List<String> items = itemControllers
                                          .map((controller) => controller.text)
                                          .toList();
                                      List<String> prices = priceControllers
                                          .map((controller) => controller.text)
                                          .toList();
                                      print(items);
                                      print(prices);

                                      // Creating item_price map for menu collection
                                      Map<String, dynamic> item_price_data =
                                          Map();
                                      Map<String, dynamic> item_status_data =
                                          Map();

                                      for (int i = 0; i < items.length; i++) {
                                        item_price_data[items[i]] = prices[i];
                                        item_status_data[items[i]] = true;
                                      }

                                      if (!mounted) return;
                                      DocumentSnapshot documentSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection("Hotels")
                                              .doc(widget.hotel_loc)
                                              .collection("Menu")
                                              .doc(widget.label)
                                              .get();

                                      if (!mounted) return;
                                      Map<String, dynamic> item_data =
                                          documentSnapshot.data()
                                              as Map<String, dynamic>;

                                      // Updating status and item vs price data

                                      print("after don${item_data}");
                                      print(item_status_data);
                                      print(item_price_data);

                                      if (!item_data
                                          .containsKey('food_status')) {
                                        // If one add separatly
                                        if (item_status_data.length == 1) {
                                          item_data['food_status'] = {
                                            item_status_data.keys
                                                    .toList()
                                                    .first:
                                                item_status_data.values
                                                    .toList()
                                                    .first
                                          };
                                        } else {
                                          item_data['food_status'] = {};
                                          item_data['food_status']
                                              .addAll(item_status_data);
                                        }
                                      } else if (item_data
                                          .containsKey('food_status')) {
                                        if (item_status_data.length == 1) {
                                          item_data['food_status'][
                                              item_status_data.keys
                                                  .toList()
                                                  .first] = item_status_data
                                              .values
                                              .toList()
                                              .first;
                                        } else {
                                          item_data['food_status']
                                              .addAll(item_status_data);
                                        }
                                      }

                                      print("object");
                                      print(item_data);

                                      item_data.addAll(item_price_data);
                                      print("after don11111${item_data}");

                                      if (!mounted) return;
                                      if (!mounted) return;
                                      await FirebaseFirestore.instance
                                          .collection("Hotels")
                                          .doc(widget.hotel_loc)
                                          .collection("Menu")
                                          .doc(widget.label)
                                          .update(item_data);

                                      if (!mounted) return;
                                      final currentContext = context;
                                      _saveTimer =
                                          Timer(Duration(seconds: 1), () {
                                        if (mounted && currentContext.mounted) {
                                          showSlideFromLeftSnackBar(
                                              currentContext,
                                              "Menu items updated sucessfully!",
                                              "success");

                                          Navigator.pop(
                                              currentContext, item_price_data);
                                        }
                                      });
                                    } else {
                                      // Show error if the form is invalid
                                      print("Form is invalid");
                                    }
                                    setState(() {
                                      isOperationLoading = false;
                                    });
                                  },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    isOperationLoading
                                        ? "Saving Items..."
                                        : "Save Items",
                                    style: font(18),
                                  ),
                                  if (isOperationLoading)
                                    ...getCircularProgressIndicator()
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: outer_background(),
                              foregroundColor: inner_background(),
                              elevation: 3,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

Future<bool> save_menu(
    BuildContext context,
    String hotel_loc,
    var category,
    Map<String, dynamic> item_price_data,
    Map<String, dynamic> item_status_data,
    String status,
    Map<String, dynamic> data_map) async {
  print("Save Menu");
  print(category);

  String email = FirebaseAuth.instance.currentUser!.email!;
  await addLogEntry(
    hotelId: hotel_loc,
    userEmail: email,
    action: "New category (${category.toString().toLowerCase()}) added.",
    tableNumber: "",
    sessionId: "",
  );

  item_price_data['food_status'] = item_status_data;
  print(item_price_data);
  print(data_map);

  DocumentReference hotelref =
      FirebaseFirestore.instance.collection("Hotels").doc(hotel_loc);

  await hotelref.collection("Menu").doc(category).set(
        status == "Existing" ? data_map : item_price_data,
        SetOptions(merge: true),
      );

  // Display after saving menu
  if (context.mounted) {
    showSlideFromLeftSnackBar(context, "Menu saved successfully!", "success");
  }

  // Timer to delay navigation after adding the category
  final currentContext = context;
  Timer(Duration(seconds: 5), () {
    if (currentContext.mounted) {
      // First, pop the current screen to remove it from the stack
      Navigator.pop(currentContext);

      // Then, push the updated Menu_Dashboard screen to show the changes
      Navigator.push(
        currentContext,
        MaterialPageRoute(
          builder: (context) => SwipableNavBar(
            role: "Admin",
            page1: "category_add",
            page2: "search",
            label: "Menu",
            href: hotel_loc,
            table_option: "",
          ),

          // Menu_Dashboard(label: "Menu", href: hotel_loc),
        ),
      );
    }
  });
  // Saving Menu to firestore
  return true;
}

// Preview Container
class TogglePreview extends StatefulWidget {
  // Preview status is passed as a parameter
  final bool preview_status;
  final String category_name;
  final TextEditingController categoryController;
  final String category_status;
  final XFile? selectedImage;

  // Passing status to display or not
  // category name
  // category Controller
  // image xfile

  // Key is used to manage the state of widgets
  TogglePreview(
      {Key? key,
      required this.preview_status,
      required this.category_name,
      required this.categoryController,
      required this.selectedImage,
      required this.category_status})
      : super(key: key);

  @override
  _ToggleContainerExampleState createState() => _ToggleContainerExampleState();
}

class _ToggleContainerExampleState extends State<TogglePreview> {
  String _categoryName = '';

  // Intially i am taking the category_name from the parameter of the constructor
  @override
  void initState() {
    super.initState();

    _categoryName =
        widget.category_name; // Initialize _categoryName with passed value
  }

  // From refreshing i am taking category_name based on status.
  void _updatePreview() {
    if (!mounted) return;
    setState(() {
      if (widget.category_status == "New") {
        _categoryName = widget.categoryController.text;
      } else {
        _categoryName = widget.category_name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),

        // Conditional container based on preview_status
        if (widget.preview_status)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 190,
                  height: 130,
                  child: Card(
                    color: outer_background(),
                    elevation: 4.0,

                    // gives rounded border for the cards
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),

                    // ClipRRect gives radius for the elements of the stack
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15)),
                      child:
                          // Use stack to add one widget over other
                          Stack(
                        children: [
                          // Background Image with gradient overlay

                          // CASE 3
                          if (widget.selectedImage != null)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    bottomRight: Radius.circular(15)),
                                image: widget.selectedImage != null
                                    ? DecorationImage(
                                        image: FileImage(
                                            File(widget.selectedImage!.path)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                          // Category Name Text
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                _categoryName,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              IconButton(
                  onPressed: () {
                    // Updates Preview by taking from the controller itself.
                    _updatePreview();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: outer_background(),
                  )),
            ],
          ),

        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
