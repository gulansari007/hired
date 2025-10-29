import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget appTextField({
  required TextEditingController controller,
  required String hint,
  String? label,
  bool obscure = false,
  TextInputType type = TextInputType.text,
  Widget? prefix,
  Widget? suffix,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  required TextInputType keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    ),
  );
}
// dropdown widget

Widget genderSelector({
  required RxString selected,
  required List<String> options,
  required String? Function(String? value) validator,
}) {
  return Obx(
    () => Wrap(
      spacing: 12,
      children:
          options.map((gender) {
            final isSelected = selected.value == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (_) => selected.value = gender,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              selectedColor: Theme.of(Get.context!).primaryColor,
              backgroundColor: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            );
          }).toList(),
    ),
  );
}

// dob

Widget dobSelector({
  required Rx<DateTime?> selectedDate,
  required BuildContext context,
  String label = 'Date of Birth',
}) {
  return Obx(() {
    final isSelected = selectedDate.value != null;
    final display =
        isSelected
            ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
            : '$label';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate.value ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          selectedDate.value = picked;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                display,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}
