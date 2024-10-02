import 'package:flutter/material.dart';
import 'package:nexaura/theme/theme.dart';

class FormContainerWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPasswordField;
  final String? hintText;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final TextInputType? inputType;
  final bool? enable;

  const FormContainerWidget(
      {super.key,
      this.controller,
      this.isPasswordField,
      this.fieldKey,
      this.hintText,
      required this.labelText,
      this.validator,
      this.inputType, this.enable});

  @override
  State<FormContainerWidget> createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      key: widget.fieldKey,
      enabled: widget.enable ?? true,
      obscureText: widget.isPasswordField == true ? _obscureText : false,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        label: Text(widget.labelText),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.black26,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black12, // Default border color
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: widget.isPasswordField == true
              ? Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: _obscureText == false
                      ? lightColorScheme.primary
                      : Colors.grey,
                )
              : const Text(""),
        ),
      ),
    );
  }
}
