class BookingModel {
  final String customerName;
  final String service;
  final String date;
  final String time;
  final String bookingId;
  final String price;
  final String profileImage;
  final BookingStatus status;

  BookingModel({
    required this.customerName,
    required this.service,
    required this.date,
    required this.time,
    required this.bookingId,
    required this.price,
    required this.profileImage,
    required this.status,
  });

  // Copy constructor for easy status updates
  BookingModel copyWith({
    String? customerName,
    String? service,
    String? date,
    String? time,
    String? bookingId,
    String? price,
    String? profileImage,
    BookingStatus? status,
  }) {
    return BookingModel(
      customerName: customerName ?? this.customerName,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      bookingId: bookingId ?? this.bookingId,
      price: price ?? this.price,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
    );
  }
}

enum BookingStatus { upcoming, pending, canceled }