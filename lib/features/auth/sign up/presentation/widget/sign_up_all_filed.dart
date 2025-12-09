import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/helpers/other_helper.dart';
import '../../../../../utils/constants/app_string.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/sign_up_controller.dart';

class SignUpAllField extends StatefulWidget {
  const SignUpAllField({super.key, required this.controller});

  final SignUpController controller;

  @override
  State<SignUpAllField> createState() => _SignUpAllFieldState();
}

class _SignUpAllFieldState extends State<SignUpAllField> {
  Country selectedCountry = Country(
    phoneCode: '880',
    countryCode: 'BD',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Bangladesh',
    example: 'Bangladesh',
    displayName: 'Bangladesh',
    displayNameNoCountryCode: 'BD',
    e164Key: '',
  );

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to phone number changes and update main controller with country code
    _phoneController.addListener(_updateMainController);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_updateMainController);
    _phoneController.dispose();
    super.dispose();
  }

  void _updateMainController() {
    // Update main controller with complete phone number (country code + number)
    final phoneNumber = _phoneController.text;
    widget.controller.phoneNumberController.text = '+${selectedCountry.phoneCode}$phoneNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// User Name here
        const CommonText(
          text: AppString.name_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6),
        CommonTextField(
          hintText: AppString.hints_name,
          hintTextColor: AppColors.black100,
          controller: widget.controller.nameController,
          validator: OtherHelper.validator,
        ),

        /// User Email here
        const CommonText(
          text: AppString.email,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          top: 12,
          bottom: 6,
        ),
        CommonTextField(
          hintText: AppString.hint_email_text,
          hintTextColor: AppColors.black100,
          controller: widget.controller.emailController,
          validator: OtherHelper.emailValidator,
        ),

        /// User phone number with country picker
        const CommonText(
          text: AppString.phone_number_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          top: 12,
          bottom: 6,
        ),
        _buildPhoneNumberField(),

        /// User Location here
        const CommonText(
          text: AppString.location,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          bottom: 6,
          top: 12,
        ),
        CommonTextField(
          hintText: AppString.location_hint,
          hintTextColor: AppColors.black100,
          controller: widget.controller.locationController,
          validator: OtherHelper.validator,
        ),

        /// User Password here
        const CommonText(
          text: AppString.password_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          bottom: 6,
          top: 12,
        ),
        CommonTextField(
          hintText: AppString.password_hint,
          hintTextColor: AppColors.black100,
          controller: widget.controller.passwordController,
          isPassword: true,
          validator: OtherHelper.passwordValidator,
        ),

        /// User Confirm Password here
        const CommonText(
          text: AppString.confirm_password_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          bottom: 6,
          top: 12,
        ),
        CommonTextField(
          hintText: AppString.hint_confirm_password,
          hintTextColor: AppColors.black100,
          controller: widget.controller.confirmPasswordController,
          isPassword: true,
          validator: (value) => OtherHelper.confirmPasswordValidator(
            value,
            widget.controller.passwordController,
          ),
        ),

        const CommonText(
          text: AppString.referal_code_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          top: 12,
          bottom: 6,
        ),
        CommonTextField(
          hintText: AppString.referal_code_hint,
          hintTextColor: AppColors.black100,
          controller: widget.controller.referralController,
          validator: OtherHelper.validator,
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller.phoneNumberController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      style: GoogleFonts.roboto(
        fontSize: 14.sp,
        color: AppColors.black,
        fontWeight: FontWeight.w400,
      ),
      validator: OtherHelper.validator,
      decoration: InputDecoration(
        errorMaxLines: 2,
        filled: true,
        fillColor: AppColors.transparent,
        hintText: AppString.hint_phone_number,
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: AppColors.black100,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country;
                  // Update complete phone number when country changes
                  widget.controller.countryCode = '+${country.phoneCode}';
                });
              },
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                inputDecoration: InputDecoration(
                  hintText: AppString.search_country,
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.black100,
                  ),
                  prefixIcon: Icon(Icons.search, size: 20.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.black50),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.black50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.black50),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
                searchTextStyle: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
                textStyle: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  color: AppColors.black,
                ),
                flagSize: 24.sp,
                bottomSheetHeight: 500.h,
                backgroundColor: Colors.white,
              ),
              // Custom country list builder to show phone codes
              countryFilter: null,
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedCountry.flagEmoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(width: 6.w),
                Text(
                  '+${selectedCountry.phoneCode}',
                  style: GoogleFonts.roboto(
                    fontSize: 14.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.black200,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        border: _buildBorder(AppColors.black50),
        enabledBorder: _buildBorder(AppColors.black50),
        focusedBorder: _buildBorder(AppColors.black50),
        errorBorder: _buildBorder(AppColors.black50),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 20.h,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: color, width: 1.w),
    );
  }

  void _updatePhoneWithCode() {
    final phoneNumber = widget.controller.phoneNumberController.text;
    if (phoneNumber.isNotEmpty) {
      widget.controller.completePhoneNumber = '+${selectedCountry.phoneCode}$phoneNumber';
    }
  }
}