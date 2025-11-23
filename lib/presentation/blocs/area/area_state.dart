part of 'area_bloc.dart';

class AreaState extends Equatable {
  final String name;
  final String message;
  final Status status;
  final List<AreaModel>? areas;
  const AreaState({required this.name, required this.message, this.status = Status.init, this.areas});

  AreaState copyWith({final String? name, final String? message, final Status? status, final List<AreaModel>? areas}) {
    return AreaState(
      name: name ?? this.name,
      message: message ?? this.message,
      status: status ?? this.status,
      areas: areas ?? this.areas,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [name, message, status, areas];
}
