module namespace gender = "content/api/gender";

declare function gender:main($params as map(*)){
 map{
   "данные" : gender:gender($params)
 }
};

declare
  %private
function gender:gender(
  $params as map(*)
) as element(gender)
{
  let $q := 
  <req>
      <query>{$params?person}</query>
      <count>1</count>
  </req>
let $auth := "Token " || $params?_config('dadata-token')
let $request :=
    <http:request method='post'>
        <http:header name="Content-Type" value='application/xml'/>
        <http:header name="Accept" value='application/xml'/>
        <http:header name="Authorization" value='{$auth}'/>
        <http:body media-type = "application/xml">{$q}</http:body>
    </http:request> 
  let $response := 
    http:send-request ($request, "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/fio")
  return 
      $response[2]//data/gender
};