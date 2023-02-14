module namespace misis = "misis/user";

import module namespace funct="funct" at "../core/functions.xqm";

declare 
  %rest:GET
  %rest:path("/simplex/misis/u")
  %output:method("xhtml")
  %output:doctype-public("www.w3.org/TR/xhtml11/DTD/xhtml11.dtd")
function misis:main(){
    let $params :=    
       map{
        'header' : funct:tpl('header', map{}),
        'content' : <div>{funct:tpl("content/cv.teachers.list", map{})}</div>,
        'footer' : funct:tpl('footer', map{})
      }
    return
      funct:tpl('main', $params)
};