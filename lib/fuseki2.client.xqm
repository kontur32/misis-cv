(:~ 
  клинет для jena fuseki2
 :)
module namespace fuseki2 = 'http://garpix.com/semantik/app/fuseki2';

declare
  %public
function fuseki2:query(
  $sparql as xs:string,
  $endPoint as xs:string
) as item()*
{
  let $response :=
    try{
      fetch:text(
        web:create-url(
          $endPoint || '/sparql',
          map{
            'query':$sparql,
            'output':'json'
          }
        )
      )
    }catch*{
      false()
    }
  return
    if($response)
    then(
      try{
        json:parse($response)
      }catch*{
        <err:parse>Ошибка парсинга</err:parse>
      }
    )
    else(
      <err:request>Ошибка запроса</err:request>
    ) 
};

declare
  %public
function fuseki2:deleteGraph(
  $graphName as xs:string,
  $endPoint as xs:string
) as item()*
{
  let $request := replace('DROP GRAPH  <%1>', '%1', $graphName)
  let $url := web:create-url($endPoint,map{'update':$request})
  return
    http:send-request(
      <http:request method='POST'>
        <http:header name="Content-Type" value= 'application/x-www-form-urlencoded'/>
      </http:request>,
      $url
    ) 
};

declare
  %public
function fuseki2:uploadGraph(
  $rdf as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF),
  $graphURI as xs:string,
  $endPoint as xs:string
) as item()*
{
  let $url :=
    web:create-url($endPoint || "/data", map{'graph':$graphURI})
  let $request :=
      <http:request method='POST'>
        <http:multipart media-type="multipart/form-data; boundary=----7MA4YWxkTrZu0gW">
            <http:header name="Content-Disposition" value='form-data; name="file"; filename="file.rdf"'/>
            <http:body media-type="application/rdf+xml">{$rdf}</http:body>           
        </http:multipart> 
      </http:request>   
  let $response := http:send-request($request, $url)
  return
     $response
};

declare
  %public
function fuseki2:update(
  $query as xs:string,
  $endPoint as xs:string
){
  let $request :=
    <http:request method='POST'> 
          <http:body media-type = "application/x-www-form-urlencoded"/>
    </http:request>
      
  let $response := 
    http:send-request($request, $endPoint, 'update=' || $query)
  return
     $response[1]/@status/data()
};

declare
  %public
function fuseki2:upload-rdf(
  $rdf as element(Q{http://www.w3.org/1999/02/22-rdf-syntax-ns#}RDF),
  $graphName as xs:anyURI,
  $rdfEndpoint as xs:anyURI
) as item()*
{
  fuseki2:deleteGraph($graphName, $rdfEndpoint || '/update')[1]/@status/data(),
  fuseki2:uploadGraph($rdf, $graphName, $rdfEndpoint)[1]/@status/data()
};