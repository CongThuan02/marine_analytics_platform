# Add Edit Functionality for Areas, Departments & Waste Types

## Overview
This guide shows how to add edit functionality to Areas, Departments, and Waste Types.

## Implementation Strategy
Instead of creating separate edit screens, we'll reuse the create bottom sheets with edit mode.

## Steps for Each Entity

### 1. Areas Edit

#### A. Add UpdateArea Event & Handler
File: `lib/presentation/blocs/area/area_event.dart`
```dart
class UpdateArea extends AreaEvent {
  final String id;
  const UpdateArea({required this.id});
  
  @override
  List<Object?> get props => [id];
}

class SetEditMode extends AreaEvent {
  final String? id;
  final String? name;
  const SetEditMode({this.id, this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

#### B. Add Edit State
File: `lib/presentation/blocs/area/area_state.dart`
```dart
class AreaState extends Equatable {
  final String name;
  final String message;
  final Status status;
  final List<AreaModel>? areas;
  final String? editingId; // Add this
  
  const AreaState({
    required this.name,
    required this.message,
    this.status = Status.init,
    this.areas,
    this.editingId, // Add this
  });
  
  AreaState copyWith({
    String? name,
    String? message,
    Status? status,
    List<AreaModel>? areas,
    String? editingId, // Add this
  }) {
    return AreaState(
      name: name ?? this.name,
      message: message ?? this.message,
      status: status ?? this.status,
      areas: areas ?? this.areas,
      editingId: editingId ?? this.editingId, // Add this
    );
  }
}
```

#### C. Add Update Handler in BLoC
File: `lib/presentation/blocs/area/area_bloc.dart`
```dart
AreaBloc() : super(AreaState(name: '', message: '')) {
  on<CreateArea>(_createArea);
  on<UpdateArea>(_updateArea); // Add this
  on<SetEditMode>(_setEditMode); // Add this
  on<UpdateFieldName>(_updateFileName);
  on<GetAreas>(_getAreas);
  on<DeleteArea>(_deleteAreas);
}

Future<void> _setEditMode(SetEditMode event, Emitter<AreaState> emit) async {
  emit(state.copyWith(
    editingId: event.id,
    name: event.name ?? '',
    status: Status.init,
  ));
}

Future<void> _updateArea(UpdateArea event, Emitter<AreaState> emit) async {
  emit(state.copyWith(status: Status.loading));
  var res = await _areaRepository.updateArea(
    id: event.id,
    area: AreaModel(
      id: event.id,
      name: state.name,
      createdAt: DateTime.now(),
    ),
  );
  emit(state.copyWith(
    message: res,
    status: Status.success,
    editingId: null, // Clear edit mode
  ));
}
```

#### D. Add Update Method in Repository
File: `lib/data/repositories/area_repository.dart`
```dart
Future<String> updateArea({required String id, required AreaModel area}) async {
  try {
    await supabase
        .from('areas')
        .update({'name': area.name})
        .eq('id', id);
    return 'Area updated successfully';
  } catch (e) {
    return 'Error: $e';
  }
}
```

#### E. Update Create Bottom Sheet to Support Edit
File: `lib/presentation/views/areas/create/page.dart`

Add edit button to list items:
```dart
ListTile(
  title: Text(area.name),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.edit, color: AppTheme.primaryGreen),
        onPressed: () => _showEditBottomSheet(context, bloc, area),
      ),
      IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () => _showDeleteDialog(context, bloc, area.id, area.name),
      ),
    ],
  ),
)
```

Add edit bottom sheet method:
```dart
void _showEditBottomSheet(BuildContext context, AreaBloc bloc, AreaModel area) {
  // Set edit mode
  bloc.add(SetEditMode(id: area.id, name: area.name));
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: bloc,
      child: _EditAreaBottomSheet(area: area),
    ),
  );
}
```

#### F. Update Create/Update Logic in Bottom Sheet
```dart
ElevatedButton(
  onPressed: () {
    final isEditing = state.editingId != null;
    if (isEditing) {
      bloc.add(UpdateArea(id: state.editingId!));
    } else {
      bloc.add(CreateArea());
    }
  },
  child: Text(state.editingId != null ? 'Update' : 'Create'),
)
```

### 2. Departments Edit
Apply the same pattern as Areas:
- Add `UpdateDepartment` event
- Add `SetEditMode` event  
- Add `editingId` to state
- Add update handler in BLoC
- Add update method in repository
- Add edit button to list items
- Update bottom sheet to support edit mode

### 3. Waste Types Edit
Apply the same pattern as Areas and Departments.

## Quick Implementation

I'll implement this for Areas first, then you can see the pattern and apply it to others.

## Benefits
- ✅ Reuses existing UI components
- ✅ Consistent UX across all entities
- ✅ Minimal code duplication
- ✅ Easy to maintain

## Testing
1. Open Areas page
2. Click edit icon on an area
3. Modify the name
4. Click Update
5. Verify the area is updated in the list
