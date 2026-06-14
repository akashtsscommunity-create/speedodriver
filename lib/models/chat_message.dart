class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String message;
  final String type; // text, voice, image
  final String? attachmentUrl;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.message,
    required this.type,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      bookingId: json['booking_id'],
      senderId: json['sender_id'],
      message: json['message'],
      type: json['type'],
      attachmentUrl: json['attachment_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'sender_id': senderId,
      'message': message,
      'type': type,
      'attachment_url': attachmentUrl,
    };
  }
}
