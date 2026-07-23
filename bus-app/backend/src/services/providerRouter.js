/**
 * Determines which payment provider to route the transaction to
 * based on the user's chosen payment method, phone number prefix, and currency.
 */
function decideProvider({ paymentMethodChosen, phoneNumber, currency }) {
  let normalizedPhone = phoneNumber ? phoneNumber.replace(/\s+/g, '') : '';

  // Normalize local Ugandan phone numbers (e.g., 077... -> 25677...)
  if (normalizedPhone.startsWith('0')) {
    normalizedPhone = '256' + normalizedPhone.slice(1);
  } else if (normalizedPhone.startsWith('+')) {
    normalizedPhone = normalizedPhone.slice(1);
  }

  // Card or explicit Pesapal payments (or non-UGX currency) route to Pesapal
  if (
    paymentMethodChosen === 'card' ||
    paymentMethodChosen === 'pesapal' ||
    currency === 'USD'
  ) {
    return { provider: 'pesapal', normalizedPhone };
  }

  // Mobile Money direct routing based on Ugandan carrier prefixes
  if (paymentMethodChosen === 'mobile_money') {
    // MTN prefixes: 077, 078, 076
    if (
      normalizedPhone.startsWith('25677') ||
      normalizedPhone.startsWith('25678') ||
      normalizedPhone.startsWith('25676')
    ) {
      return { provider: 'mtn_direct', normalizedPhone };
    }

    // Airtel prefixes: 070, 075, 074
    if (
      normalizedPhone.startsWith('25670') ||
      normalizedPhone.startsWith('25675') ||
      normalizedPhone.startsWith('25674')
    ) {
      return { provider: 'airtel_direct', normalizedPhone };
    }
  }

  // Fallback to Pesapal for any other setup
  return { provider: 'pesapal', normalizedPhone };
}

module.exports = { decideProvider };