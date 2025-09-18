# Payment System Implementation

## Overview
This document explains how the payment system has been implemented according to your senior's requirements.

## Payment Flow

### 1. User Selection
- User selects a question/category (Horoscope, Compatibility, Auspicious Time, or Ask a Question)
- User is navigated to the PaymentPage

### 2. Payment Method Selection
- User chooses a payment method:
  - **Stripe (Card)**: Opens Stripe payment sheet for card payments
  - **Google Pay**: Opens Stripe payment sheet with Google Pay integration
  - **Apple Pay**: Shows success overlay (placeholder for future implementation)
  - **PayPal**: Shows success overlay (placeholder for future implementation)

### 3. Stripe Payment Flow (Card & Google Pay)
When user selects Stripe or Google Pay:

1. **Step 1: Start Inquiry Process**
   - Calls API: `POST /frontend/GuestInquiry/StartInquiryProcess`
   - Sends question details, profile information, and inquiry type
   - API returns:
     ```json
     {
       "error_code": "0",
       "status_code": "200",
       "message": "Purchase Initiated. Please proceed for payment.",
       "data": {
         "inquiry_number": "6b134af76685452ba8826ef1f674ed95",
         "client_secret": "cs_live_a1r5ANPnAFUhs20B5ZCp2zkC4lElWBaOUkCMxXKc4dyonQa0U548UPlyth"
       }
     }
     ```

2. **Step 2: Process Payment with Stripe**
   - Uses the returned `client_secret` to initialize Stripe payment sheet
   - Stripe handles the payment processing
   - Backend automatically manages the payment completion

### 4. Non-Stripe Payment Methods
- Apple Pay and PayPal currently show success overlay
- These can be implemented later with their respective SDKs

## Key Changes Made

### 1. Updated PaymentService
- Added `startInquiryProcess()` method to call the API first
- Added `processStripePayment()` method to handle Stripe with session ID
- Improved error handling and logging

### 2. Updated PaymentPage
- Changed from StatelessWidget to StatefulWidget
- Added loading states and error handling
- Integrated with new payment service
- Shows inquiry details before payment

### 3. Updated Navigation
- All PaymentPage navigations now pass `questionId` and `profile2` parameters
- Ensures proper data flow for payment processing

### 4. Centralized API URLs
- Added constants in `lib/constants.dart` for all API URLs
- Makes it easier to manage and update API endpoints

## API Endpoints Used

- **Login**: `POST /frontend/Guests/login`
- **Validate OTP**: `POST /frontend/Guests/ValidateOTP`
- **Get Guest Profile**: `GET /frontend/Guests/Get`
- **Start Inquiry Process**: `POST /frontend/GuestInquiry/StartInquiryProcess`
- **My Inquiries**: `GET /frontend/GuestInquiry/MyInquiries`

## Error Handling

- Network errors are caught and displayed to user
- API errors show specific error messages
- Stripe errors are handled gracefully with user-friendly messages
- Loading states prevent multiple payment attempts

## Testing

To test the payment system:

1. Select any question from the categories
2. Choose Stripe or Google Pay as payment method
3. Check console logs for API calls and responses
4. Verify that the inquiry process starts before payment
5. Confirm Stripe payment sheet opens with the session ID

## Future Enhancements

- Implement Apple Pay integration
- Implement PayPal integration
- Add payment confirmation emails
- Add payment history tracking
- Implement refund functionality

## Notes

- The system now follows the correct flow: API call first, then Stripe payment
- All payment processing is handled by the backend and Stripe
- The frontend only manages the UI flow and API communication
- Error handling has been improved for better user experience




