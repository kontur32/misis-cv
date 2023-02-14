module namespace header = "header";

declare function header:main( $params as map(*) ){
  map{
    'mainMenu' : $params?_('header/mainMenu', map{})
  }  
};