import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';

abstract class EventDatasource {
  Future<List<EventModel>> getAllEvents();
  Future<void> createEvent(EventModel event);
  Future<void> deleteEvent(String id);
}

class SupabaseEventDatasource implements EventDatasource {
  @override
  Future<List<EventModel>> getAllEvents() async {
    try {
      final response = await SupabaseService.eventsTable
          .select()
          .order('event_date', ascending: true);
      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching events', e);
      return [];
    }
  }

  @override
  Future<void> createEvent(EventModel event) async {
    try {
      await SupabaseService.eventsTable.insert(event.toJson());
    } catch (e) {
      AppLogger.error('Error creating event', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await SupabaseService.eventsTable.delete().eq('id', id);
    } catch (e) {
      AppLogger.error('Error deleting event', e);
      rethrow;
    }
  }
}
