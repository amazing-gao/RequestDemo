## request demo

使用[request](https://github.com/request/request)抓取网页，并对网页内容处理

---

## 示例
```coffee
request = require('./app')

request 'http://www.baidu.com', (error, resp, body)->
  console.log error
  console.log body

```

---

## 特性

* 检测HTTP响应头中的编码或者响应体的编码，并转为UTF8
* 使用gzip/deflate压缩请求，并对结果进行解压缩

实际测试已经抓取数千个网站均可以正常工作，如发现不能正常工作的站点，感谢提交issue
