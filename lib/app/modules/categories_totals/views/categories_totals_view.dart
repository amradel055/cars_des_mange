import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:multiselect/multiselect.dart';
import 'package:toby_bills/app/core/utils/user_manager.dart';
import 'package:toby_bills/app/core/values/app_constants.dart';

import '../../../components/table.dart';
import '../../../core/utils/excel_helper.dart';
import '../../../core/utils/printing_methods_helper.dart';
import '../controllers/categories_totals_controller.dart';

class CategoriesTotalsView extends GetView<CategoriesTotalsController> {
  const CategoriesTotalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            UnconstrainedBox(
              child: ElevatedButton(
                child: Text("رجوع"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            UnconstrainedBox(
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.salesReports.isEmpty ? null : () => PrintingHelper().printSalesReports(context, controller.salesReports),
                  child: const Text("طباعة"),
                );
              }),
            ),
            const SizedBox(width: 10),
            UnconstrainedBox(
              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.salesReports.isEmpty ? null : () => ExcelHelper.salesReportsExcel(controller.salesReports, context),
                  child: const Text("تصدير الى اكسل"),
                );
              }),
            ),
            const SizedBox(width: 10),
            UnconstrainedBox(
              child: ElevatedButton(
                child: const Text("بحث"),
                onPressed: () {},
              ),
            ),
          ],
        ),
        actions: [
          Obx(() {
            return SizedBox(
              width: 200,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropDownMultiSelect(
                  key: UniqueKey(),
                  options: controller.symbols.map((e) => e.name ?? "").toList(),
                  selectedValues: controller.selectedSymbols.map((e) => e.name ?? "").toList(),
                  onChanged: (values) {
                    controller.selectNewSymbols(values);
                  },
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  childBuilder: (List<String> values) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          values.isEmpty ? "يرجى تحديد فئة على الاقل" : values.where((element) => element != "تحديد الكل").join(', '),
                          maxLines: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
          const Center(
            child: Text(
              "اختر فئة: ",
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 15),
          Center(
            child: SizedBox(
              width: 190,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownSearch<String>(
                  key: UniqueKey(),
                  items: AppConstants.invoiceTypeList,
                  onChanged: (value) {
                    if (value == AppConstants.invoiceTypeList.first) {
                      controller.invoiceTypeSelected = null;
                    } else {
                      controller.invoiceTypeSelected = AppConstants.invoiceTypeList.indexOf(value!) - 1;
                    }
                  },
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Center(
              child: Text(
                'نوع الفاتوره:',
                textDirection: TextDirection.rtl,
              )),
          const SizedBox(width: 15),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    controller.pickToDate();
                  },
                  child: Obx(() {
                    return Text(
                      DateFormat("yyyy-MM-dd").format(controller.dateTo.value),
                      style: const TextStyle(decoration: TextDecoration.underline),
                    );
                  })),
            ),
          ),
          const Center(
            child: Text(
              "الى تاريخ: ",
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 15),
          Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () {
                    controller.pickFromDate();
                  },
                  child: Obx(() {
                    return Text(
                      DateFormat("yyyy-MM-dd").format(controller.dateFrom.value),
                      style: const TextStyle(decoration: TextDecoration.underline),
                    );
                  })),
            ),
          ),
          const Center(
            child: Text(
              "من تاريخ: ",
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Obx(() {
        final reports = controller.salesReports;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: TableWidget(
            header: [
              "الكود",
              "الفئة",
              "العدد",
              "سعر البيع",
              "التكلفة",
            ]
                .map((e) =>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(e, textAlign: TextAlign.center),
                ))
                .toList(),
            headerHeight: 40,
            rows: [
              [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    "",
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    UserManager().galleryName,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    reports.fold<num>(0, (p, e) => p + (e.number??0)).toStringAsFixed(2),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    reports.fold<num>(0, (p, e) => p + (e.allCost??0)).toStringAsFixed(2),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    reports.fold<num>(0, (p, e) => p + (e.allAvarageCost??0)).toStringAsFixed(2),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
              for (final report in reports)
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      report.code.toString(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      report.name.toString(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      report.number.toString(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      report.allCost.toString(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      report.allAvarageCost.toString(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
            ],
            minimumCellWidth: 120,
            rowHeight: 50,
            rowColor: (index) => index == 0
                ? Colors.green
                : index % 2 == 0
                ? Colors.black12
                : Colors.white,
          ),
        );
      },
      ),
    );
  }
}