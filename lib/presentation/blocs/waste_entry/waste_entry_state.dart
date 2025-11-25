part of 'waste_entry_bloc.dart';

class WasteEntryState extends Equatable {
  final List<WasteEntryModel> entries;
  final Status status;
  final String? message;

  const WasteEntryState({
    this.entries = const [],
    this.status = Status.init,
    this.message,
  });

  WasteEntryState copyWith({
    List<WasteEntryModel>? entries,
    Status? status,
    String? message,
    bool clearMessage = false,
  }) {
    return WasteEntryState(
      entries: entries ?? this.entries,
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [entries, status, message];
}

