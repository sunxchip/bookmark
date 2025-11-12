import 'package:bookmark/features/reading/domain/entities/reading_session.dart';
import 'package:bookmark/features/reading/domain/repositories/reading_repository.dart';

class WatchSession {
  final ReadingRepository repo;
  WatchSession(this.repo);

  Stream<ReadingSession?> call(String sessionId) => repo.watchSession(sessionId);
}
