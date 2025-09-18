// import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/config/env.dart';

// Stripe Keys
String get stripePublishableKey => Env.stripePublishableKey;

// ⚠️ Do NOT keep secret keys in a client app in production
// Move stripeSecretKey to your backend once live

// Base URL from .env
String get baseApiUrl => Env.apiBaseUrl;

// API Endpoints
String get loginApiUrl => "${baseApiUrl}/Guests/login";
String get validateOtpApiUrl => "${baseApiUrl}/Guests/ValidateOTP";
String get getGuestApiUrl => "${baseApiUrl}/Guests/Get";
String get startInquiryProcessApiUrl => "${baseApiUrl}/GuestInquiry/StartInquiryProcess";
String get myInquiriesApiUrl => "${baseApiUrl}/GuestInquiry/MyInquiries";
String get getInquiriesByInquiryNumber => "$baseApiUrl/GuestInquiry/GetInquiriesByInquiryNumber";

// Checkout URLs
String get checkoutSuccessUrl => "${baseApiUrl}/Checkout/success";
String get checkoutCancelUrl => "${baseApiUrl}/Checkout/cancel";
