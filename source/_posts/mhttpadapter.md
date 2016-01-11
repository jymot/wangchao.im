---
title: Http请求适配性封装
date: 2016-01-09 10:32:09
categories: Android
tags: Http
---
现在强大的第三方网络请求库太多了，比如OkHttp，android-async-http等，我们在用这些第三方网络请求库的时候，一般因为
项目需求，都会简单的做一层封装，下面我就来说我对此的理解。

<!--more-->

因为项目在使用第三方请求库的时候，很可能今天用A库明天用B库，这样换来换去太烦了，所以在封装第三方请求库的时候要有自己
的一套规范，我们只需要用第三方请求库实现这套规范就可以了，比如我们定义一个接口，具体如下：
``` java
public interface HttpClientInterface {

      /**
         * 执行请求
         * 
         * @param httpRequest   请求对象
         * @return              this
         */
        HttpClientInterface execute(HttpRequest httpRequest);
    
        /**
         * 取消请求
         * 
         * @param request   请求对象
         * @return          this
         */
        HttpClientInterface cancel(HttpRequest request);

}
```
在我们用第三方库的时候，需要实现我们定义的规范，这里以OkHttp为例：
``` java
/*package*/ class OkHttpClientImpl implements HttpClientInterface {

     ...
     
     @Override public HttpClientInterface execute(HttpRequest httpRequest) {
            setUrl(httpRequest.getRequestUrl());
            setTimeout(httpRequest.getTimeout());
            setHeaders(httpRequest.getHeaders());
            setRequestParams(httpRequest.getRequestParams(), httpRequest.getMethod());
            setResponseHandler(httpRequest);
            setTag(httpRequest.getTag());
            switch (httpRequest.getMethod()){
                case HttpRequest.Method.GET: {
                    get(httpRequest);
                } break;
                case HttpRequest.Method.POST: {
                    post(httpRequest);
                } break;
            }
            return null;
    
        }
    
        @Override public HttpClientInterface cancel(final HttpRequest request) {
            if (weakCall != null){
                final Call call = weakCall.get();
                if (call != null){
                    Runnable r = new Runnable() {
                        @Override
                        public void run() {
                            call.cancel();
                            if (responseHandler != null){
                                responseHandler.sendCancelMessage();
                            }
                        }
                    };
    
                    if (Looper.myLooper() == Looper.getMainLooper()){
                        new Thread(r).start();
                    } else {
                        r.run();
                    }
                }
            }
            return this;
        }
        
        ...
}
```
我们只需要对应的实现execute和cancel方法，当然可能还需抽象其它的方法，这里不在赘述。所以现在我们只需要通过接口的方式
去调用请求，为了使用方便，我还定义了一套Annotation，如@Get、@Post等，具体的实现请参见源码，文章末尾github地址。

### 如何使用
通常我们在使用网络请求时候，都会有一些公共的设置，如下:
``` java
public abstract class BaseApi{
  
    @RootURL("http://root.com/") String baseURL;
    @Timeout(40) String timeout;
    @RequestContentType(RequestParams.APPLICATION_FORM) String Content_Type;
    @Header("Android") String User_Agent;
        
    @CommonParamsMethod
    public Map<String, String> getCommonParams() {
      Map<String, String> params = new HashMap<>();
      params.put("key", "value");
      return params;
    }
  }
  
  public abstract class SimpleApi extends BaseApi{
  
      @Post(url="test")
      public abstract void testApi(@Callback TextResponseHandler callback);
      
  }
```
其中BaseApi为我们对网络请求的公共设置，根地址为"http://root.com/",超时时间为40秒，Content-type为Form，
还有一些公共请求参数。当我们在写自己的请求时候，只需要继承BaseApi这个类，就像刚才的例子一样，url只需要传相对
路径test，这样最终的请求url为"http://root.com/test"。当然我们也可以写绝对路径，如"https://www.baidu.com",
这样就不会再使用相对路径的方式进行拼接。
下面这例子就是一个简单的接口定义，和调用：
``` java
  public abstract class SimpleApi{
  
    public static SimpleApi instance() {
      return HttpRequest.inject(SimpleApi.class);
    }
  
    @Post(url="http://test.com", timeout=40, tag="tag", heads = {"key", "value"})
    public abstract void testApi(String key0,
                                 String key1,
                                 @Callback JSONResponseHandler callback);
                                 
    @GET(url="https://www.baidu.com")
    public abstract HttpRequest testApi2(@Callback JSONResponseHandler callback);
    
  }
  
  public class TestActivity extends Activity{
      
      private void invokeTestApi(){
        SimpleApi.instance().testApi("value0", "value1", new JSONResponseHandler(){
        
              public void onSuccess(JSONObject jsonObject, HttpResponse response){
              }
              
        });
        //auto execute
      }
      
      private void invokeTestApi2(){
        HttpRequest request = SimpleApi.instance().testApi2(new JSONResponseHandler(){
        
            public void onSuccess(JSONObject jsonObject, HttpResponse response){
            }
            
        });
        
        //execute
        request.execute();
      }
    
  }
```

这样我们就可以适配各种第三方网络请求库了，只需要实现我们定义的接口即可，具体代码请参见[MHttpAdapter]

[MHttpAdapter]: https://github.com/motcwang/MHttpAdapter

