---
title: 多平台使用字体图标
date: 2016-05-06 13:40:41
categories: Client
tags: 字体图标
---

最近比较流行字体图标，下面说一下分别在HTML、Android和iOS中怎么使用字体图标。
### 一、HTML
#### 具体步骤
1.font-face声明字体
```css
@font-face {
    font-family: 'iconfont';
    src: url('iconfont.eot'); /* IE9*/
    src: url('iconfont.eot?#iefix') format('embedded-opentype'), /* IE6-IE8 */
    url('iconfont.woff') format('woff'), /* chrome、firefox */
    url('iconfont.ttf') format('truetype'), /* chrome、firefox、opera、Safari, Android, iOS 4.2+*/
    url('iconfont.svg#iconfont') format('svg'); /* iOS 4.1- */
}
```
2.定义使用iconfont的样式
```css
.iconfont{
    font-family:"iconfont";
    font-size:16px;
    font-style:normal;
}
```
3.挑选相应图标并获取字体编码，应用于页面
```css
<i class="iconfont">&#33</i>
```
#### 常见问题
1.字体图标在safair或chrome浏览器下被加粗？
由于字体图标存在半个像素的锯齿，在浏览器渲染的时候直接显示一个像素了，导致在有背景下的图标显示感觉加粗；所以在应用字体图标的时候需要对图标样式进行抗锯齿处理，CSS代码设置如下：
```css
.iconfont{
    -webkit-font-smoothing: antialiased;
}
```
2.字体图标在IE7浏览器显示中图标右侧出现小方框现象？
可以对引用字体图标的非块标签进行以下CSS定义:
```css
display: block;
```
3.字体图标在pc端的chrome浏览器下出现严重的锯齿？
可以对字体图标的边缘进行模糊；（只支持webkit内核浏览器,参数数值不宜设置得很大，这会带来图标加粗的问题）
```css
-webkit-text-stroke-width: 0.2px;
```

### 二、Android
#### 具体步骤
1.复制字体文件到项目 assets 目录；
2.打开 iconfont 目录中的 demo.html，找到图标相对应的 HTML 实体字符码；
3.打开 res/values/strings.xml，添加 string 值；
```xml
<string name="icons">&#x3605; &#x35ad; &#x35ae; &#x35af;</string>
```
4.添加 string 值到 TextView：
```xml
<TextView
    android:id="@+id/iconfont"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="@string/icons" />
```
5.为 TextView 设置字体
```java
    Typeface iconfont = Typeface.createFromAsset(getAssets(), "iconfont/iconfont.ttf");
    TextView textview = (TextView)findViewById(R.id.like);
    textview.setTypeface(iconfont);
```

### 三、iOS
#### 具体步骤
1.将您IconFont刚下载的字体文件(.ttf)添加到工程中
2.打开Info.plist文件，增加一个新的Array类型的键，键名设置为UIAppFonts（Fonts provided by application），增加字体的文件名：“iconfont.ttf“
3.使用IconFont字体:
```java
UILabel * label = [[UILabel alloc] initWithFrame:self.view.bounds];
UIFont *iconfont = [UIFont fontWithName:@"uxIconFont" size: 34];
label.font = iconfont;
label.text = @"\U00003439 \U000035ad \U000035ae \U000035af \U000035eb \U000035ec";
[self.view addSubview: label];
```
#### 注意
创建 UIFont 使用的是字体名，而不是文件名；
文本值为 8 位的 Unicode 字符，我们可以打开 demo.html 查找每个图标所对应的 HTML 实体 Unicode 码，比如：
"店" 对应的 HTML 实体 Unicode 码为：
0x3439
转换后为
\U00003439
就是将 0x 替换为 \U 中间用 0 填补满长度为 8 个字符

### 四、图标制作
[link]
[link]: http://iconfont.cn/help/iconmake.html