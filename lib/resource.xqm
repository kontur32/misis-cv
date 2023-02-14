module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource";

import module namespace token = "funct/token/getToken"   at '../lib/tokens.xqm';
import module namespace config = "https://misis.ru/simplex/misis/api/v1/config" 
  at '../core/config.xqm';

declare
  %public
function resource:файлTRCI($path as xs:string) as element(file)*
{
  resource:запрос(
    resource:адресЗапроса($path, ())
  )/file
};

declare
  %public
function resource:адресЗапроса(
  $path as xs:string,
  $method as xs:string*
) as xs:anyURI
{
   let $href := 
     web:create-url(
       string-join(
         (
           config:param('api.method.getData'),
           'stores',
           config:param('store.yandex.data'),
           $method
         ),
         '/'
       ),
       map{'path': $path}
     )
   return
     xs:anyURI($href)
};

declare
  %public
function resource:запросСпискаРесурсов($path as xs:string) as element()
{
  resource:запрос(resource:адресЗапроса($path, 'resources'))/child::*
};

declare
  %public
function resource:запросРесурса($path as xs:string) as xs:base64Binary*
{
  resource:запрос(resource:адресЗапроса($path, 'file'))
};

declare
  %public
function resource:запрос($href as  xs:anyURI)
{
  let $token := token:getToken()
  return
    http:send-request(
      <http:request method='GET'>
        <http:header name="Authorization" value= '{"Bearer " || $token}'/>
      </http:request>,
      $href
    )[2]
};