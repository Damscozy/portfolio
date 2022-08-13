// ignore_for_file: constant_identifier_names, unnecessary_null_comparison, prefer_final_fields
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gwong_mfb/app/screens/core/customWidgets.dart';
import 'package:gwong_mfb/appbinding/api_link.dart';
import 'package:gwong_mfb/models/airtime_model.dart';
import 'package:gwong_mfb/models/biller_model.dart';
import 'package:gwong_mfb/models/cable_model.dart';
import 'package:gwong_mfb/models/data_model.dart';
import 'package:gwong_mfb/models/eletric_model.dart';
import 'package:gwong_mfb/models/payment_model.dart';
import 'package:gwong_mfb/models/single_billers_model.dart';
import 'package:gwong_mfb/models/validate_customer_model.dart';
import 'package:gwong_mfb/repository/all_biller_repository.dart';
import 'package:gwong_mfb/repository/auth.dart';
import 'package:http/http.dart' as http;

enum SingleBillerStatus {
  Loading,
  Success,
  UnSuccessful,
  Error,
  Unknown_Error,
  Empty,
  AVAILABLE,
  UNAVAILABLE,
}

enum AirtimeDateStatus {
  Loading,
  Success,
  UnSuccessful,
  Error,
  Unknown_Error,
  Empty,
  AVAILABLE,
  UNAVAILABLE,
}

class BillerRepository extends GetxController {
  final _authController = Get.find<AuthServices>();
  final _payController = Get.find<AllBillerRepository>();

  SingleBillerStatus get singleBillersStatus => _singleBillerStatus.value;
  final Rx<SingleBillerStatus> _singleBillerStatus =
      Rx(SingleBillerStatus.Empty);

  AirtimeDateStatus get airtimeDateStatus => _airtimeDateStatus.value;
  final Rx<AirtimeDateStatus> _airtimeDateStatus = Rx(AirtimeDateStatus.Empty);

  final Rx<List<CatBillersModel>> _billersCategory = Rx([]);
  List<CatBillersModel> get billersCategory => _billersCategory.value;

  final Rx<List<SingleBillersModel>> _singleBillersId = Rx([]);
  final Rx<List<SingleBillersModel>> _singleBillersCategory = Rx([]);

  List<SingleBillersModel> get singleBillerId => _singleBillersId.value;
  List<SingleBillersModel> get singleBillerCategory =>
      _singleBillersCategory.value;

  final Rx<List<PaymentCodeModel>> _allPayment = Rx([]);
  List<PaymentCodeModel> get allPayment => _allPayment.value;

  final Rx<List<ValidateCusModel>> _validCust = Rx([]);
  List<ValidateCusModel> get validCust => _validCust.value;

  final Rx<List<CableModel>> _allCable = Rx([]);
  List<CableModel> get allCable => _allCable.value;

  final Rx<List<EletricModel>> _allEletric = Rx([]);
  List<EletricModel> get allEletric => _allEletric.value;

  final Rx<List<AirtimeModel>> _allAirtime = Rx([]);
  List<AirtimeModel> get allAirtime => _allAirtime.value;

  final Rx<List<DataModel>> _allData = Rx([]);
  List<DataModel> get allData => _allData.value;

  Rx<CableModel?> selectedCable = Rx(null);
  Rx<EletricModel?> selectedElectric = Rx(null);
  Rx<AirtimeModel?> selectedAirtime = Rx(null);
  Rx<DataModel?> selectedData = Rx(null);

  Rx<SingleBillersModel?> selectedSingleBiller = Rx(null);
  Rx<CatBillersModel?> selectedCategory = Rx(null);
  Rx<PaymentCodeModel?> selectedPayment = Rx(null);

  TextEditingController pinController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController prepaidController = TextEditingController();
  TextEditingController decoderController = TextEditingController();
  TextEditingController paymentCodeController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();

  final selected = 'Select'.obs;

  void setSelected(String value) {
    selected.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    _authController.Mtoken.listen((p0) {
      if (p0 != null && p0 != "0") {}
    });

    _payController.selectedBiller.listen(
      (p0) {
        if (p0 != null) {
          getSingleBillersByCategoryId(p0.CategoryId!);
        }
      },
    );

    selectedSingleBiller.listen((p0) {
      if (p0 != null) {
        getPaymentCode('', billerId: p0.BillerId!);
      }
    });

    selectedCategory.listen((p0) {
      if (p0 != null) {
        getSingleBillersById(p0.CategoryId!);
      }
    });

    selectedCable.listen((p0) {
      if (p0 != null) {
        getPaymentCode('', billerId: p0.billerid!);
      }
    });

    selectedElectric.listen((p0) {
      if (p0 != null) {
        getPaymentCode('', billerId: p0.billerid!);
      }
    });

    selectedAirtime.listen((p0) {
      if (p0 != null) {
        getPaymentCode('', billerId: p0.billerid!);
      }
    });

    selectedData.listen((p0) {
      if (p0 != null) {
        getPaymentCode('', billerId: p0.billerid!);
      }
    });
  }

  // Get Single Biller By ID Function
  Future getSingleBillersById(String billersId) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse('${ApiLink.single_biller_billerID}$billersId'),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get single billers by billersid response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);

        final singleBillersId = List.from(json['result']['element'])
            .map((e) => SingleBillersModel.fromJson(e))
            .toList();

        _singleBillersId(singleBillersId);
        getPaymentCode('', billerId: selectedSingleBiller.value!.BillerId!);
        // if (singleBillerId.isEmpty) {
        //   _singleBillerStatus(SingleBillerStatus.Empty);
        // } else {
        //   _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        // }
      } else {
        _singleBillerStatus(SingleBillerStatus.Unknown_Error);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("get single billers by id error ${ex.toString()}");
      }
      _singleBillerStatus(SingleBillerStatus.Error);
    }
  }

  // Get Single Biller By CATEGORY Function
  Future getSingleBillersByCategoryId(String catId) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse('${ApiLink.single_biller_catID}$catId'),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get single billers by category response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);

        final singleBillersCategories =
            List.from(json['result']['body']['billers'])
                .map((e) => SingleBillersModel.fromJson(e))
                .toList();

        _singleBillersCategory(singleBillersCategories);

        // if (singleBillersCategories.isEmpty) {
        // _singleBillerStatus(SingleBillerStatus.Empty);
        // } else {
        //   _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        // }
      } else {
        _singleBillerStatus(SingleBillerStatus.Empty);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("get single billers by category error ${ex.toString()}");
      }
      _singleBillerStatus(SingleBillerStatus.Error);
    }
  }

  // Validate Customer Function
  Future validateCustomer({
    required String paymentCode,
    required String customerId,
  }) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse(
              '${ApiLink.validate_customer}paymentCode=$paymentCode&customerId=$customerId'),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get customer validation response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);

        final allCustomer = List.from(json['result']['Customers'])
            .map((e) => ValidateCusModel.fromJson(e))
            .toList();
        return allCustomer.first.fullName;
        // [
        // allCustomer.first.amount,
        // ];

        // _validCust(allCustomer);
        // if (singleBillersCategories.isEmpty) {
        // _singleBillerStatus(SingleBillerStatus.Empty);
        // } else {
        //   _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        // }
      } else {
        _singleBillerStatus(SingleBillerStatus.Empty);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("get customer validation error ${ex.toString()}");
      }
      _singleBillerStatus(SingleBillerStatus.Error);
    }
  }

  // PAYBILLS FUNCTION
  Future<bool> payBills(
    String billerId,
    String productCode,
    String customerId,
    String amount,
    String pin,
  ) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.post(Uri.parse(ApiLink.pay_bills),
          body: jsonEncode({
            "biller_id": billerId,
            "payment_code": productCode,
            "customer_id": customerId,
            "amount": amount,
            "pin": pin,
          }),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("bill payment response ${response.body}");
      }

      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        Get.snackbar("Success", "Successfully Paid");
        return true;
      } else {
        _singleBillerStatus(SingleBillerStatus.UnSuccessful);
        Get.snackbar("Error", "Unable Pay Bill");
        return false;
      }
    } catch (ex) {
      _singleBillerStatus(SingleBillerStatus.Unknown_Error);
      if (kDebugMode) {
        print("unable to process bill payment status ${ex.toString()}");
      }
      return false;
    }
  }

  // BUY AIRTIME FUNCTION
  Future<bool> buyAirtime(
    String billerId,
    String paymentCode,
    String amount, {
    required String customerId,
    required String pin,
  }) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.post(Uri.parse(ApiLink.buy_airtime),
          body: jsonEncode({
            "biller_id": billerId,
            "payment_code": paymentCode,
            "customer_id": customerId,
            "account_ref": 'GWONG',
            "amount": amount,
            "pin": pin,
          }),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("airtime payment response ${response.body}");
      }

      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        Get.snackbar("Success", "Airtime Purchased Successfully");
        return true;
      } else {
        _singleBillerStatus(SingleBillerStatus.UnSuccessful);
        Get.snackbar("Error", "Unable Purchase Airtime");
        return false;
      }
    } catch (ex) {
      _singleBillerStatus(SingleBillerStatus.Unknown_Error);
      if (kDebugMode) {
        print("unable to process airtime purchase status ${ex.toString()}");
      }
      return false;
    }
  }

  // Get Payments By BillerID Function
  Future<List<PaymentCodeModel>> getPaymentCode(
    filter, {
    required String billerId,
  }) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse('${ApiLink.paymentCode_by_billerID}biller_id=$billerId'),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get payment by billerID response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);

        final allPayment = List.from(json['result']['paymentitems'])
            .map((e) => PaymentCodeModel.fromJson(e))
            .toList();

        _allPayment(allPayment);
        if (selectedPayment.value == null || allPayment.isEmpty) {
          customDescriptionText('Select a plan');
        } else {
          selectedPayment(allPayment.first);
        }

        // if (singleBillersCategories.isEmpty) {
        // _singleBillerStatus(SingleBillerStatus.Empty);
        // } else {
        //   _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        // }
      } else {
        _singleBillerStatus(SingleBillerStatus.Empty);
      }
    } catch (ex) {
      if (kDebugMode) {
        print("get payment code by billerID error ${ex.toString()}");
      }
      _singleBillerStatus(SingleBillerStatus.Error);
    }
    return _allPayment(allPayment);
  }

  // GET ALL CABLES PROVIDERS FUNCTION
  Future<List<CableModel>> getAllCables(filter) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse(
            '${ApiLink.single_biller_catID}2',
          ),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get all cable response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);
        final allCable = List.from(json['result']['body']['billers'])
            .map((e) => CableModel.fromJson(e))
            .toList();
        _allCable(allCable);
        _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        getPaymentCode('', billerId: selectedCable.value!.billerid!);
        if (selectedCable.value == null || allCable.isEmpty) {
          customDescriptionText('Select an operator');
        } else {
          selectedCable(allCable.first);
        }
      } else {
        _singleBillerStatus(SingleBillerStatus.UnSuccessful);
      }
    } catch (ex) {
      _singleBillerStatus(SingleBillerStatus.Unknown_Error);
      // if (kDebugMode) {
      //   print("unable to process airtime purchase status ${ex.toString()}");
      // }
    }
    return _allCable(allCable);
  }

  // GET ALL ELETRICITY PROVIDERS FUNCTION
  Future<List<EletricModel>> getAllElectricity(filter) async {
    try {
      _singleBillerStatus(SingleBillerStatus.Loading);
      final response = await http.get(
          Uri.parse(
            '${ApiLink.single_biller_catID}1',
          ),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get all eletricity response ${response.body}");
      }
      if (response.statusCode == 200) {
        _singleBillerStatus(SingleBillerStatus.Success);
        final json = jsonDecode(response.body);
        final allEletric = List.from(json['result']['body']['billers'])
            .map((e) => EletricModel.fromJson(e))
            .toList();
        _allEletric(allEletric);
        _singleBillerStatus(SingleBillerStatus.AVAILABLE);
        getPaymentCode('', billerId: selectedElectric.value!.billerid!);
        if (selectedElectric.value == null || allEletric.isEmpty) {
          customDescriptionText('Select an operator');
        } else {
          selectedElectric(allEletric.first);
        }
      } else {
        _singleBillerStatus(SingleBillerStatus.UnSuccessful);
      }
    } catch (ex) {
      _singleBillerStatus(SingleBillerStatus.Unknown_Error);
      // if (kDebugMode) {
      //   print("unable to process airtime purchase status ${ex.toString()}");
      // }
    }
    return _allEletric(allEletric);
  }

  // GET ALL AIRTIME PROVIDERS FUNCTION
  Future<List<AirtimeModel>> getAllAirtime(filter) async {
    try {
      _airtimeDateStatus(AirtimeDateStatus.Loading);
      final response = await http.get(
          Uri.parse(
            '${ApiLink.single_biller_catID}3',
          ),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get all airtime response ${response.body}");
      }
      if (response.statusCode == 200) {
        _airtimeDateStatus(AirtimeDateStatus.Success);
        final json = jsonDecode(response.body);
        final allAirtime = List.from(json['result']['body']['billers'])
            .map((e) => AirtimeModel.fromJson(e))
            .toList();
        _allAirtime(allAirtime);
        _airtimeDateStatus(AirtimeDateStatus.AVAILABLE);
        getPaymentCode('', billerId: selectedAirtime.value!.billerid!);
        if (selectedAirtime.value == null || allAirtime.isEmpty) {
          customDescriptionText('Select airtime');
        } else {
          selectedAirtime(allAirtime.first);
        }
      } else {
        _airtimeDateStatus(AirtimeDateStatus.UnSuccessful);
      }
    } catch (ex) {
      _airtimeDateStatus(AirtimeDateStatus.Unknown_Error);
      // if (kDebugMode) {
      //   print("unable to process airtime purchase status ${ex.toString()}");
      // }
    }
    return _allAirtime(allAirtime);
  }

  // GET ALL DATA PROVIDERS FUNCTION
  Future<List<DataModel>> getAllData(filter) async {
    try {
      _airtimeDateStatus(AirtimeDateStatus.Loading);
      final response = await http.get(
          Uri.parse(
            '${ApiLink.single_biller_catID}4',
          ),
          headers: Authorization.getAuthorization());
      if (kDebugMode) {
        print("get all data response ${response.body}");
      }
      if (response.statusCode == 200) {
        _airtimeDateStatus(AirtimeDateStatus.Success);
        final json = jsonDecode(response.body);
        final allData = List.from(json['result']['body']['billers'])
            .map((e) => DataModel.fromJson(e))
            .toList();
        _allData(allData);
        getPaymentCode('', billerId: selectedData.value!.billerid!);
        _airtimeDateStatus(AirtimeDateStatus.AVAILABLE);
        if (selectedData.value == null || allData.isEmpty) {
          customDescriptionText('Select Data');
        } else {
          selectedData(allData.first);
        }
      } else {
        _airtimeDateStatus(AirtimeDateStatus.UnSuccessful);
      }
    } catch (ex) {
      _airtimeDateStatus(AirtimeDateStatus.Unknown_Error);
      // if (kDebugMode) {
      //   print("unable to process data purchase status ${ex.toString()}");
      // }
    }
    return _allData(allData);
  }
}
