import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/chat_list_model.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/socket/socket_service.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/enum/enum.dart';

class ChatControllers extends GetxController {
  /// Api status check here
  Status status = Status.completed;

  /// Chat more Data Loading Bar
  bool isMoreLoading = false;

  TextEditingController searchController = TextEditingController();

  /// page no here
  int page = 1;

  /// Chat List here (original data)
  List<ChatModel> chats = [];

  /// Filtered Chat List for search
  List<ChatModel> filteredChats = [];

  /// Chat Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Chat Controller Instance create here
  static ChatControllers get instance => Get.put(ChatControllers());

  ChatModel? chatModel;
  String name = "";
  String image = "";

  /// Search functionality
  void searchByName(String query) {
    if (query.isEmpty) {
      // Show all chats if search is empty
      filteredChats = List.from(chats);
    } else {
      // Filter chats by participant name or last message
      filteredChats = chats.where((chat) {
        final participantName = chat.participant.name.toLowerCase();
        final lastMessage = chat.latestMessage.text.toLowerCase();
        final searchQuery = query.toLowerCase();

        return participantName.contains(searchQuery) ||
            lastMessage.contains(searchQuery);
      }).toList();
    }
    update();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    filteredChats = List.from(chats);
    update();
  }

  /// Chat More data Loading function
  Future<void> moreChats() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      isMoreLoading = true;
      update();
      await getChatRepo();
      isMoreLoading = false;
      update();
    }
  }

  /// Chat data Loading function
  Future<void> getChatRepo() async {
    if (page == 1) {
      status = Status.loading;
      update();
    }

    var response = await ApiService.get("${ApiEndPoint.chats}?page=$page");

    if (response.statusCode == 200) {
      var data = response.data['data'] ?? [];

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));

        // ✅ participants is List, so access using index
        final participants = item['participants'];
        if (participants is List && participants.isNotEmpty) {
          final user = participants[0];  // first participant
          name = user['name'] ?? "";
          image = user['image'] ?? "";
        }

        // ✅ if you need last message safely
        final lastMessage = item['lastMessage'];
        if (lastMessage is Map && lastMessage['sender'] is Map) {
          var sender = lastMessage['sender'];
          print("Last sender name: ${sender['name']}");
        }
      }

      page = page + 1;

      // Update filtered chats
      if (searchController.text.isEmpty) {
        filteredChats = List.from(chats);
      } else {
        searchByName(searchController.text);
      }

      status = Status.completed;
      update();
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
      status = Status.error;
      update();
    }
  }

  Future<void> refreshChatList() async {
    // Reset page to 1
    page = 1;

    // Clear existing chats
    chats.clear();
    filteredChats.clear();

    // Fetch fresh data
    await getChatRepo();

    // Small delay to ensure smooth animation
    await Future.delayed(Duration(milliseconds: 300));
  }

  /// Chat data Update Socket listener
  listenChat() async {
    SocketServices.on("update-chatlist::${LocalStorage.userId}", (data) {
      page = 1;
      chats.clear();

      for (var item in data) {
        chats.add(ChatModel.fromJson(item));
      }

      // Update filtered chats
      if (searchController.text.isEmpty) {
        filteredChats = List.from(chats);
      } else {
        searchByName(searchController.text);
      }

      status = Status.completed;
      update();
    });
  }

  /// Controller on Init
  @override
  void onInit() {
    getChatRepo();
    listenChat();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}