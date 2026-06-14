import 'package:flutter/material.dart';
import 'app_colors.dart';
class AppStyles {
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static styleForElevatedButton() {
    return ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Optional: round the corners
      ),
    );
  }

  static InputDecoration inputDecorationForSearchbar(String hintText) {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.grayLight, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: 10));
  }

  static Text textStyleForHintCenter(String strValue) {
    return (Text(strValue,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black)));
  }

  static Text textStyleCenterWithOutSize(String? strValue) {
    return (Text(
      strValue ?? "N/A",
      textAlign: TextAlign.center,
      overflow: TextOverflow.visible,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppColors.white, fontSize: 16),
    ));
  }

  static Text textStyleForVersionCode(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textColor,
          fontSize: 18),
    ));
  }

  static Text textStyleForVersionCodeBlack(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppColors.black, fontSize: 18),
    ));
  }

  static InputDecoration inputEditTextBorderWithOutIcon(String? hintText1) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white,
      hintText: hintText1 ?? "",
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.0),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
    );
  }

  static InputDecoration inputEditTextBorder(String hintText, Icon icon) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      // Set to true to enable background color
      fillColor: AppColors.white,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.white, width: 2)),
      prefixIcon: icon,
    );
  }

  static const styleSmallSizeWithWhiteColor = TextStyle(
    fontSize: 14,
    color: AppColors.white,
  );

  static const styleSmallSizeWithBlackColor = TextStyle(
    fontSize: 14,
    color: AppColors.black,
  );

  static const styleNormalSizeWithWhiteColor = TextStyle(
    fontSize: 16,
    color: AppColors.white,
  );

  static const styleNormalSizeWithBlackColor = TextStyle(
    fontSize: 16,
    color: AppColors.black,
  );

  static const styleLargeSizeWithWhiteColor = TextStyle(
    fontSize: 18,
    color: AppColors.white,
  );

  static const styleLargeSizeWithBlackColor = TextStyle(
    fontSize: 18,
    color: AppColors.black,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    color: AppColors.white,
  );

  static const styleHintSmallSizeWithWhiteColor = TextStyle(
    fontSize: 14,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
  );

  static const styleHintSmallSizeWithBlackColorBold = TextStyle(
    color: AppColors.black,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const styleHintSmallSizeWithBlackColorNor = TextStyle(
    color: AppColors.black,
    fontSize: 14,
  );

  static const styleHintNormalSizeWithWhiteColor = TextStyle(
    fontSize: 14,
    color: AppColors.textColor,
    fontWeight: FontWeight.bold,
  );

  static const styleHintNormalSizeWithTextColor = TextStyle(
    color: AppColors.textColor,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const styleHintLargeSizeWithWhiteColor = TextStyle(
    fontSize: 18,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
  );

  static const styleHintLargeSizeWithBlackColor = TextStyle(
    color: AppColors.black,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const styleHintLargeSizeWithBlackColorN = TextStyle(
    color: AppColors.black,
    fontSize: 16,
  );

  static const styleHintWithRedColor = TextStyle(
    color: AppColors.red,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const styleHintExtraLargeSizeWithBlackColor = TextStyle(
    color: AppColors.black,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const styleHintExtraLargeSizeWithWhiteColor = TextStyle(
    color: AppColors.textColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.btnColor,
    textStyle: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static BoxDecoration btnBoxDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.btnStartColor,
          AppColors.btnCenterColor,
          AppColors.btnEndColor
        ],
      ),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: AppColors.transparent,
        width: 1,
      ),
    );
  }

  static BoxDecoration btnAlertBoxDecoration(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: AppColors.transparent,
        width: 1,
      ),
    );
  }

  static InputDecoration inputEditTextWithOutBorderRadiusAndIcon(
      String? hintText1) {
    return InputDecoration(
      hintText: hintText1 ?? "",
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.grayLight, width: 1)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.grayDark, width: 1)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.grayLight, width: 1)),
    );
  }

  static InputDecoration inputEditTextWithOutBorderRadiusAndIconOutSideFrom(
      String? hintText1) {
    return InputDecoration(
        hintText: hintText1 ?? "",
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: AppColors.black, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: AppColors.red, width: 1)),
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: AppColors.grayLight, width: 1)),
        border: const OutlineInputBorder(borderSide: BorderSide(width: 1)));
  }

  static ButtonStyle elevatedButtonStyleForm() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.transparent,
      shadowColor: AppColors.gray,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static ButtonStyle elevatedButtonStyleFormGreenColor() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      shadowColor: AppColors.textColor,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static ButtonStyle elevatedButtonStyleFormRedColor() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.transparent,
      shadowColor: AppColors.red,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static ButtonStyle elevatedButtonStyleFormBlueColor() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.transparent,
      shadowColor: AppColors.blue,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static InputDecoration inputEditTextBorderOnlyBottomLine(String? hintText1) {
    return InputDecoration(
      hintText: hintText1 ?? "",
      hintStyle:
      const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: const BorderSide(color: AppColors.red, width: 1)),
    );
  }

  static Text textStyleForNormalWithBoldRedColorText(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.red),
    ));
  }

  static Text textStyleForNormalWithBoldRedColorText16(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.refreshTextColor,
          fontSize: 18),
    ));
  }

  static Text textStyleForNormalWithBoldSize18(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppColors.black, fontSize: 16),
    ));
  }

  static Text textStyleForNormalWithBold(String strValue) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: AppColors.black, fontSize: 12),
    ));
  }

  static Text textStyleForNormalCenter(String? strValue) {
    return (Text(
      strValue ?? "N/A",
      overflow: TextOverflow.visible,
      style: const TextStyle(
          fontWeight: FontWeight.normal, color: AppColors.black, fontSize: 12),
    ));
  }

  static Text textStyleForNormalWithBoldColor(String strValue, Color color) {
    return (Text(
      strValue,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.start,
      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
    ));
  }

  static Text textStyleCenterTextWithColor(
      String? strValue, Color color, double fontSize) {
    return (Text(
      strValue ?? "N/A",
      textAlign: TextAlign.start,
      overflow: TextOverflow.visible,
      style: TextStyle(
          fontWeight: FontWeight.normal, color: color, fontSize: fontSize),
    ));
  }

  static BoxDecoration btnBoxDecorationCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: AppColors.transparent,
        width: 1,
      ),
    );
  }

  static BoxDecoration buttonwithborder() {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.lightGreen,
        Colors.greenAccent.shade700,
        AppColors.green
      ], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: Colors.lightGreen,
        width: 1,
      ),
    );
  }

  static BoxDecoration retangleWithCircular10() {
    return BoxDecoration(
      color: Color(0xFFFFFFFF),
      border: Border.all(
        color: AppColors.allow,
        width: 1,
      ),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }

  static BoxDecoration rectangleWithCircular() {
    return BoxDecoration(
      border: Border.all(
        color: AppColors.allow,
        width: 1,
      ),
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    );
  }

  static inputBoxDecoration(String hint) {
    return InputDecoration(
      labelText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.allow),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.allow),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.red),
      ),
    );
  }
}