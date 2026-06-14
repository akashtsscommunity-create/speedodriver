class LinkedAccount {
  final int emailAccountId;
  final String name;
  final String email;
  final int userId;
  final String emailAddress;
  final String displayName;
  final bool isCurrentAccount;
  final bool isPrimary;
  final int accountHolder_UserId;

  LinkedAccount({
    required this.emailAccountId,
    required this.name,
    required this.email,
    required this.userId,
    required this.emailAddress,
    required this.displayName,
    required this.isCurrentAccount,
    required this.isPrimary,
    required this.accountHolder_UserId,
  });

  factory LinkedAccount.fromApi(Map<String, dynamic> json) {
    return LinkedAccount(
      emailAccountId: json['emailAccountId'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userId: json['userId'],
      emailAddress: json['emailAddress'] ?? '',
      displayName: json['displayName'] ?? '',
      isCurrentAccount: json['isCurrentAccount'],
      isPrimary: json['isPrimary'] ,
      accountHolder_UserId: json['accountHolder_UserId'] ,
    );
  }

  Map<String, dynamic> toJson() => {
    'emailAccountId': emailAccountId,
    'name': name,
    'email': email,
    'userId': userId,
    'emailAddress': emailAddress,
    'displayName': displayName,
    'isCurrentAccount': isCurrentAccount,
    'isPrimary': isPrimary,
    'accountHolder_UserId': accountHolder_UserId,
  };

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      emailAccountId: json['emailAccountId'],
      name: json['name'],
      email: json['email'],
      userId: json['userId'],
      emailAddress: json['emailAddress'],
      displayName: json['displayName'],
      isCurrentAccount: json['isCurrentAccount'],
      isPrimary: json['isPrimary'],
      accountHolder_UserId: json['accountHolder_UserId'],
    );
  }
}