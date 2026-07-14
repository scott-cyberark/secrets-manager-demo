"use strict";

// Sample payment-charging app - BEFORE.
// The third-party API key is hardcoded directly in source. Compare with
// vault-app.js.

const PAYMENT_API_KEY = "REPLACE_WITH_YOUR_PAYMENT_PROVIDER_API_KEY"; // <-- hardcoded, bad

async function chargeCustomer(amountCents, customerId) {
  console.log(
    `Charging customer ${customerId} for ${amountCents} cents using key ${PAYMENT_API_KEY.slice(
      0,
      8
    )}...`
  );
  // const res = await fetch("https://api.payment-provider.example.com/v1/charges", {
  //   method: "POST",
  //   headers: { Authorization: `Bearer ${PAYMENT_API_KEY}` },
  //   body: JSON.stringify({ amount: amountCents, customer: customerId }),
  // });
  console.log("Charge simulated successfully.");
}

chargeCustomer(2500, "cust_12345");
