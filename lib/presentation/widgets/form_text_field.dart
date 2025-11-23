import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormTextField extends StatelessWidget {
  final String name;
  final String? label;
  final String? hintText;
  final void Function(String?)? onChanged;

  const FormTextField({super.key, required this.name, this.label, this.onChanged, this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: FormBuilderTextField(
          onChanged: onChanged,
          name: name,
          decoration: InputDecoration(border: .none, hintText: hintText, label: label != null ? Text(label!) : null),
        ),
      ),
    );
  }
}
