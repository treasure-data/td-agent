import tornado.escape json_encode
import urllib
from tornado.httpclient import AsyncHTTPClient

encoded_json = json_encode({'test': 1, 'semicolon' : ';'})
message = "json=%s" % urllib.quote(encoded_json)

request = HTTPRequest(
    headers={"Content-Type": "application/x-www-form-urlencoded"},
            url="<URL of TD-agent>",
            method="POST",
            body=message)

AsyncHTTPClient().fetch(request)
