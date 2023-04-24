import 'dart:convert';

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));

String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  Customer({
    required this.id,
    required this.organizationId,
    required this.name,
    this.nicNo,
    this.address,
    this.telephone,
    this.email,
    this.location,
  });

  final int id;
  final int organizationId;
  final String name;
  final String? nicNo;
  final String? address;
  final String? telephone;
  final String? email;
  final String? location;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
      id: json["id"],
      organizationId: json["organization_id"],
      name: json["name"],
      nicNo: json["nic_no"],
      address: json["address"],
      telephone: json["telephone"],
      email: json["email"],
      location: json["location"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "organization_id": organizationId,
        "name": name,
        "nic_no": nicNo,
        "address": address,
        "telephone": telephone,
        "email": email,
        "location": location
      };
}
