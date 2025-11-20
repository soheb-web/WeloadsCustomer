import 'dart:developer';

import 'package:delivery_mvp_app/CustomerScreen/Newscreen.dart';
import 'package:delivery_mvp_app/data/controller/getDeliveryHistoryController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/network/api.state.dart';
import '../data/Model/getDeliveryHistoryResModel..dart';
import 'DetailPage.dart';

class DeliveryHistoryScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  const DeliveryHistoryScreen(this.socket, {super.key});

  @override
  ConsumerState<DeliveryHistoryScreen> createState() =>
      _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends ConsumerState<DeliveryHistoryScreen> {
  Color _getStatusColor(String? status) {
    String statusStr = status?.toString().split('.').last ?? "not_assigned";

    switch (status.toString().toLowerCase()) {
      case "assigned":
        return const Color(0xFFE3F2FD);
      case "ongoing":
      case "picked":
        return const Color(0xFF7DCF4A); // green
      case "not_assigned":
      case "no_driver_found":
        return const Color(0xFFFFEBEE); // red
      case "completed":
        return const Color(0xFFE8F5E9); // green
      case "cancelled_by_user":
      case "cancelled_by_driver":
        return const Color(0xFFFFCDD2); // dark red
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getStatusTextColor(String? status) {
    String statusStr = status?.toString().split('.').last ?? "not_assigned";

    switch (status.toString().toLowerCase()) {
      case "assigned":
        return const Color(0xFF0D47A1); // dark blue
      case "not_assigned":
        return const Color(0xFFC62828); // dark red
      case "completed":
        return const Color(0xFF2E7D32); // dark green
      case "pending":
        return const Color(0xFF7E6604); // dark yellow-brown
      default:
        return const Color(0xFF424242); // dark gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvier = ref.watch(getDeliveryHistoryController);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: RefreshIndicator(
        backgroundColor: Color(0xFF006970),
        color: Colors.white,
        onRefresh: () async {
          ref.invalidate(getDeliveryHistoryController);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40.h),
            Row(
              children: [
                SizedBox(width: 25.w),
                Text(
                  "Delivery History",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111111),
                    letterSpacing: -1.1,
                  ),
                ),
                Spacer(),
                Container(
                  width: 32.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Color(0xFFF0F5F5),
                  ),
                  child: Center(
                    child: SvgPicture.asset("assets/SvgImage/icon.svg"),
                  ),
                ),
                SizedBox(width: 24.w),
              ],
            ),
            SizedBox(height: 15.h),
            historyProvier.when(
              data: (history) {
                if (history.data!.deliveries!.isEmpty) {
                  return Center(
                    child: Text(
                      "No History Available",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                  );
                }
                DateTime date = DateTime.fromMillisecondsSinceEpoch(
                  1761395019837,
                );
                String formattedDate = DateFormat(
                  "dd MMMM yyyy, h:mma",
                ).format(date);

                String pretty(String s) => s
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w[0].toUpperCase() + w.substring(1))
                    .join(' ');

                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: history.data!.deliveries!.length,
                    itemBuilder: (context, index) {
                      log(history.data!.deliveries![index].name.toString());
                      return GestureDetector(
                        onTap: () {
                          history.data!.deliveries![index].status.toString() ==
                                      "assigned" ||
                                  history.data!.deliveries![index].status
                                          .toString() ==
                                      "ongoing"
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PickupScreenNotification(
                                          socket: widget.socket,
                                          deliveryId:
                                              history
                                                  .data!
                                                  .deliveries![index]
                                                  .id ??
                                              "",
                                        ),
                                  ),
                                )
                              :
                                //                           history.data!.deliveries![index].status=="assigned" ||    history.data!.deliveries![index].status=="ongoing"?
                                //
                                //                           Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                //                               PickupScreenNotification(
                                // socket: widget.socket,
                                //                                   deliveryId: history.data!.deliveries![index].id??"",
                                //                               )))
                                //
                                //                               :
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RequestDetailsPage(
                                      deliveryId:
                                          history.data!.deliveries![index].id ??
                                          "",
                                    ),
                                  ),
                                );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 15.h,
                            left: 25.w,
                            right: 25.w,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    // "ORDB1234",
                                    history.data!.deliveries![index].id ?? "",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF0C341F),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Receipient: ${history.data!.deliveries![index].name ?? "Unknow"}",
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF545454),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                      Spacer(),
                                      Container(
                                        padding: EdgeInsets.only(
                                          left: 6.w,
                                          right: 6.w,
                                          top: 2.h,
                                          bottom: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            3.r,
                                          ),
                                          // color: Color(0xFFFFF4C7),
                                          color: _getStatusColor(
                                            history
                                                .data!
                                                .deliveries![index]
                                                .status,
                                          ),
                                        ),
                                        child: Center(
                                          child:
                                              // Text(
                                              //     // ASSIGNED,
                                              //     // CANCELLED_BY_DRIVER,
                                              //     // CANCELLED_BY_USER,
                                              //     // COMPLETED,
                                              //     // NOT_ASSIGNED,
                                              //     // NO_DRIVER_FOUND,
                                              //     // ONGOING,
                                              //     // PICKED
                                              //   // "In progress",
                                              //   history.data!.deliveries![index].status.toString()=="CANCELLED_BY_DRIVER"?"Cancel":"",
                                              //   style: GoogleFonts.inter(
                                              //     fontSize: 12.sp,
                                              //     fontWeight: FontWeight.w500,
                                              //     // color: Color(0xFF7E6604),
                                              //     // color: _getStatusTextColor(
                                              //     //   history
                                              //     //       .data!
                                              //     //       .deliveries![index]
                                              //     //       .status,
                                              //     // ),
                                              //   ),
                                              // ),
                                              // child:
                                              Text(
                                                pretty(
                                                  history
                                                          .data!
                                                          .deliveries![index]
                                                          .status ??
                                                      "",
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: _getStatusTextColor(
                                                    history
                                                        .data!
                                                        .deliveries![index]
                                                        .status,
                                                  ),
                                                ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 35.w,
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      color: Color(0xFFF7F7F7),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/SvgImage/bikess.svg",
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 16.sp,
                                              color: Color(0xFF27794D),
                                            ),
                                            SizedBox(width: 5.w),
                                            Text(
                                              "Drop off",
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF545454),
                                              ),
                                            ),
                                          ],
                                        ),

                                        ...history
                                            .data!
                                            .deliveries![index]
                                            .dropoff!
                                            .map(
                                              (d) => Padding(
                                                padding: EdgeInsets.only(
                                                  left: 3.w,
                                                  bottom: 4.h,
                                                ),
                                                child: Text(
                                                  d.name ?? "",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF0C341F),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        SizedBox(height: 2.h),
                                        Text(
                                          //2 January 2020, 2:43pm",
                                          DateFormat("dd MMMM yyyy, h:mma")
                                              .format(
                                                DateTime.fromMillisecondsSinceEpoch(
                                                  history
                                                      .data!
                                                      .deliveries![index]
                                                      .createdAt!,
                                                ),
                                              )
                                              .toLowerCase(),
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF545454),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Divider(color: Color(0xFFDCE8E9)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                log(stackTrace.toString());
                return Center(child: Text(error.toString()));
              },
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

String getReadableStatus(String status) {
  switch (status) {
    case "CANCELLED_BY_DRIVER":
      return "Cancelled By Driver";
    case "CANCELLED_BY_USER":
      return "Cancelled By User";
    case "ASSIGNED":
      return "Assigned";
    case "NOT_ASSIGNED":
      return "Not Assigned";
    case "NO_DRIVER_FOUND":
      return "No Driver Found";
    case "ONGOING":
      return "Ongoing";
    case "PICKED":
      return "Picked";
    case "COMPLETED":
      return "Completed";
    default:
      return status;
  }
}
