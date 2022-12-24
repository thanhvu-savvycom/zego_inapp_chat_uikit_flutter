import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

const Color white = Colors.white;
const Color black = Colors.black;
const Color dark1 = Color(0xFF0A0B09);
const Color dark5 = Color(0xFF6B6D6C);
const Color dark6 = Color(0xFF7B7D7C);
const Color dark7 = Color(0xFF8B8D8C);
const Color dark9 = Color(0xFFAFB1AF);
const Color dark11 = Color(0xFFD4D5D2);
const Color neutral5 = Color(0xFFB0B0B0);
const Color neutral7 = Color(0xFFF3F3F3);
const Color darkBlue = Color(0xFF32359D);
const Color blue3 = Color(0xFF283C7C);
const Color blue4 = Color(0xFF395390);
const Color darkRed = Color(0xFFCF2A2A);
const Color danger = Color(0xFFED1F42);
const actionTextColor = Color(0xFF24138A);
const blue1 = Color(0xFF212E4A);
const dark2 = Color(0xFF313131);
const natural1 = Color(0xFF1D1D1D);
const nutural3 = Color(0xFF666666);
const colorLineGray = Color(0xFFF3F3F3);
const danger2 = Color(0xFFF14C68);
const success1 = Color(0xFF15AA2C);
const blue = Color(0xFF1A73E8);
const orange = Color(0xFFFF6B00);
const blueInform = Color(0xFF315BF1);
const bgInform = Color(0xFFEAEFFE);
const bgSuccess = Color(0xFFE8F7EA);
const bgError = Color(0xFFFEECEF);
const bgWarning = Color(0xFFFFF0E5);
const neutral2 = Color(0xFF2D2D2D);

extension CustomTheme on TextTheme {
  TextStyle get titleLarge =>
      GoogleFonts.inter(color: dark1, fontSize: 36.sp, fontWeight: FontWeight.bold, height: 44 / 36);

  TextStyle get title1 {
    return GoogleFonts.inter(color: dark1, fontSize: 32.sp, fontWeight: FontWeight.bold, height: 38 / 32);
  }

  TextStyle get title2 {
    return GoogleFonts.inter(color: dark1, fontSize: 28.sp, fontWeight: FontWeight.bold, height: 32 / 28);
  }

  TextStyle get title3 {
    return GoogleFonts.inter(color: dark1, fontSize: 22.sp, fontWeight: FontWeight.bold, height: 30 / 22);
  }

  TextStyle get title4 {
    return GoogleFonts.inter(color: dark1, fontSize: 20.sp, fontWeight: FontWeight.bold, height: 28 / 20);
  }

  TextStyle get body1 => GoogleFonts.inter(color: dark1, fontSize: 16.sp, fontWeight: FontWeight.w400, height: 22 / 16);

  TextStyle get body1Bold =>
      GoogleFonts.inter(color: dark1, fontSize: 16.sp, fontWeight: FontWeight.bold, height: 22 / 16);

  TextStyle get body2Bold =>
      GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w600, height: 20 / 14);

  TextStyle get body2 => GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w400, height: 20 / 14);

  TextStyle get buttonNormal =>
      GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w600, height: 18 / 14);

  TextStyle get subTitleRegular => GoogleFonts.inter(
        color: dark1,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 24 / 14,
      );

  TextStyle get tooltip =>
      GoogleFonts.inter(color: dark1, fontSize: 12.sp, fontWeight: FontWeight.w400, height: 16 / 12);

  TextStyle get labelLargeText =>
      GoogleFonts.inter(color: dark1, fontSize: 12.sp, fontWeight: FontWeight.w600, height: 16 / 12);

  TextStyle get labelNormalText =>
      GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w400, height: 19 / 14);

  TextStyle get h5Regular {
    return GoogleFonts.inter(color: dark1, fontSize: 18.sp, fontWeight: FontWeight.w400, height: 25 / 18);
  }

  TextStyle get subTitle {
    return GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w400, height: 20 / 14);
  }

  TextStyle get textRegular => GoogleFonts.inter(
        color: dark1,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 17 / 12,
      );

  TextStyle get smallNormal => GoogleFonts.inter(
        color: dark1,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
      );

  TextStyle get labelHighLight {
    return GoogleFonts.inter(color: dark1, fontSize: 16.sp, fontWeight: FontWeight.w600, height: 22 / 16);
  }

  TextStyle get h5Bold {
    return GoogleFonts.inter(color: dark1, fontSize: 18.sp, fontWeight: FontWeight.bold, height: 25 / 18);
  }

  TextStyle get subTitle16 {
    return GoogleFonts.inter(color: dark1, fontSize: 16.sp, fontWeight: FontWeight.w400, height: 22 / 16);
  }

  TextStyle get text16 {
    return GoogleFonts.inter(color: dark1, fontSize: 16.sp, fontWeight: FontWeight.w700, height: 22 / 16);
  }

  TextStyle get bold14 {
    return GoogleFonts.inter(color: dark1, fontSize: 14.sp, fontWeight: FontWeight.w700, height: 20 / 14);
  }

  TextStyle get h4Bold {
    return GoogleFonts.inter(color: dark1, fontSize: 20.sp, fontWeight: FontWeight.bold, height: 27 / 20);
  }

  TextStyle get text12 =>
      GoogleFonts.inter(color: dark1, fontSize: 12.sp, fontWeight: FontWeight.w400, height: 18 / 12);

  TextStyle get textSmall =>
      GoogleFonts.inter(color: dark1, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 16 / 12);

  TextStyle get title5 =>
      GoogleFonts.inter(color: dark1, fontSize: 18.sp, fontWeight: FontWeight.w700, height: 24 / 18);

  TextStyle get smallMedium =>
      GoogleFonts.inter(color: dark1, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 16 / 12);
}
