module namespace api = "https://misis.ru/simplex/misis/api/v1/api";
  
import module namespace funct="funct" at "../core/functions.xqm";

declare
  %rest:GET
  %rest:query-param('output', '{$output}', 'xml')
  %rest:path ("/simplex/misis/api/v1/public/{$method}")
function  api:get($method, $output)
{
  let $result := funct:tpl("content/api/" || $method, map{})
  return
    switch ($output)
    case 'csv'
      return 
        (
          <rest:response>
            <http:response status="200">
              <http:header name="Content-type" value="text/csv; charset=windows-1251"/>
            </http:response>
          </rest:response>,
          serialize($result, map{'method': 'csv', 'encoding':'Cp1251', 'csv': map{'separator':';', 'header': true()}})
        )
    case 'xml' return $result
    case 'json'
      return
        (
          <rest:response>
            <http:response status="200">
              <http:header name="Content-type" value="application/json"/>
            </http:response>
          </rest:response>,
          json:serialize(<json type='object'>{$result}</json>)
        )
    default return $result
};