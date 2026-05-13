const functions = require("firebase-functions");
const { VNPay, ignoreLogger } = require("vnpay");

exports.createVNPayUrl = functions.https.onCall(
  async (data, context) => {
    try {
      const vnpay = new VNPay({
        tmnCode: "DEMOV210",
        secureSecret:
          "12345678901234567890123456789012",
        vnpayHost:
          "https://sandbox.vnpayment.vn",
        testMode: true,
        hashAlgorithm: "SHA512",
        loggerFn: ignoreLogger,
      });

      const paymentUrl =
        vnpay.buildPaymentUrl({
          vnp_Amount: data.amount,
          vnp_IpAddr: "127.0.0.1",
          vnp_TxnRef: Date.now().toString(),
          vnp_OrderInfo: data.orderInfo,
          vnp_OrderType: "other",
          vnp_ReturnUrl:
            "https://your-return-url.com",
        });

      return {
        paymentUrl,
      };
    } catch (e) {
      throw new functions.https.HttpsError(
        "internal",
        e.toString()
      );
    }
  }
);