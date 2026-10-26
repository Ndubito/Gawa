import 'package:dio/dio.dart';
import 'package:flutter_1/core/network/api_client.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_cycle_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_member_model.dart';
import 'package:flutter_1/features/subscriptions/domain/entities/subscription_model.dart';
import 'package:flutter_1/features/subscriptions/domain/repos/subscriptions_repo.dart';

class SubscriptionsRepoImpl extends SubscriptionsRepo {
  final Dio _dio = ApiClient().dio;

  /// Surface the backend's message (e.g. "Group not found") when present.
  String _message(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return e.message ?? fallback;
  }

  //Create a subscription (recipient/organizer derived from the auth token)
  @override
  Future<SubscriptionModel> createSubscription(SubscriptionModel subscription) async {
    try {
      final res = await _dio.post('/subscriptions', data: subscription.toCreateJson());
      return SubscriptionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create subscription: ${_message(e, 'unknown error')}');
    }
  }

  //Get a single subscription
  @override
  Future<SubscriptionModel> getSubscription(int subscriptionId) async {
    try {
      final res = await _dio.get('/subscriptions/$subscriptionId');
      return SubscriptionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to fetch subscription: ${_message(e, 'unknown error')}');
    }
  }

  //List a group's subscriptions (newest first)
  @override
  Future<List<SubscriptionModel>> getGroupSubscriptions(int groupId) async {
    try {
      final res = await _dio.get('/subscriptions/group/$groupId');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(SubscriptionModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch subscriptions: ${_message(e, 'unknown error')}');
    }
  }

  //List every subscription across the current user's groups
  @override
  Future<List<SubscriptionModel>> getMySubscriptions() async {
    try {
      final res = await _dio.get('/subscriptions/mine');
      final data = (res.data as List).cast<Map<String, dynamic>>();
      return data.map(SubscriptionModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch subscriptions: ${_message(e, 'unknown error')}');
    }
  }

  //Update a subscription's mutable fields
  @override
  Future<SubscriptionModel> updateSubscription(
    int subscriptionId,
    SubscriptionModel subscription,
  ) async {
    try {
      final res = await _dio.patch(
        '/subscriptions/$subscriptionId',
        data: subscription.toUpdateJson(),
      );
      return SubscriptionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update subscription: ${_message(e, 'unknown error')}');
    }
  }

  //Delete (soft) a subscription
  @override
  Future<void> deleteSubscription(int subscriptionId) async {
    try {
      await _dio.delete('/subscriptions/$subscriptionId');
    } on DioException catch (e) {
      throw Exception('Failed to delete subscription: ${_message(e, 'unknown error')}');
    }
  }

  // No backend endpoints yet — these land with the cycles/obligations feature.
  @override
  Future<List<SubscriptionMemberModel>> getMembers(int subscriptionId) =>
      throw UnimplementedError('Subscription members arrive with the obligations feature');

  @override
  Future<List<SubscriptionCycleModel>> getCycles(int subscriptionId) =>
      throw UnimplementedError('Subscription cycles arrive with the obligations feature');
}
