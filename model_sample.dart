// ignore_for_file: non_constant_identifier_names, prefer_initializing_formals

class AllBillersCategory {
  String? CategoryId;
  String? CategoryName;
  String? CategoryDescription;

  AllBillersCategory({
    String? CategoryId,
    String? CategoryName,
    String? CategoryDescription,
  }) {
    this.CategoryId = CategoryId;
    this.CategoryName = CategoryName;
    this.CategoryDescription = CategoryDescription;
  }
  factory AllBillersCategory.fromJson(Map<String, dynamic> json) =>
      AllBillersCategory(
        CategoryId: json["categoryid"],
        CategoryName: json["categoryname"],
        CategoryDescription: json["categorydescription"],
      );

  Map<String, dynamic> toJson() => {
        "categoryid": CategoryId,
        "categoryname": CategoryName,
        "categorydescription": CategoryDescription,
      };
}
