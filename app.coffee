_ = require 'lodash'
request = require 'request'
jschardet = require 'jschardet'
Iconv = require('iconv').Iconv
zlib = require 'zlib'
charset = require 'charset'

convertToUtf8 = (headers, content)->
  # check charset by response headers
  charsetStr = charset headers, content, 4096

  unless charsetStr
    # check charset by response body
    detected = jschardet.detect content
    return content.toString() unless detected and detected.encoding
    charsetStr = detected.encoding

  if charsetStr != 'utf-8' and charsetStr != 'UTF-8' and charsetStr != 'UTF8' and charsetStr != 'utf8' and charsetStr != 'ascii' and charsetStr != 'ASCII'
    # if iconv convert error. use original content
    try
      iconvObj = new Iconv charsetStr, 'UTF-8//TRANSLIT//IGNORE'
      content = iconvObj.convert(content)
    catch e

  return content.toString()

unzipContent = (respon, body, cb)->
  # gzip/deflate/deflate raw uncompressed
  if respon.headers['content-encoding'] and respon.headers['content-encoding'].toLowerCase().indexOf('gzip') >= 0
    zlib.gunzip body, (unzipError, unzipBody)=>
      return cb unzipError, respon if unzipError
      return cb null, respon, convertToUtf8(respon.headers, unzipBody)
  else if respon.headers['content-encoding'] and respon.headers['content-encoding'].toLowerCase().indexOf('deflate') >= 0
    zlib.inflate body, (unzipError, unzipBody)=>
      return cb null, respon, convertToUtf8(respon.headers, unzipBody) unless unzipError
      
      if unzipError
        zlib.inflateRaw body, (unzipError, unzipBody)=>
          return cb unzipError, respon if unzipError
          return cb null, respon, convertToUtf8(respon.headers, unzipBody)
  else
    cb error, respon, convertToUtf8(respon.headers, body)

requestArgs = ['uri','url','qs','method','headers','body','form', 'formData','json','multipart','followRedirect',
  'followAllRedirects', 'maxRedirects','encoding','pool','timeout','proxy','auth','oauth','strictSSL',
  'jar','aws']

###
  option Object,  same as request options
  option uri   ,  request uri
  cb Function cb(error, respon, body)
###
newRequest = (option, cb)->
  if _.isString option
    option = uri: option

  defaultOption =
    encoding: null
    headers:
      'Accept-Charset': 'utf-8;q=0.7,*;q=0.3'
      'Accept-Encoding': 'gzip, deflate'

  _.merge defaultOption, option
  defaultOption = _.pick(defaultOption, requestArgs)

  request defaultOption, (error, respon, body)->
    return cb error, respon, null if error

    unzipContent respon, body, cb
