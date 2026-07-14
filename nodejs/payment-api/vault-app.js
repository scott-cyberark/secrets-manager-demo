"use strict";

// Sample payment-charging app - AFTER.
// Same app as hardcoded-app.js, but the API key is pulled dynamically from
// Idira Secrets Manager at startup instead of being embedded in source.

const { IdiraClient } = require("./idira-client");

// "Safe/Secret" path convention, same as used in .github/workflows/secrets.yml
const SECRET_PATH_API_KEY = "data/vault/SM-API-SecretHub/payment-api/api_key";

async function chargeCustomer(amountCents, customerId) {
  const client = new IdiraClient();
  const paymentApiKey = await client.getSecret(SECRET_PATH_API_KEY);

  console.log(
    `Charging customer ${customerId} for ${amountCents} cents using key ${paymentApiKey.slice(
      0,
      8
    )}...`
  );
  // const res = await fetch("https://api.payment-provider.example.com/v1/charges", {
  //   method: "POST",
  //   headers: { Authorization: `Bearer ${paymentApiKey}` },
  //   body: JSON.stringify({ amount: amountCents, customer: customerId }),
  // });
  console.log(
    "Charge simulated successfully using a key fetched from Idira Secrets Manager."
  );
}

chargeCustomer(2500, "cust_12345").catch((err) => {
  console.error(err);
  process.exit(1);
});
