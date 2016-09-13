(:~
 : Download resources.
 :
 : @author Christian Grün, BaseX Team, 2014-16
 :)
module namespace _ = 'dba/databases';

import module namespace cons = 'dba/cons' at '../../modules/cons.xqm';
import module namespace util = 'dba/util' at '../../modules/util.xqm';

(:~
 : Downloads a resource.
 : @param  $name      database
 : @param  $resource  resource
 : @param  $file      file name (ignored)
 : @return rest response and file content
 :)
declare
  %rest:path("/dba/download/{$file}")
  %rest:query-param("name",     "{$name}")
  %rest:query-param("resource", "{$resource}")
function _:download(
  $name      as xs:string,
  $resource  as xs:string,
  $file      as xs:string
) as item()+ {
  cons:check(),
  try {
    let $options := map { 'name': $name, 'resource': $resource }
    let $raw := util:eval("db:is-raw($name, $resource)", $options)
    let $ct := util:eval("db:content-type($name, $resource)", $options)
    return (
      web:response-header(map { 'media-type': $ct }),
      util:eval(
        if($raw) then "db:retrieve($name, $resource)" else "db:open($name, $resource)", $options
      )
    )
  } catch * {
    <rest:response>
      <http:response status="400" message="{ $err:description }"/>
    </rest:response>
  }
};

(:~
 : Downloads a database backup.
 : @param  $backup  name of backup file (ignored)
 : @return zip file
 :)
declare
  %rest:path("/dba/backup/{$backup}")
  %output:media-type("application/octet-stream")
function _:download(
  $backup  as xs:string
) {
  cons:check(),
  util:eval("file:read-binary(db:system()/globaloptions/dbpath || '/' || $backup)",
    map { 'backup': $backup }
  )
};
