import 'package:favors_manager/friend.dart';

class Favor {
  final String uuid;
  final String description;
  final Friend friend;
  final DateTime? dueDate;
  final bool? accepted;
  final DateTime? completed;

  Favor({
    required this.uuid,
    required this.description,
    required this.friend,
    this.dueDate,
    this.accepted,
    this.completed,
  });

  /// returns true if the favor is active ( the user is doing it )
  get isDoing => accepted == true && completed == null;

  /// returns true if the user has not answered the request yet
  get isRequested => accepted == null;

  /// returns true if the favor is already completed
  get isCompleted => completed != null;

  /// returns true if the favor was not accepted
  get isRefused => accepted == false;
}
