module namespace funct = "funct";

import module namespace getData = "getData" at "getData.xqm";
import module namespace config = "https://misis.ru/simplex/misis/api/v1/config" at "config.xqm";

import module namespace resource = "https://misis.ru/simplex/misis/api/v1/resource"
  at '../lib/resource.xqm';


declare function funct:replace( $string, $map ){
  fold-left(
        map:for-each( $map, function( $key, $value ){ map{ $key : $value } } ),
        $string, 
        function( $string, $d ){
           replace(
            $string,
            "\{\{" || map:keys( $d )[ 1 ] || "\}\}",
            replace( serialize( map:get( $d, map:keys( $d )[ 1 ] ) ), '\\', '\\\\' ) (: проблема \ в заменяемой строке :)
          ) 
        }
      )
};

declare function funct:xhtml( $app as xs:string, $map as item(), $componentPath ){
  let $appAlias := if( contains( $app, "/") ) then( tokenize( $app, "/" )[ last()] ) else( $app )
  let $string := 
    file:read-text(
      file:base-dir() || $componentPath ||  '/' || $app || "/"  || $appAlias || ".html"
    )
  
  return
    parse-xml(
      funct:replace( $string, $map )
    )
};

declare function funct:tpl( $app, $params ){
  let $componentPath := '../components'
  let $queryTpl := '
    import module namespace {{appAlias}} = "{{app}}" at "{{rootPath}}/{{app}}/{{appAlias}}.xqm";  
    declare variable $params external;
    {{appAlias}}:main( $params )'
  
  let $appAlias := 
    if( contains( $app, "/") ) then( tokenize( $app, "/")[ last() ] )  else( $app )
  
  let $query := 
    funct:replace(
      $queryTpl,
      map{
        'rootPath' : $componentPath,
        'app' : $app,
        'appAlias' : $appAlias
      }
    )
  
  let $tpl := function($app, $params){funct:tpl($app, $params)}
  let $config := function($param){config:param($param)}
  let $getFile := function($path, $xq, $storeID){getData:getFile($path, $xq, $storeID)}
  let $getData := 
    map{
      'getFile' : $getFile,
      'getData' : function($xquery, $params){getData:getData($xquery, $params)}
    }
  
  let $result :=
      xquery:eval(
          $query, 
          map{ 'params':
            map:merge( 
              ($params, map{'_' : $tpl, '_data' : $getData, '_config' : $config})
            )
          }
        )

  return
     funct:xhtml( $app, $result, $componentPath )
};