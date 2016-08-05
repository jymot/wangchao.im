---
title: sencha-touch-chrome43
date: 2016-01-08 08:42:43
categories: Web
tags: [Javascript, sencha touch]
---
解决 Sencha Touch 在 Chrome 43 上面滑动问题的bug
![Smithsonian Image](/images/Screen-Shot-2015-04-28-at-9.10.36-AM.png)

<!--more-->

在初始化 Sencha Touch 时，重写 Ext.util.SizeMonitor 和 Ext.util.PaintMonitor:
``` javascript
Ext.override(Ext.util.SizeMonitor, {
    constructor: function(config) {
        var namespace = Ext.util.sizemonitor;

        if (Ext.browser.is.Firefox) {
            return new namespace.OverflowChange(config);
        } else if (Ext.browser.is.WebKit) {
            if (!Ext.browser.is.Silk &amp;&amp; Ext.browser.engineVersion.gtEq('535') &amp;&amp; !Ext.browser.engineVersion.ltEq('537.36')) {
                return new namespace.OverflowChange(config);
            } else {
                return new namespace.Scroll(config);
            }
        } else if (Ext.browser.is.IE11) {
          return new namespace.Scroll(config);
        } else {
          return new namespace.Scroll(config);
        }
    }
});
```
``` javascript
Ext.override(Ext.util.PaintMonitor, {
  constructor: function(config) {
      if (Ext.browser.is.Firefox || (Ext.browser.is.WebKit &amp;&amp; Ext.browser.engineVersion.gtEq('536') &amp;&amp; !Ext.browser.engineVersion.ltEq('537.36') &amp;&amp; !Ext.os.is.Blackberry)) {
          return new Ext.util.paintmonitor.OverflowChange(config);
      }
      else {
          return new Ext.util.paintmonitor.CssAnimation(config);
      }
  }
});
```
