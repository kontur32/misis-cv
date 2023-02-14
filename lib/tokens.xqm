module namespace token = "funct/token/getToken";

import module namespace config = "https://misis.ru/simplex/misis/api/v1/config" 
  at '../core/config.xqm';
  
declare
  %public
function token:getTokenPayload($accessToken as xs:string) as map(*){
  let $token := tokenize($accessToken, '\.')[2]
  let $payload := 
    json:parse(convert:binary-to-string(xs:base64Binary($token)))/json
  let $iss := $payload/iss/text()
  let $userID := $payload/data/user/id/text()
  return
    map{
      'iss':$iss,
      'userID':$userID
    }
};


declare
  %public
function token:getToken() as xs:string*
{
  token:getToken(
    config:param('authHost'), 
    config:param('login'), 
    config:param('password') 
   )
};

declare
  %public
function token:getToken(
  $host as xs:string,
  $username as xs:string,
  $password as xs:string
) as xs:string*
{
  let $request := 
    <http:request method='post'>
        <http:multipart media-type = "multipart/form-data" >
          <http:header name="Content-Disposition" value= 'form-data; name="username";'/>
          <http:body media-type = "text/plain" >{$username}</http:body>
          <http:header name="Content-Disposition" value= 'form-data; name="password";' />
          <http:body media-type = "text/plain">{$password }</http:body>
        </http:multipart> 
      </http:request>
  
  let $response := 
      http:send-request(
        $request,
        $host || "/wp-json/jwt-auth/v1/token"
    )
    return
      if($response[1]/@status/data()="200")
      then($response[2]//token/text())
      else()
};