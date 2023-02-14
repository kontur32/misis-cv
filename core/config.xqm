module namespace config = "https://misis.ru/simplex/misis/api/v1/config";

declare variable $config:param := function( $param ){ config:param ( $param ) };

declare  function config:param ( $param as xs:string ) as xs:string* {
  doc ( "../config.xml" ) 
  /config/param[ @id = $param ]/text()
};