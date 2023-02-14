module namespace main = "main";

declare function main:main( $params as map(*) ){
  map{
    'header' : $params?header,
    'content' : $params?content,
    'footer' : $params?footer
  }
};