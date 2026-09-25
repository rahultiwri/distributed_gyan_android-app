class PaymentHistoryEnt {
  String txndate;
  String txnamount;
  String respmsg;
  String erpmsg;

  PaymentHistoryEnt({
    this.txndate = '',
    this.txnamount = '',
    this.respmsg = '',
    this.erpmsg = '',
  });
}