window.ethereum.isWeb3 = true
window.ethereum.request = (args) => window.flutter_inappwebview.callHandler('request', ...args)