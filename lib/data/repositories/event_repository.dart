import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class EventRepository {
  final EventDatasource _datasource;

  EventRepository({EventDatasource? datasource})
      : _datasource = datasource ?? SupabaseEventDatasource();

  Future<List<EventModel>> getAllEvents() => _datasource.getAllEvents();
  Future<void> createEvent(EventModel event) => _datasource.createEvent(event);
  Future<void> deleteEvent(String id) => _datasource.deleteEvent(id);
}
