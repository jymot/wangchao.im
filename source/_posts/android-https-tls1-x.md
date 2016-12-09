---
title: Android 5.0以下TLS1.x SSLHandshakeException
date: 2016-11-30 20:17:02
categories: [Android]
tags: [Android, TLSv1.x]
---
最近把App的所有请求都换成Https,在测试的时候,部分手机发现请求失败,失败的异常信息如下:
```
javax.net.ssl.SSLHandshakeException: javax.net.ssl.SSLProtocolException: SSL handshake aborted: ssl=0x783e8e70: Failure in SSL library, usually a protocol error
error:14077102:SSL routines:SSL23_GET_SERVER_HELLO:unsupported protocol (external/openssl/ssl/s23_clnt.c:714 0x71a20cf8:0x00000000)
```
该异常为握手失败,但是为什么有的手机可以成功有的手机又失败了呢,首先查看我们服务端接口TLS支持的版本为1.x,后来发现失败的手机都是5.x以下的版本,推测应该是和这个有关,然后查阅官方文档,[SSLSocket]中有提到TLS版本和Android SDK版本的对应表,如下:

| Protocol | Supported (API Levels) | Enabled by default (API Levels) |
| -------- | ------------ | ----------- |
| SSLv3 | 1+ | 1+ |
| TLSv1 | 1+ | 1+ |
| TLSv1.1 | 16+ | 20+ |
| TLSv1.2 | 16+ | 20+ |

通过这个表看到,TLSv1.x(1.1,1.2)Android默认从API16开始支持,而从API20开始默认可用,这就可以解释之前为什么5.x以下手机在进行请求时失败了。

<!--more-->

知道问题的原因,我们就要解决,当然服务端可以支持TLSv1版本,这样我们就都可以请求成功,但是这并不是最好的解决方法,我们当然要让我们的App支持新的TLS协议才对。

通过官方文档发现`Cipher suites`有的也是API20+支持或者默认可用,所以我们如果想支持TLSv1.x版本,可能需要给低版本添加`Cipher suites`,所以我们需要自定义SSLSocketFactory,自定义的SSLSocketFactory如下:
```java
public class SSL extends SSLSocketFactory {
    private SSLSocketFactory defaultFactory;
    // Android 5.0+ (API level21) provides reasonable default settings
    // but it still allows SSLv3
    // https://developer.android.com/about/versions/android-5.0-changes.html#ssl
    static String protocols[] = null, cipherSuites[] = null;

    static {
        try {
            SSLSocket socket = (SSLSocket) SSLSocketFactory.getDefault().createSocket();
            if (socket != null) {
                /* set reasonable protocol versions */
                // - enable all supported protocols (enables TLSv1.1 and TLSv1.2 on Android <5.0)
                // - remove all SSL versions (especially SSLv3) because they're insecure now
                List<String> protocols = new LinkedList<>();
                for (String protocol : socket.getSupportedProtocols())
                    if (!protocol.toUpperCase().contains("SSL"))
                        protocols.add(protocol);
                SSL.protocols = protocols.toArray(new String[protocols.size()]);
                /* set up reasonable cipher suites */
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
                    // choose known secure cipher suites
                    List<String> allowedCiphers = Arrays.asList(
                            // TLS 1.2
                            "TLS_RSA_WITH_AES_256_GCM_SHA384",
                            "TLS_RSA_WITH_AES_128_GCM_SHA256",
                            "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256",
                            "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
                            "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
                            "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
                            "TLS_ECHDE_RSA_WITH_AES_128_GCM_SHA256",
                            // maximum interoperability
                            "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
                            "TLS_RSA_WITH_AES_128_CBC_SHA",
                            // additionally
                            "TLS_RSA_WITH_AES_256_CBC_SHA",
                            "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
                            "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
                            "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
                            "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA");
                    List<String> availableCiphers = Arrays.asList(socket.getSupportedCipherSuites());
                    // take all allowed ciphers that are available and put them into preferredCiphers
                    HashSet<String> preferredCiphers = new HashSet<>(allowedCiphers);
                    preferredCiphers.retainAll(availableCiphers);
                    /* For maximum security, preferredCiphers should *replace* enabled ciphers (thus disabling
                     * ciphers which are enabled by default, but have become unsecure), but I guess for
                     * the security level of DAVdroid and maximum compatibility, disabling of insecure
                     * ciphers should be a server-side task */
                    // add preferred ciphers to enabled ciphers
                    HashSet<String> enabledCiphers = preferredCiphers;
                    enabledCiphers.addAll(new HashSet<>(Arrays.asList(socket.getEnabledCipherSuites())));
                    SSL.cipherSuites = enabledCiphers.toArray(new String[enabledCiphers.size()]);
                }
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    public SSL(X509TrustManager tm) {
        try {
            SSLContext sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, (tm != null) ? new X509TrustManager[]{tm} : null, null);
            defaultFactory = sslContext.getSocketFactory();
        } catch (GeneralSecurityException e) {
            throw new AssertionError(); // The system has no TLS. Just give up.
        }
    }

    private void upgradeTLS(SSLSocket ssl) {
        // Android 5.0+ (API level21) provides reasonable default settings
        // but it still allows SSLv3
        // https://developer.android.com/about/versions/android-5.0-changes.html#ssl
        if (protocols != null) {
            ssl.setEnabledProtocols(protocols);
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP && cipherSuites != null) {
            ssl.setEnabledCipherSuites(cipherSuites);
        }
    }

    @Override public String[] getDefaultCipherSuites() {
        return cipherSuites;
    }

    @Override public String[] getSupportedCipherSuites() {
        return cipherSuites;
    }

    @Override public Socket createSocket(Socket s, String host, int port, boolean autoClose) throws IOException {
        Socket ssl = defaultFactory.createSocket(s, host, port, autoClose);
        if (ssl instanceof SSLSocket)
            upgradeTLS((SSLSocket) ssl);
        return ssl;
    }

    @Override public Socket createSocket(String host, int port) throws IOException, UnknownHostException {
        Socket ssl = defaultFactory.createSocket(host, port);
        if (ssl instanceof SSLSocket)
            upgradeTLS((SSLSocket) ssl);
        return ssl;
    }

    @Override public Socket createSocket(String host, int port, InetAddress localHost, int localPort) throws IOException, UnknownHostException {
        Socket ssl = defaultFactory.createSocket(host, port, localHost, localPort);
        if (ssl instanceof SSLSocket)
            upgradeTLS((SSLSocket) ssl);
        return ssl;
    }

    @Override public Socket createSocket(InetAddress host, int port) throws IOException {
        Socket ssl = defaultFactory.createSocket(host, port);
        if (ssl instanceof SSLSocket)
            upgradeTLS((SSLSocket) ssl);
        return ssl;
    }

    @Override public Socket createSocket(InetAddress address, int port, InetAddress localAddress, int localPort) throws IOException {
        Socket ssl = defaultFactory.createSocket(address, port, localAddress, localPort);
        if (ssl instanceof SSLSocket)
            upgradeTLS((SSLSocket) ssl);
        return ssl;
    }
}
```
然后我们只需要给我们的请求设置这个SSLSocketFactory就可以了,我们以[okhttp]为例,如下:
```java
//定义一个信任所有证书的TrustManager
final X509TrustManager trustAllCert = new X509TrustManager() {
    @Override
    public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
    }

    @Override
    public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
    }

    @Override
    public java.security.cert.X509Certificate[] getAcceptedIssuers() {
        return new java.security.cert.X509Certificate[]{};
    }
};
//设置OkHttpClient
OkHttpClient client = new OkHttpClient
                        .Builder()
                        .sslSocketFactory(new SSL(trustAllCert), trustAllCert)
                        .build();
```
设置之后,用低版本手机测试Https,现在可以测试成功了。

[SSLSocket]: https://developer.android.com/reference/javax/net/ssl/SSLSocket.html?hl=zh-cn
[okhttp]: https://github.com/square/okhttp
