(:~
 : Stop jobs.
 :
 : @author Christian Grün, BaseX Team, 2014-17
 :)
module namespace dba = 'dba/jobs';

import module namespace cons = 'dba/cons' at '../modules/cons.xqm';
import module namespace util = 'dba/util' at '../modules/util.xqm';

(:~ Top category :)
declare variable $dba:CAT := 'jobs';

(:~
 : Stops jobs.
 : @param  $ids  job ids
 : @return redirection
 :)
declare
  %rest:GET
  %rest:path("/dba/job-stop")
  %rest:query-param("id", "{$ids}")
function dba:job-stop(
  $ids  as xs:string*
) as element(rest:response) {
  cons:check(),
  let $params := try {
    $ids ! jobs:stop(.),
    map { 'info': util:info($ids, 'job', 'stopped') }
  } catch * {
    map { 'error': $err:description }
  }
  return web:redirect($dba:CAT, $params)
};
