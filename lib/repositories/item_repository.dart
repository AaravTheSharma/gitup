import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

class ItemRepository {
  final SharedPreferences _prefs;
  static const String _itemsKey = 'storage_items';

  ItemRepository(this._prefs);

  // Get all items
  Future<List<Item>> getAllItems() async {
    final String? itemsJson = _prefs.getString(_itemsKey);
    if (itemsJson == null) {
      return [];
    }

    try {
      final List<dynamic> itemsList = jsonDecode(itemsJson) as List<dynamic>;
      return itemsList
          .map((i) => Item.fromJson(i as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving item data: $e');
      return [];
    }
  }

  // Save all items
  Future<bool> saveItems(List<Item> items) async {
    try {
      final String itemsJson = jsonEncode(
        items.map((i) => i.toJson()).toList(),
      );
      return await _prefs.setString(_itemsKey, itemsJson);
    } catch (e) {
      print('Error saving item data: $e');
      return false;
    }
  }

  // Add a new item
  Future<bool> addItem(Item item) async {
    final items = await getAllItems();
    items.add(item);
    return await saveItems(items);
  }

  // Update an existing item
  Future<bool> updateItem(Item oldItem, Item newItem) async {
    final items = await getAllItems();
    final index = items.indexWhere(
      (item) =>
          item.name == oldItem.name &&
          item.location == oldItem.location &&
          item.subLocation == oldItem.subLocation &&
          item.addedDate.isAtSameMomentAs(oldItem.addedDate),
    );

    if (index != -1) {
      items[index] = newItem;
      return await saveItems(items);
    }

    return false;
  }

  // Delete an item by reference
  Future<bool> deleteItemByReference(Item itemToDelete) async {
    final items = await getAllItems();
    final initialLength = items.length;

    items.removeWhere(
      (item) =>
          item.name == itemToDelete.name &&
          item.location == itemToDelete.location &&
          item.subLocation == itemToDelete.subLocation &&
          item.addedDate.isAtSameMomentAs(itemToDelete.addedDate),
    );

    if (items.length < initialLength) {
      return await saveItems(items);
    }

    return false;
  }

  // Delete an item
  Future<bool> deleteItem(
    String name,
    String location,
    String subLocation,
  ) async {
    final items = await getAllItems();
    final initialLength = items.length;

    items.removeWhere(
      (item) =>
          item.name == name &&
          item.location == location &&
          item.subLocation == subLocation,
    );

    if (items.length < initialLength) {
      return await saveItems(items);
    }

    return false;
  }

  // Get items by location
  Future<List<Item>> getItemsByLocation(String location) async {
    final items = await getAllItems();
    return items.where((item) => item.location == location).toList();
  }

  // Search items
  Future<List<Item>> searchItems(String query) async {
    final items = await getAllItems();
    return Item.searchItems(items, query);
  }

  // Get recently added items
  Future<List<Item>> getRecentlyAddedItems({int limit = 5}) async {
    final items = await getAllItems();
    return Item.getRecentlyAdded(items, limit: limit);
  }

  // Get location distribution
  Future<Map<String, int>> getLocationDistribution() async {
    final items = await getAllItems();
    return Item.getLocationDistribution(items);
  }

  // Get location percentages
  Future<Map<String, double>> getLocationPercentages() async {
    final items = await getAllItems();
    return Item.getLocationPercentages(items);
  }

  // Get total item count
  Future<int> getTotalItemCount() async {
    final items = await getAllItems();
    return items.length;
  }

  // Get count of items added in the last 30 days
  Future<int> getRecentItemCount() async {
    final items = await getAllItems();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return items.where((item) => item.addedDate.isAfter(thirtyDaysAgo)).length;
  }
}
