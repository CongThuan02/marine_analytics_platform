import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormTextField extends StatefulWidget {
  final String name;
  final String? label;
  final String? hintText;
  final String? value;
  final bool autofocus;
  final bool isPassword;
  final Widget? suffixIcon;
  final void Function(String?)? onChanged;
  final List<String? Function(String?)>? validators;

  FormTextField({
    super.key,
    required this.name,
    this.label,
    this.hintText,
    this.value,
    this.autofocus = false,
    this.isPassword = false,
    this.suffixIcon,
    this.validators,
    this.onChanged,
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  bool hidePassword = false;

  @override
  void initState() {
    super.initState();
    hidePassword = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      name: widget.name,
      validator: FormBuilderValidators.compose([...?widget.validators]),
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: field.hasError ? Colors.red : Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  // controller: TextEditingController(text: field.value)
                  //   ..selection = TextSelection.collapsed(offset: field.value?.length ?? 0),
                  obscureText: hidePassword,
                  autofocus: widget.autofocus,
                  onChanged: (value) {
                    field.didChange(value);
                    widget.onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    labelText: widget.label,
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            onPressed: () {
                              setState(() => hidePassword = !hidePassword);
                            },
                            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                          )
                        : widget.suffixIcon,
                  ),
                ),
              ),
            ),

            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Text(field.errorText!, style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        );
      },
    );
  }
}
