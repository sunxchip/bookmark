import 'package:bookmark/features/reading/domain/repositories/reading_repository.dart';
import 'package:bookmark/features/reading/domain/entities/reading_record.dart';

class AddReadingRecord {
  final ReadingRepository repo;
  AddReadingRecord(this.repo);

  Future<void> call(String sessionId, ReadingRecord record) {
    return repo.addRecord(sessionId: sessionId, record: record);
  }
}
