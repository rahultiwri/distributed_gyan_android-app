
class BannerModel {
final String id;
final String desc;
final String imgurl;
final String onclick;

BannerModel({
required this.id,
required this.desc,
required this.imgurl,
required this.onclick,
});

factory BannerModel.fromJson(Map<String, dynamic> json) {
return BannerModel(
id: json['id']?.toString() ?? '',
desc: json['desc']?.toString() ?? '',
imgurl: json['imgurl']?.toString() ?? '',
onclick: json['onclick']?.toString() ?? '',
);
}
}

