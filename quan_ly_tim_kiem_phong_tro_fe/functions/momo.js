const crypto = require("crypto");
const axios = require("axios");

exports.createMomoPayment = async (req, res) => {
  try {
    const { bookingId, amount, orderInfo } =
      req.body;

    /// ================= DEMO ACCOUNT =================
    const partnerCode = "MOMO";
    const accessKey = "F8BBA842ECF85";

    /// CHƯA CÓ SECRETKEY THẬT
    /// dùng tạm fake để demo
    const secretKey =
      "fake_secret_key_demo";

    const requestId =
      bookingId ||
      Date.now().toString();

    const orderId =
      bookingId ||
      Date.now().toString();

    /// ================= URL =================
    const redirectUrl =
      "https://test-payment.momo.vn";

    const ipnUrl =
      "https://test-payment.momo.vn";

    const requestType =
      "captureWallet";

    const extraData = "";

    /// ================= SIGNATURE =================
    const rawSignature =
      `accessKey=${accessKey}` +
      `&amount=${amount}` +
      `&extraData=${extraData}` +
      `&ipnUrl=${ipnUrl}` +
      `&orderId=${orderId}` +
      `&orderInfo=${orderInfo}` +
      `&partnerCode=${partnerCode}` +
      `&redirectUrl=${redirectUrl}` +
      `&requestId=${requestId}` +
      `&requestType=${requestType}`;

    const signature = crypto
      .createHmac(
        "sha256",
        secretKey,
      )
      .update(rawSignature)
      .digest("hex");

    /// ================= REQUEST BODY =================
    const requestBody = {
      partnerCode,
      accessKey,
      requestId,
      amount: amount.toString(),
      orderId,
      orderInfo,
      redirectUrl,
      ipnUrl,
      extraData,
      requestType,
      signature,
      lang: "vi",
      autoCapture: true,
    };

    console.log(
      "MOMO REQUEST:",
      requestBody,
    );

    /// ================= CALL MOMO =================
    const response =
      await axios.post(
        "https://test-payment.momo.vn/v2/gateway/api/create",
        requestBody,
      );

    console.log(
      "MOMO RESPONSE:",
      response.data,
    );

    /// ================= SUCCESS =================
    if (response.data.payUrl) {
      return res.json({
        success: true,
        payUrl:
          response.data.payUrl,
      });
    }

    /// ================= FALLBACK DEMO =================
    return res.json({
      success: true,
      payUrl: "https://test-payment.momo.vn"
    });
  } catch (e) {
    console.log("MOMO ERROR:", e);

    /// DEMO FALLBACK
    return res.json({
      success: true,
      payUrl: "https://test-payment.momo.vn",
    });
  }
};