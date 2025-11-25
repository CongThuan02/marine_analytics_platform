part of 'waste_type_bloc.dart';

class WasteTypeState extends Equatable {
  final String? message;
  final List<WasteTypeModel>? items;
  final Status? status;
  final WasteTypeModel? wasteTypeModel;

  const WasteTypeState({this.message, this.items, this.status, this.wasteTypeModel = const WasteTypeModel()});

  WasteTypeState copyWith({
    final String? message,
    final List<WasteTypeModel>? items,
    final Status? status,
    final WasteTypeModel? wasteTypeModel,
  }) {
    return WasteTypeState(
      message: message ?? this.message,
      items: items ?? this.items,
      status: status ?? this.status,
      wasteTypeModel: wasteTypeModel ?? this.wasteTypeModel,
    );
  }

  @override
  List<Object?> get props => [message, items, status, wasteTypeModel];
}
