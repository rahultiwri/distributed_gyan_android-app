package com.example.gyan_milk

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.paytm.pgsdk.PaytmOrder
import com.paytm.pgsdk.PaytmPaymentTransactionCallback
import com.paytm.pgsdk.TransactionManager

class MainActivity : FlutterActivity() {

    private val CHANNEL = "gyan_milk/paytm"

    private val ACTIVITY_REQUEST_CODE = 2

    private val PAYTM_HOST = "https://securegw.paytm.in/"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "startPaytmTransaction" -> {

                    val orderId =
                        call.argument<String>("orderId") ?: ""

                    val mid =
                        call.argument<String>("mid") ?: ""

                    val token =
                        call.argument<String>("token") ?: ""

                    val amount =
                        call.argument<String>("amount") ?: ""

                    if (
                        orderId.isEmpty() ||
                        mid.isEmpty() ||
                        token.isEmpty() ||
                        amount.isEmpty()
                    ) {
                        result.error(
                            "INVALID_PAYMENT_DATA",
                            "Paytm payment data is incomplete.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {

                        startPaytmTransaction(
                            orderId = orderId,
                            mid = mid,
                            token = token,
                            amount = amount,
                            result = result
                        )

                    } catch (e: Exception) {

                        result.error(
                            "PAYTM_START_ERROR",
                            e.message ?: "Unable to start Paytm transaction.",
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startPaytmTransaction(
        orderId: String,
        mid: String,
        token: String,
        amount: String,
        result: MethodChannel.Result
    ) {

        val callbackUrl =
            PAYTM_HOST +
                    "theia/paytmCallback?ORDER_ID=" +
                    orderId

        val paytmOrder = PaytmOrder(
            orderId,
            mid,
            token,
            amount,
            callbackUrl
        )

        val transactionManager =
            TransactionManager(
                paytmOrder,
                object : PaytmPaymentTransactionCallback {

                    override fun onTransactionResponse(
                        bundle: Bundle?
                    ) {

                        val response =
                            HashMap<String, Any?>()

                        if (bundle != null) {

                            for (key in bundle.keySet()) {
                                response[key] =
                                    bundle.get(key)
                            }
                        }

                        result.success(response)
                    }

                    override fun networkNotAvailable() {

                        result.error(
                            "NETWORK_NOT_AVAILABLE",
                            "Network not available.",
                            null
                        )
                    }

                    override fun onErrorProceed(
                        error: String?
                    ) {

                        result.error(
                            "ON_ERROR_PROCEED",
                            error ?: "Paytm error.",
                            null
                        )
                    }

                    override fun clientAuthenticationFailed(
                        error: String?
                    ) {

                        result.error(
                            "CLIENT_AUTHENTICATION_FAILED",
                            error ?: "Client authentication failed.",
                            null
                        )
                    }

                    override fun someUIErrorOccurred(
                        error: String?
                    ) {

                        result.error(
                            "UI_ERROR",
                            error ?: "Paytm UI error.",
                            null
                        )
                    }

                    override fun onErrorLoadingWebPage(
                        errorCode: Int,
                        errorMessage: String?,
                        failingUrl: String?
                    ) {

                        result.error(
                            "WEB_PAGE_ERROR",
                            errorMessage ?: "Error loading Paytm page.",
                            failingUrl
                        )
                    }

                    override fun onBackPressedCancelTransaction() {

                        result.error(
                            "TRANSACTION_CANCELLED",
                            "Transaction cancelled by user.",
                            null
                        )
                    }

                    override fun onTransactionCancel(
                        errorMessage: String?,
                        bundle: Bundle?
                    ) {

                        val response =
                            HashMap<String, Any?>()

                        response["message"] =
                            errorMessage ?: "Transaction cancelled."

                        if (bundle != null) {

                            for (key in bundle.keySet()) {
                                response[key] =
                                    bundle.get(key)
                            }
                        }

                        result.success(response)
                    }
                }
            )

        transactionManager.setAppInvokeEnabled(false)

        transactionManager.setEnableAssist(true)

        transactionManager.setShowPaymentUrl(
            PAYTM_HOST +
                    "theia/api/v1/showPaymentPage"
        )

        transactionManager.startTransaction(
            this,
            ACTIVITY_REQUEST_CODE
        )
    }
}
