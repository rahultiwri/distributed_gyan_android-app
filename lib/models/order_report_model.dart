class OrderReportModel {
  final String msg;
  final String accode;
  final String ordershift;
  final String orderstatus;
  final String orderdate;
  final String ordervalue;
  final String crate;
  final String jaali;
  final String imgurl;
  final String remarks;
  final String ovnarr;
  final List<String> topgroups;
  final Map<String, List<OrderReportProduct>> products;

  const OrderReportModel({
    required this.msg,
    required this.accode,
    required this.ordershift,
    required this.orderstatus,
    required this.orderdate,
    required this.ordervalue,
    required this.crate,
    required this.jaali,
    required this.imgurl,
    required this.remarks,
    required this.ovnarr,
    required this.topgroups,
    required this.products,
  });

  factory OrderReportModel.fromJson(Map<String, dynamic> json) {
    final topGroups = <String>[];
    final products = <String, List<OrderReportProduct>>{};

    final groups = json['topgroups'];

    if (groups is List) {
      for (final group in groups) {
        final groupName = group.toString();

        topGroups.add(groupName);

        final groupData = json[groupName];

        if (groupData is List) {
          products[groupName] = groupData
              .whereType<Map>()
              .map(
                (item) => OrderReportProduct.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();
        } else {
          products[groupName] = [];
        }
      }
    }

    return OrderReportModel(
      msg: json['msg']?.toString() ?? '',
      accode: json['accode']?.toString() ?? '',
      ordershift: json['ordershift']?.toString() ?? '',
      orderstatus: json['orderstatus']?.toString() ?? '',
      orderdate: json['orderdate']?.toString() ?? '',
      ordervalue: json['ordervalue']?.toString() ?? '',
      crate: json['crate']?.toString() ?? '0',
      jaali: json['jaali']?.toString() ?? '0',
      imgurl: json['imgurl']?.toString() ?? '',
      remarks: json['remarks']?.toString() ?? '',
      ovnarr: json['ovnarr']?.toString() ?? '',
      topgroups: topGroups,
      products: products,
    );
  }
}

class OrderReportProduct {
  final String prdname;
  final String prdcode;
  final String qty;

  const OrderReportProduct({
    required this.prdname,
    required this.prdcode,
    required this.qty,
  });

  factory OrderReportProduct.fromJson(
      Map<String, dynamic> json,
      ) {
    return OrderReportProduct(
      prdname: json['prdname']?.toString() ?? '',
      prdcode: json['prdcode']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '0',
    );
  }
}