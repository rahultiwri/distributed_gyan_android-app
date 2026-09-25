class CustomerModel {
  final int custcode;
  final String custname;
  final String address;
  final String city;
  final String mobile;
  final String distch;

  CustomerModel({
    required this.custcode,
    required this.custname,
    required this.address,
    required this.city,
    required this.mobile,
    required this.distch,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      custcode: json['custcode'] ?? 0,
      custname: (json['custname'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      distch: (json['distch'] ?? '').toString(),
    );
  }
}