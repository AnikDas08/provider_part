import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/notification/notification_service.dart';
import '../../data/model/message_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../utils/app_utils.dart';

class MessageController extends GetxController {
  bool isLoading = false;
  bool isMoreLoading = false;
  bool isSendingImage = false;
  List<MessageModel> messages = [];
  String chatId = "";
  String image = "";
  String name = "";
  int page = 1;
  Sender? senderdata;

  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  static MessageController get instance => Get.put(MessageController());

  Future<void> getMessageRepo() async {
    if (page == 1) {
      isLoading = true;
      update();
    }

    var response = await ApiService.get(
      "${ApiEndPoint.messages}/$chatId?page=$page&limit=15",
    );

    if (response.statusCode == 200) {
      var data = response.data['data'] ?? {};
      if (page == 1) {
        messages.clear();
      }
      for (var messageData in data) {
        MessageModel messageModel = MessageModel.fromJson(messageData);
        messages.add(messageModel);
      }
      print("Messages loaded: ${messages.length}");

      page++;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        update();
        Get.back(); // Close the bottom sheet
        sendImageMessage();
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to pick image from camera");
      print("Camera error: $e");
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        selectedImage = File(pickedFile.path);
        update();
        Get.back(); // Close the bottom sheet
        sendImageMessage();
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to pick image from gallery");
      print("Gallery error: $e");
    }
  }

  // Show image source dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text('Camera'),
              onTap: () => pickImageFromCamera(),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text('Gallery'),
              onTap: () => pickImageFromGallery(),
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: Text('Cancel'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  // Send image message using multipartImage API
  Future<void> sendImageMessage() async {
    if (selectedImage == null) return;

    try {
      isSendingImage = true;
      update();

      // Prepare the body with chat ID, type, and optional text
      Map<String, String> body = {
        'chat': chatId,
        'type': 'image',
      };

      // Add text caption if provided
      if (messageController.text.isNotEmpty) {
        body['text'] = messageController.text;
        messageController.clear();
      }

      // Prepare files array for multipartImage
      List<Map<String, String>> files = [
        {
          'name': 'image', // The field name your API expects
          'image': selectedImage!.path,
        }
      ];

      // Call the multipartImage API
      var response = await ApiService.multipartImage(
        ApiEndPoint.sendMessage,
        body: body,
        files: files,
        method: "POST",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        //Utils.successSnackBar("Success", "Image sent successfully");
        selectedImage = null;

        // Optionally add the message to the list immediately
        // The socket will also push it, so you might want to handle duplicates
      } else {
        Utils.errorSnackBar(
            "Error",
            response.message ?? "Failed to send image"
        );
      }
    } catch (e) {
      Utils.errorSnackBar("Error", "Failed to send image: ${e.toString()}");
      print("Send image error: $e");
    } finally {
      isSendingImage = false;
      update();
    }
  }

  // Send text message
  addNewMessage() async {
    if (messageController.text.trim().isEmpty) return;

    var body = {
      "chat": chatId,
      "text": messageController.text,
      "type": "text"
    };

    String messageText = messageController.text;
    messageController.clear();

    try {
      var response = await ApiService.post(
          ApiEndPoint.sendMessage,
          body: body
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // If failed, restore the message
        messageController.text = messageText;
        Utils.errorSnackBar("Error", "Failed to send message");
      }
    } catch (e) {
      messageController.text = messageText;
      Utils.errorSnackBar("Error", "Failed to send message");
      print("Send message error: $e");
    }
  }

  listenMessage(String chatId) async {
    SocketServices.on('getMessage::$chatId', (data) {
      print("socket data : $data");
      Get.find<HomeController>().countMessa();
      //NotificationService.showNotification(data);

      // Check if message already exists to avoid duplicates
      String messageId = data['_id'] ?? '';
      bool messageExists = messages.any((msg) => msg.id == messageId);

      if (!messageExists) {
        messages.insert(0, MessageModel.fromJson(data ?? {}));
        update();
      }
    });
  }

  init(String id) {
    print("Chat ID: $id");
    chatId = id;
    page = 1;
    messages.clear();
    getMessageRepo();
    listenMessage(chatId);
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (!isMoreLoading && !isLoading) {
          getMessageRepo();
        }
      }
    });
    if (Get.arguments != null) {
      name = Get.arguments['name'] ?? '';
      image = Get.arguments['image'] ?? '';
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    messageController.dispose();
    super.onClose();
  }
}