import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:toby_bills/app/core/extensions/num_extension.dart';
import 'package:toby_bills/app/core/extensions/string_ext.dart';
import 'package:toby_bills/app/core/utils/app_storage.dart';
import 'package:toby_bills/app/core/utils/printing_methods_helper.dart';
import 'package:toby_bills/app/core/utils/show_popup_text.dart';
import 'package:toby_bills/app/core/utils/user_manager.dart';
import 'package:toby_bills/app/data/model/customer/dto/request/create_customer_request.dart';
import 'package:toby_bills/app/data/model/customer/dto/request/find_customer_balance_request.dart';
import 'package:toby_bills/app/data/model/customer/dto/request/find_customer_request.dart';
import 'package:toby_bills/app/data/model/customer/dto/response/find_customer_balance_response.dart';
import 'package:toby_bills/app/data/model/customer/dto/response/find_customer_response.dart';
import 'package:toby_bills/app/data/model/general_journal/dto/request/find_general_journal_request.dart';
import 'package:toby_bills/app/data/model/inventory/dto/request/get_inventories_request.dart';
import 'package:toby_bills/app/data/model/inventory/dto/response/inventory_response.dart';
import 'package:toby_bills/app/data/model/invoice/dto/gl_pay_dto.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/create_invoice_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/delete_invoice_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/gallery_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/get_delegator_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/get_delivery_place_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/get_due_date_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/get_invoice_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/request/offerone_request.dart';
import 'package:toby_bills/app/data/model/invoice/dto/response/gallery_response.dart';
import 'package:toby_bills/app/data/model/invoice/dto/response/invoice_response.dart';
import 'package:toby_bills/app/data/model/invoice/dto/response/get_delegator_response.dart';
import 'package:toby_bills/app/data/model/invoice/dto/response/get_due_date_response.dart';
import 'package:toby_bills/app/data/model/invoice/invoice_detail_model.dart';
import 'package:toby_bills/app/data/model/item/dto/request/item_price_request.dart';
import 'package:toby_bills/app/data/model/item/dto/request/get_items_request.dart';
import 'package:toby_bills/app/data/model/item/dto/request/item_data_request.dart';
import 'package:toby_bills/app/data/model/item/dto/response/item_data_response.dart';
import 'package:toby_bills/app/data/model/item/dto/response/item_response.dart';
import 'package:toby_bills/app/data/model/reports/dto/request/edit_bills_request.dart';
import 'package:toby_bills/app/data/repository/customer/customer_repository.dart';
import 'package:toby_bills/app/data/repository/general_journal/general_journal_repository.dart';
import 'package:toby_bills/app/data/repository/inventory/inventory_repository.dart';
import 'package:toby_bills/app/data/repository/invoice/invoice_repository.dart';
import 'package:toby_bills/app/data/repository/item/item_repository.dart';
import 'package:toby_bills/app/data/repository/reports/reports_repository.dart';
// import 'package:window_manager/window_manager.dart';
import '../../../core/enums/toast_msg_type.dart';
import '../../../core/values/app_constants.dart';
import '../../../data/model/invoice/dto/response/get_delivery_place_response.dart';

class HomeController extends GetxController {

  final isLoading = false.obs;
  final isProof = false.obs;
  final checkSendSms = false.obs;
  final isItemProof = false.obs;
  final isItemRemains = false.obs;
  final totalNet = RxNum(0.0);
  final discountHalala = RxNum(0.0);
  final totalAfterDiscount = RxNum(0.0);
  final tax = RxNum(0.0);
  final finalNet = RxNum(0.0);
  final remain = RxNum(0.0);
  final payed = RxNum(0.0);
  final itemAvailableQuantity = RxnNum();
  final itemNet = RxnNum();
  final itemTotalQuantity = RxnNum();
  num itemNetWithoutDiscount = 0;
  String? offerCoupon;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Rxn<DeliveryPlaceResposne> selectedDeliveryPlace = Rxn();
  Rxn<DelegatorResponse> selectedDelegator = Rxn();
  Rxn<String> selectedInvoiceType = Rxn("????????????");
  Rxn<int> selectedPriceType = Rxn(1);
  Rxn<int> selectedDiscountType = Rxn(0);
  Rxn<GalleryResponse> selectedGallery = Rxn();
  Rxn<FindCustomerResponse> selectedCustomer = Rxn();
  Rxn<InventoryResponse> selectedInventory = Rxn();
  Rxn<ItemResponse> selectedItem = Rxn();
  FindCustomerBalanceResponse? findCustomerBalanceResponse;

  final findSideCustomerController = TextEditingController();
  final searchedInvoiceController = TextEditingController();
  final invoiceCustomerController = TextEditingController();
  final invoiceDiscountController = TextEditingController();
  final invoiceRemarkController = TextEditingController();
  final itemNameController = TextEditingController();
  final itemNotesController = TextEditingController();
  final itemPriceController = TextEditingController();
  final itemQuantityController = TextEditingController();
  final itemNumberController = TextEditingController();
  final itemDiscountController = TextEditingController();
  final itemDiscountValueController = TextEditingController();

  final searchedInvoiceFocusNode = FocusNode();
  final findSideCustomerFieldFocusNode = FocusNode();
  final invoiceCustomerFieldFocusNode = FocusNode();
  final invoiceDiscountFieldFocusNode = FocusNode();
  final itemNameFocusNode = FocusNode();
  final itemNotesFocusNode = FocusNode();
  final itemPriceFocusNode = FocusNode();
  final itemQuantityFocusNode = FocusNode();
  final itemNumberFocusNode = FocusNode();
  final itemDiscountFocusNode = FocusNode();
  final itemDiscountValueFocusNode = FocusNode();

  final customers = <FindCustomerResponse>[].obs;
  final deliveryPlaces = <DeliveryPlaceResposne>[];
  final delegators = <DelegatorResponse>[];
  final inventories = <InventoryResponse>[];
  final items = <ItemResponse>[];
  final galleries = <GalleryResponse>[];
  final glPayDtoList = <GlPayDTO>[];
  final invoiceDetails = <Rx<InvoiceDetailsModel>>[].obs;
  Rxn<GetDueDateResponse> dueDate = Rxn();
  Rx<DateTime> date = Rx(DateTime.now());
  Rxn<InvoiceModel> invoice = Rxn();

  Map<int, String> priceTypes = {
    1: "??????????",
    0: "????????????",
  };

  Map<int, String> discountType = {
    0: "????????",
    1: "????????",
  };

  static const getBuilderSerial = "getBuilderSerial";

  bool get canEdit => UserManager().user.userScreens["proworkorder"]?.edit??false;

  @override
  void onInit() async {
    super.onInit();
    // windowManager.setTitle("Toby Bills -> ???????? ????????????????");
    isLoading(true);
    _addItemFieldsListener();
    items.addAll(_getItemsFromStorage());
    if (items.isEmpty) {
      getItems();
    }
    await getGalleries();
    Future.wait([getDueDate(), getGlPayDtoList(), getDeliveryPlaces(), getDelegators(), getInventories()]).whenComplete(() => isLoading(false));
  }

  getCustomersByCode() {
    isLoading(true);
    findSideCustomerFieldFocusNode.unfocus();
    final request = FindCustomerRequest(code: findSideCustomerController.text, branchId: UserManager().branchId, gallaryIdAPI: UserManager().galleryId);
    CustomerRepository().findCustomerByCode(request,
        onSuccess: (data) {
          customers.assignAll(data);
          findSideCustomerFieldFocusNode.requestFocus();
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  getCustomersByCodeForInvoice() {
    isLoading(true);
    invoiceCustomerFieldFocusNode.unfocus();
    final request = FindCustomerRequest(code: invoiceCustomerController.text, branchId: UserManager().branchId, gallaryIdAPI: UserManager().galleryId);
    CustomerRepository().findCustomerByCode(request,
        onSuccess: (data) {
          customers.assignAll(data);
          invoiceCustomerFieldFocusNode.requestFocus();
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  Future<void> getDueDate({bool withLoading = false}) {
    if(withLoading) isLoading(true);
    return InvoiceRepository().findDueDateDTOAPI(
      GetDueDateRequest(branchId: UserManager().branchId, id: selectedGallery.value?.id),
      onSuccess: (data) => dueDate(data),
      onError: (error) => showPopupText(text: error.toString()),
      onComplete: (){
        if(withLoading) {
            isLoading(false);
          }
        }
    );
  }


  Future<void> getGlPayDtoList() {
    return ReportsRepository().getAllGlPay(
      AllInvoicesRequest(branchId: UserManager().branchId, id: UserManager().id),
      onSuccess: (data) => glPayDtoList.assignAll(data),
      onError: (error) => showPopupText(text: error.toString()),
    );
  }

  Future<void> getGalleries() {
    return InvoiceRepository().getGalleries(
      GalleryRequest(branchId: UserManager().branchId, id: UserManager().id),
      onSuccess: (data) {
        galleries.assignAll(data);
        if (galleries.any((element) => element.id == UserManager().galleryId)) {
          selectedGallery(galleries.singleWhere((element) => element.id == UserManager().galleryId));
        } else if (galleries.isNotEmpty) {
          selectedGallery(galleries.first);
        }
      },
      onError: (error) => showPopupText(text: error.toString()),
    );
  }

  Future<void> getDeliveryPlaces() {
    return InvoiceRepository().findInventoryByBranch(
      DeliveryPlaceRequest(branchId: UserManager().branchId, id: UserManager().id),
      onSuccess: (data) {
        deliveryPlaces.assignAll(data);
        if (deliveryPlaces.isNotEmpty) {
          selectedDeliveryPlace(deliveryPlaces.first);
        }
      },
      onError: (error) => showPopupText(text: error.toString()),
    );
  }

  Future<void> getDelegators() {
    return InvoiceRepository().findDelegatorByInventory(
      DelegatorRequest(gallaryId: UserManager().galleryId, branchId: UserManager().branchId),
      onSuccess: (data) => {delegators.assignAll(data), if (delegators.isNotEmpty) selectedDelegator(delegators.first)},
      onError: (error) => showPopupText(text: error.toString()),
    );
  }

  Future<void> getInventories() {
    return InventoryRepository().getAllInventories(GetInventoriesRequest(branchId: UserManager().branchId, id: UserManager().id),
        onSuccess: (data) {
          inventories.assignAll(data);
          if (inventories.isNotEmpty) {
            selectedInventory(inventories.first);
          }
        },
        onError: (error) => showPopupText(text: error.toString()));
  }

  void createCustomer(CreateCustomerRequest newCustomer) {
    isLoading(true);
    newCustomer.companyId = UserManager().companyId;
    newCustomer.createdBy = UserManager().id;
    newCustomer.branchId = UserManager().branchId;
    newCustomer.accountIdAPI = UserManager().accountIdAPI;
    newCustomer.gallaryIdAPI = selectedGallery.value?.id;
    CustomerRepository().createCustomer(
      newCustomer,
      onSuccess: (data) {
        data.name = newCustomer.name;
        data.mobile = newCustomer.mobile;
        data.email = newCustomer.email;
        invoiceCustomerController.text = "${data.name} ${data.code}";
        selectedCustomer(data);
        getCustomerBalance(data.id!);
        showPopupText(text: "???? ?????????? ???????????? ??????????", type: MsgType.success);
      },
      onError: (error) => showPopupText(text: error.toString()),
      onComplete: () => isLoading(false),
    );
  }

  getInvoiceListForCustomer(FindCustomerResponse value) {
    findSideCustomerController.text = "${value.name} ${value.code}";
    isLoading(true);
    CustomerRepository().findCustomerInvoicesData(FindCustomerBalanceRequest(id: value.id),
        onSuccess: (data) => findCustomerBalanceResponse = data, onError: (error) => showPopupText(text: error.toString()), onComplete: () => isLoading(false));
  }

  printInvoice(BuildContext context) {
    isLoading(true);
    InvoiceRepository()
        .findInvPurchaseInvoiceBySerialNew(GetInvoiceRequest(serial: invoice.value!.serial.toString(), branchId: UserManager().branchId, gallaryId: null, typeInv: 4),
            onSuccess: (data) {
              PrintingHelper().printInvoice(context, data,
                  dariba: data.taxvalue,
                  total: data.totalNetAfterDiscount,
                  discount: data.discount,
                  value: data.totalNet,
                  net: data.finalNet,
                  payed: data.payed,
                  remain: data.remain);
            },
            onError: (error) => showPopupText(text: error.toString()),
            onComplete: () => isLoading(false));
  }

  printGeneralJournal(BuildContext context) {
    isLoading(true);
    GeneralJournalRepository().findGeneralJournalById(FindGeneralJournalRequest(invoice.value!.generalJournalId),
        onSuccess: (data) {
          PrintingHelper().printGeneralJournal(data, context);
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  searchForInvoiceById(String id) async {
    newInvoice(resetDueDate: false);
    isLoading(true);
    searchedInvoiceFocusNode.unfocus();
    await InvoiceRepository().findInvPurchaseInvoiceBySerialNew(GetInvoiceRequest(serial: id, branchId: UserManager().branchId, gallaryId: null, typeInv: 4),
        onSuccess: (data) {
          invoice(data);
          selectedPriceType(data.pricetype);
          if (galleries.any((element) => element.id == data.gallaryId)) {
            selectedGallery(galleries.singleWhere((element) => element.id == data.gallaryId));
            UserManager().changeGallery(selectedGallery.value);
          } else {
            selectedGallery.value = null;
          }
          date(data.date);
          dueDate.value!.dueDate = data.dueDate;
          dueDate.value!.dayNumber = data.dueperiod;
          selectedDeliveryPlace(deliveryPlaces.singleWhere((element) => element.name == data.deliveryPlaceName));
          selectedInvoiceType(AppConstants.invoiceTypeList[data.invoiceType == null ? 0 : data.invoiceType! + 1]);
          if (delegators.any((element) => element.id == data.invDelegatorId)) {
            selectedDelegator(delegators.singleWhere((element) => element.id == data.invDelegatorId));
          } else {
            selectedDelegator(null);
          }
          isProof(data.proof == 1);
          invoiceDiscountController.text = data.discount.toString();
          selectedDiscountType(data.discountType);
          checkSendSms(data.checkSendSms == 1);
          invoiceRemarkController.text = data.remarks ?? '';
          for (final detail in data.invoiceDetailApiList!) {
            if (!items.any((element) => element.id == detail.itemId)) {
              showPopupText(text: "???????? ?????? ?????????? ???? ?????????? ???? ???????????????? ?????? ????????");
              return;
            }
            final item = items.singleWhere((element) => element.id == detail.itemId);
            detail.maxPriceMen = item.maxPriceMen;
            detail.maxPriceYoung = item.maxPriceYoung;
            detail.minPriceMen = item.minPriceMen;
            detail.minPriceYoung = item.minPriceYoung;
            detail.typeInv = data.typeInv;
          }
          invoiceDetails.assignAll((data.invoiceDetailApiList ?? []).map((e) => Rx(e)).toList().obs);
          selectedCustomer(FindCustomerResponse(
            id: data.customerId,
            mobile: data.customerMobile,
            name: data.customerName,
            code: data.customerCode,
            balanceLimit: data.customerBalance,
            email: data.customerEmail,
            shoulder: data.shoulder,
            step: data.step,
            length: data.length,
          ));
          invoiceCustomerController.text = "${data.customerName} ${data.customerCode}";
          discountHalala(data.discHalala);
          calcInvoiceValues();
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  getCustomerBalance(int id) {
    isLoading(true);
    CustomerRepository().getCustomerBalance(FindCustomerBalanceRequest(id: id),
        onSuccess: (data) {
          selectedCustomer.value!.balanceLimit = data;
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  List<ItemResponse> _getItemsFromStorage() {
    List<dynamic> items = AppStorage.read("items") ?? [];
    final itemsList = List<ItemResponse>.from(items.map((e) => ItemResponse.fromJson(e)));
    return itemsList;
  }

  getItems() {
    isLoading(true);
    ItemRepository().getAllItems(GetItemRequest(branchId: UserManager().branchId),
        onSuccess: (data) {
          items.assignAll(data);
          GetStorage().write("items", data.map((e) => e.toJson()).toList());
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  List<ItemResponse> filterItems(String filter) {
    return items.where((element) => element.code.toString().contains(filter) || element.name.toString().contains(filter)).toList();
  }

  _clearItemFields() {
    selectedItem.value = null;
    itemNameController.clear();
    itemNumberController.clear();
    itemQuantityController.clear();
    itemPriceController.clear();
    itemNotesController.clear();
    itemDiscountController.clear();
    itemDiscountValueController.clear();
    isItemProof(false);
    isItemRemains(false);
    itemAvailableQuantity.value = null;
    itemNet.value = null;
    itemTotalQuantity.value = null;
    if(inventories.isNotEmpty) {
      selectedInventory(inventories.first);
    }
  }

  selectItem(ItemResponse item, {void Function()? noQuantity}) {
    if (selectedCustomer.value == null) {
      showPopupText(text: "???????? ???????????? ???????? ??????????");
      return;
    }
    if (selectedInventory.value == null) {
      showPopupText(text: "???????? ???????????? ???????????? ??????????");
      return;
    }
    itemNameFocusNode.unfocus();
    getItemData(
        itemId: item.id!,
        onSuccess: (data) {
          if (data.availableQuantity != null && data.availableQuantity! <= 0) {
            if (noQuantity != null) {
              noQuantity();
            } else {
              showPopupText(text: "???? ???????? ???????? ??????????");
              itemNameController.clear();
              itemNameFocusNode.requestFocus();
            }
            return;
          }
          itemNameController.text = "${item.name} ${item.code}";
          // if (data.availableQuantity != null) {
          //   item.tempNumber = (data.availableQuantity! / data.quantityOfUnit).fixed(2);
          // }
          itemNumberController.text = "1.0";
          itemQuantityController.text = data.quantityOfUnit.toString();
          // item.quantity = data.quantityOfUnit;
          itemPriceController.text = data.sellPrice.toString();
          itemDiscountController.text = data.discountRow.toString();
          itemDiscountValueController.text = "0";
          itemAvailableQuantity(data.availableQuantity);
          selectedItem(item..itemData = data);
          calcItemData();
          Future.delayed(const Duration(milliseconds: 50)).whenComplete(() => itemNumberFocusNode.requestFocus());

        });
  }

  getItemData({required int itemId, required void Function(ItemDataResponse itemDataResponse) onSuccess, int? inventoryId}) async {
    final customer = selectedCustomer.value!;
    if ((customer.step ?? -1) <= 0.0 && (customer.shoulder ?? -1) <= 0.0 && (customer.length ?? -1) <= 0.0) {
      showPopupText(text: "?????? ?????????? ???????????? ????????????");
      return;
    }
    isLoading(true);
    final manager = UserManager();
    final request = ItemDataRequest(
        id: itemId,
        customerId: customer.id,
        priceType: selectedPriceType.value!,
        inventoryId: inventoryId ?? selectedInventory.value!.id,
        invNameGallary: manager.galleryType);
    await ItemRepository()
        .getItemData(request, onSuccess: onSuccess, onError: (error) => {showPopupText(text: error.toString()), _clearItemFields()}, onComplete: () => isLoading(false));
  }

  calcItemData() {
    final number = itemNumberController.text.parseToNum;
    final quantity = itemQuantityController.text.parseToNum;
    itemTotalQuantity((quantity * number).fixed(2));
    itemNetWithoutDiscount = ((itemPriceController.text.parseToNum) * number).fixed(2);
    final discount = itemDiscountController.text.tryToParseToNum ?? 0;
    final discountValue = itemDiscountValueController.text.tryToParseToNum ?? 0;
    itemNet((itemNetWithoutDiscount - (itemNetWithoutDiscount * (discount / 100)) - discountValue).fixed(2));
  }

  selectInventory(InventoryResponse? value) {
    final oldInv = selectedInventory.value;
    selectedInventory(value);
    if (selectedItem.value != null && selectedItem.value!.isInventoryItem == 1) {
      // _getItemPrice();
      selectItem(
        selectedItem.value!,
        noQuantity: () {
          showPopupText(text: "???????????? ???????? ?????????? ???? ???????????????? ????????????");
          selectedInventory(oldInv);
        },
      );
    }
  }

  addNewInvoiceDetail() {
    if (selectedItem.value == null) return;
    final item = selectedItem.value!;
    final detail = InvoiceDetailsModel(
            progroupId: item.proGroupId,
            typeShow: item.typeShow,
            typeInv: 4,
            lastCost: item.lastCost,
            remark: itemNotesController.text,
            name: item.name!,
            number: itemNumberController.text.parseToNum,
            quantityOfOneUnit: itemQuantityController.text.parseToNum,
            code: item.code,
            minPriceMen: item.minPriceMen,
            minPriceYoung: item.minPriceYoung,
            maxPriceMen: item.maxPriceMen,
            maxPriceYoung: item.maxPriceYoung,
            quantity: itemQuantityController.text.parseToNum * itemNumberController.text.parseToNum,
            net: itemNet.value,
            availableQuantityRow: itemAvailableQuantity.value,
            price: itemPriceController.text.parseToNum,
            unitName: item.unitName,
            discount: itemDiscountController.text.parseToNum,
            discountValue: itemDiscountValueController.text.parseToNum,
            inventoryName: selectedInventory.value!.name,
            inventoryCode: selectedInventory.value!.code,
            inventoryId: selectedInventory.value!.id,
            itemId: item.id,
            proof: isItemProof.value ? 1 : 0,
            netWithoutDiscount: itemNetWithoutDiscount,
            remnants: isItemRemains.value ? 1 : 0)
        .obs;

    invoiceDetails.add(detail);
    calcInvoiceValues();
    _clearItemFields();
    itemNameFocusNode.requestFocus();
  }

  _getItemPrice() {
    isLoading(true);
    final item = selectedItem.value!;
    final request = ItemPriceRequest(
        id: item.id!,
        inventoryId: selectedInventory.value!.id,
        customerId: selectedCustomer.value!.id,
        priceType: selectedPriceType.value!,
        quantityOfUnit: itemQuantityController.text.parseToNum,
        invNameGallary: UserManager().galleryType);
    ItemRepository().getItemPrice(request,
        onSuccess: (data) {
          selectedItem.value!.sellPrice = data.sellPrice;
          itemPriceController.text = data.sellPrice.toString();
          calcItemData();
        },
        onError: (error) => showPopupText(text: error.toString()),
        onComplete: () => isLoading(false));
  }

  onItemNumberFieldSubmitted(String value) {
    if (selectedItem.value != null && selectedItem.value!.proGroupId == 1) {
      itemPriceFocusNode.requestFocus();
    } else {
      itemQuantityFocusNode.requestFocus();
    }
  }

  saveInvoice() {
    if (invoiceDetails.isEmpty) {
      showPopupText(text: "?????? ?????????? ??????????");
      return;
    }
    final isEdit = invoice.value != null;
    final request = CreateInvoiceRequest(
      id: invoice.value?.id,
      payed: payed.value,
      customerId: selectedCustomer.value!.id,
      customerCode: selectedCustomer.value!.code,
      customerMobile: selectedCustomer.value!.mobile,
      customerName: selectedCustomer.value!.name,
      discHalala: discountHalala.value,
      dueDate: dueDate.value?.dueDate,
      dueperiod: dueDate.value?.dayNumber,
      finalNet: finalNet.value,
      totalNet: totalNet.value,
      gallaryDeliveryId: selectedDeliveryPlace.value?.id,
      gallaryDeliveryName: selectedDeliveryPlace.value?.name,
      gallaryName: UserManager().galleryName,
      branchId: UserManager().branchId,
      gallaryId: UserManager().galleryId,
      date: date.value,
      checkSendSms: checkSendSms.value ? 1 : 0,
      companyId: UserManager().companyId,
      createdBy: UserManager().id,
      createdDate: DateTime.now(),
      glPayDTOList: glPayDtoList,
      invDelegatorId: selectedDelegator.value?.id,
      invoiceDetailApiList: invoiceDetails.map((element) => element.value).toList(),
      invoiceDetailApiListDeleted: invoice.value?.invoiceDetailApiListDeleted!.map((element) => element).toList(),
      invoiceType: AppConstants.invoiceTypeList.indexOf(selectedInvoiceType.value!) == 0 ? null : AppConstants.invoiceTypeList.indexOf(selectedInvoiceType.value!) - 1,
      pricetype: selectedPriceType.value,
      typeInv: 4,
      proof: isProof.value ? 1 : 0,
      remarks: invoiceRemarkController.text,
      taxvalue: tax.value,
      totalNetAfterDiscount: totalAfterDiscount.value,
      offerCopoun: offerCoupon,
      serial: invoice.value?.serial,
      invInventoryId: 45,
      discount: invoiceDiscountController.text.tryToParseToNum,
      discountType: selectedDiscountType.value,
    );
    isLoading(true);
    InvoiceRepository().saveInvoice(request,
        onSuccess: (data) async {
          invoice(data);
          invoiceDetails.assignAll((data.invoiceDetailApiList??[]).map((e) => e.obs).toList());
          for (var element in glPayDtoList) {
            element.value = 0;
          }
          // await InvoiceRepository().saveTarhil(data,
          //     onSuccess: (data) {
          //       invoice.value!.serial = data.serial;
          //       invoice.value!.qrCode = data.qrCode;
          //       invoice.value!.daribaValue = data.daribaValue;
          //       invoice.value!.segilValue = data.segilValue;
          //       showPopupText(text: isEdit ? "???? ?????????? ???????????????? ??????????" : "???? ?????? ???????????????? ??????????", type: MsgType.success);
          //       update([getBuilderSerial]);
          //     },
          //     onError: (e) {
          //       showPopupText(text: e.toString());
          //     },
          //     onComplete: () => isLoading(false));
        },
        onError: (e) {
          showPopupText(text: e.toString());
          isLoading(false);
        },
        onComplete: () => isLoading(false));
  }

  newInvoice({bool resetDueDate = true}) {
    _clearItemFields();
    if (priceTypes.keys.isNotEmpty) selectedPriceType(priceTypes.keys.first);
    if (discountType.keys.isNotEmpty) selectedDiscountType(discountType.keys.first);
    if (deliveryPlaces.isNotEmpty) selectedDeliveryPlace(deliveryPlaces.first);
    if (delegators.isNotEmpty) selectedDelegator(delegators.first);
    invoiceDiscountController.clear();
    selectedInvoiceType(AppConstants.invoiceTypeList.first);
    isProof(false);
    checkSendSms(false);
    invoiceRemarkController.clear();
    selectedCustomer.value = null;
    invoiceDetails.clear();
    invoiceCustomerController.clear();
    discountHalala(0);
    calcInvoiceValues();
    invoice.value = null;
    for (var element in glPayDtoList) {
      element.value = 0;
    }
    if(resetDueDate) {
      getDueDate(withLoading: true);
    }
  }

  calcInvoiceValues() {
    num net = 0;
    for (final invoiceDetailsModel in invoiceDetails) {
      net += invoiceDetailsModel.value.net!;
    }
    totalNet(net);
    num discount = 0;
    if (selectedDiscountType.value == 0) {
      discount = invoiceDiscountController.text.tryToParseToNum ?? 0;
    } else {
      discount = net * ((invoiceDiscountController.text.tryToParseToNum ?? 0) / 100);
    }
    totalAfterDiscount(net - discountHalala.value - discount);
    tax(totalAfterDiscount.value * 0.15);
    finalNet((totalAfterDiscount.value + tax.value).fixed(2));
    payed(glPayDtoList.fold<num>(0, (p, e) => p+(e.value??0)));
    remain(finalNet.value - payed.value);
  }

  removeHalala() {
    int number = finalNet.value.toInt();
    num remain = finalNet.value - number;
    discountHalala(remain / 1.15);
    calcInvoiceValues();
  }

  retreiveHalala() {
    discountHalala(0);
    calcInvoiceValues();
  }

  _addItemFieldsListener() {
    itemNumberFocusNode.addListener(_itemNumberListener);
    itemQuantityFocusNode.addListener(_itemQuantityListener);
    itemPriceFocusNode.addListener(_itemPriceListener);
  }

  _removeItemFieldsListener() {
    itemNumberFocusNode.removeListener(_itemNumberListener);
    itemQuantityFocusNode.removeListener(_itemQuantityListener);
    itemPriceFocusNode.removeListener(_itemPriceListener);
  }

  bool _isQuantityValid() {
    final number = itemNumberController.text.tryToParseToNum;
    final quantity = itemQuantityController.text.tryToParseToNum;
    if (number == null || quantity == null) return true;
    return !(itemAvailableQuantity.value != null && itemAvailableQuantity.value! < (number * quantity));
  }

  _itemNumberListener() {
    if (!itemNumberFocusNode.hasFocus) {
      if (selectedItem.value == null || itemNumberController.text.tryToParseToNum == selectedItem.value!.tempNumber) return;
      if (!_isQuantityValid()) {
        showPopupText(text: "???? ???????? ?????????? ?????? ??????????");
        itemNumberController.text = selectedItem.value!.tempNumber.toString();
      } else {
        selectedItem.value!.tempNumber = itemNumberController.text.parseToNum;
      }
      // if(itemNumberController.text.tryToParseToNum != null) {
      itemTotalQuantity(itemNumberController.text.parseToNum * itemQuantityController.text.parseToNum);
      // }
      calcItemData();
    }
  }

  _itemQuantityListener() {
    if (!itemQuantityFocusNode.hasFocus) {
      if (selectedItem.value == null || itemQuantityController.text.tryToParseToNum == selectedItem.value!.tempQuantity) return;
      if (!_isQuantityValid()) {
        showPopupText(text: "???? ???????? ?????????? ?????? ????????????");
        itemQuantityController.text = selectedItem.value!.tempQuantity.toString();
      } else {
        if (selectedItem.value!.isInventoryItem == 1) {
          _getItemPrice();
        }
        selectedItem.value!.tempQuantity = itemQuantityController.text.parseToNum;
      }
      // if(itemQuantityController.text.tryToParseToNum != null) {
      itemTotalQuantity(itemNumberController.text.parseToNum * itemQuantityController.text.parseToNum);
      // }
      calcItemData();
    }
  }

  _itemPriceListener() {
    if (!itemPriceFocusNode.hasFocus) {
      final price = itemPriceController.text.tryToParseToNum;
      if (price == null) return;
      final item = selectedItem.value!;
      if(UserManager().galleryType == 0){
        if (selectedPriceType.value == 1 && price < item.minPriceMen!) {
          showPopupText(text: "?????????? ?????? ????????");
          itemPriceController.text = item.minPriceMen.toString();
        }
        else if (selectedPriceType.value == 0 && price < item.minPriceYoung!) {
          showPopupText(text: "?????????? ?????? ????????");
          itemPriceController.text = item.minPriceYoung.toString();
        }
      } else if(UserManager().galleryType == 1){
        if (selectedPriceType.value == 1 && price < (item.minPriceMen! * 0.85)) {
          showPopupText(text: "?????????? ?????? ????????");
          itemPriceController.text = item.minPriceMen.toString();
        }
        else if (selectedPriceType.value == 0 && price < (item.minPriceYoung! * 0.85)) {
          showPopupText(text: "?????????? ?????? ????????");
          itemPriceController.text = item.minPriceYoung.toString();
        }

      }
    }
  }

  @override
  void onClose() {
    _removeItemFieldsListener();
    super.onClose();
  }

  void changePriceType(int? value) async {
    selectedPriceType(value);
    final details = <Rx<InvoiceDetailsModel>>[];
    for (final detail in invoiceDetails) {
      final item = items.singleWhere((element) => element.id == detail.value.itemId);
      await getItemData(
          itemId: item.id!,
          onSuccess: (itemData) {
            item.itemData = itemData;
            final newDetail = detail.value.assignItem(item);
            details.add(Rx(newDetail));
          },
          inventoryId: detail.value.inventoryId);
    }
    if (selectedItem.value != null) {
      await getItemData(
          itemId: selectedItem.value!.id!,
          onSuccess: (itemData) {
            selectedItem.value!.itemData = itemData;
            itemPriceController.text = itemData.sellPrice.toString();
            calcItemData();
          });
    }
    invoiceDetails.assignAll(details);
    calcInvoiceValues();
  }

  deleteInvoice() {
    isLoading(true);
    InvoiceRepository().deleteInvoice(
        DeleteInvoiceRequest(invoice.value?.id),
      onSuccess: (_){
        showPopupText(text: "???? ?????????? ??????????",type: MsgType.success);
        newInvoice();
      },
      onError: (e)=>showPopupText(text: e.toString()),
      onComplete: () => isLoading(false)
    );
  }

  offerOne() {
    final request = OfferOneRequest(invoiceDetailApiList: invoiceDetails.map((element) => element.value).toList(), galleryType: UserManager().galleryType);
    isLoading(true);
    InvoiceRepository().offerOne(request,
      onSuccess: (data){
        invoiceDetails.assignAll(data.map((e) => e.obs));
        calcInvoiceValues();
      },
      onError: (e) => showPopupText(text: e.toString()),
      onComplete: ()=> isLoading(false)
    );
  }

  void updateCustomer() {
    isLoading(true);
    CustomerRepository().updateCustomer(
      selectedCustomer.value!,
      onSuccess: (data) {
        showPopupText(text: "???? ?????????????? ??????????", type: MsgType.success);
      },
      onError: (error) => showPopupText(text: error.toString()),
      onComplete: () => isLoading(false),
    );
  }
}
