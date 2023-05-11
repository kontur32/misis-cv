module namespace getPOST= "https://misis.ru/simplex/misis/api/v1/POST";


declare
  %rest:POST('{$body}')
  %rest:GET
  %rest:path ("/simplex/misis/api/v1/nc")
function  getPOST:statistic($body){
  file:write(file:base-dir()|| '/tmp/--' ||format-dateTime(current-dateTime(), "[Y0001]-[M01]-[D01]--[H01]-[m01]-[s01]" ) || '.json', $body)
};