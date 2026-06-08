const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const qs = require("qs");

const momo = require("./momo");

exports.createMomoPayment =
  functions.https.onRequest(
    momo.createMomoPayment,
  );

exports.createVNPayUrl = functions.https.onRequest(async (req, res) => {
  try {
    const { bookingId, amount, orderInfo } = req.body;

    const tmnCode = "LOIOXZT8";
    const secretKey = "GSMXV0OQ3CUMVJXMLLE9G1R84OP3HKXU";

    const ipAddr = req.headers["x-forwarded-for"] || req.socket.remoteAddress;

    const createDate = new Date();

    const pad = (n) => n.toString().padStart(2, "0");

    const vnp_CreateDate =
      createDate.getFullYear().toString() +
      pad(createDate.getMonth() + 1) +
      pad(createDate.getDate()) +
      pad(createDate.getHours()) +
      pad(createDate.getMinutes()) +
      pad(createDate.getSeconds());

    let vnp_Params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: tmnCode,
      vnp_Locale: "vn",
      vnp_CurrCode: "VND",
      vnp_TxnRef: bookingId,
      vnp_OrderInfo: orderInfo,
      vnp_OrderType: "billpayment",
      vnp_Amount: amount * 100,
      vnp_ReturnUrl: "https://sandbox.vnpayment.vn/apis/vnpay-demo/",
      vnp_IpAddr: ipAddr,
      vnp_CreateDate: vnp_CreateDate,
    };

    // SORT
    vnp_Params = sortObject(vnp_Params);

    // DATA TO SIGN
    const signData = qs.stringify(vnp_Params, {
      encode: false,
    });

    // CREATE HASH
    const hmac = crypto.createHmac("sha512", secretKey);

    const signed = hmac.update(Buffer.from(signData, "utf-8")).digest("hex");

    // ADD HASH AFTER SIGNING
    vnp_Params["vnp_SecureHashType"] = "SHA512";
    vnp_Params["vnp_SecureHash"] = signed;

    // FINAL URL
    const paymentUrl =
      "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?" +
      qs.stringify(vnp_Params, {
        encode: false,
      });

    console.log("PAYMENT URL:", paymentUrl);

    return res.json({
      success: true,
      paymentUrl,
    });
  } catch (e) {
    console.log(e);

    return res.status(500).json({
      success: false,
      error: e.toString(),
    });
  }
});

function sortObject(obj) {
  let sorted = {};
  let keys = Object.keys(obj).sort();

  for (let key of keys) {
    sorted[key] = obj[key];
  }

  return sorted;
}
