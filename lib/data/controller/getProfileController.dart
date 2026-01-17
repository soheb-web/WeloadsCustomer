import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/getProfileModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../CustomerScreen/AllIndia/AllIndiaParselListModel.dart';
import '../../CustomerScreen/AllIndia/parcelListModel.dart';
import '../Model/CreateTransactionResponseModel.dart';
import '../Model/PackerCategoryAndSubcategoryModel.dart';
import '../Model/RecommendedModel.dart';





final getParcelListController = FutureProvider.autoDispose<ParcelResponseListModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.getParcelList();
});


final getAllIndiaController = FutureProvider.autoDispose<AllIndiaResponseListModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.getPackerAndMoveBookingList();
});


final getProfileController = FutureProvider.autoDispose<GetProfileModel>((
  ref,
) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.fetchProfile();
});



final getTransactionController = FutureProvider.autoDispose<TransactionListResponseModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.getTxList();
});


final getPackersCategoryController = FutureProvider.autoDispose<PackerCategoryAndSubCategoryModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.getPackersCategoryOrSubCategory();
});


final recommendController = FutureProvider.autoDispose<RecommendedModel>((
    ref,
    ) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.recommendedList();
});


