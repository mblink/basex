(:~
 : Jobs page.
 :
 : @author Christian Grün, BaseX Team 2005-24, BSD License
 :)
module namespace dba = 'dba/jobs';

import module namespace config = 'dba/config' at '../lib/config.xqm';
import module namespace html = 'dba/html' at '../lib/html.xqm';
import module namespace utils = 'dba/utils' at '../lib/utils.xqm';

(:~ Top category :)
declare variable $dba:CAT := 'jobs';

(:~
 : Jobs page.
 : @param  $sort   table sort key
 : @param  $job    highlighted job
 : @param  $error  error message
 : @param  $info   info message
 : @return page
 :)
declare
  %rest:GET
  %rest:path('/dba/jobs')
  %rest:query-param('sort',  '{$sort}', 'duration')
  %rest:query-param('job',   '{$job}')
  %rest:query-param('error', '{$error}')
  %rest:query-param('info',  '{$info}')
  %output:method('html')
  %output:html-version('5')
function dba:jobs(
  $sort   as xs:string,
  $job    as xs:string?,
  $error  as xs:string?,
  $info   as xs:string?
) as element(html) {
  html:wrap(map { 'header': $dba:CAT, 'info': $info, 'error': $error },
    <tr>{
      <td>
        <form method='post'>
        <h2>Jobs</h2>
        {
          let $admin := user:list-details(session:get($config:SESSION-KEY))/@permission = 'admin'
          let $headers := (
            map { 'key': 'id', 'label': 'ID' },
            map { 'key': 'state', 'label': 'State' },
            map { 'key': 'duration', 'label': 'Dur.', 'type': 'number', 'order': 'desc' },
            map { 'key': 'user', 'label': 'User' },
            map { 'key': 'you', 'label': 'You' },
            map { 'key': 'time', 'label': 'Time', 'type': 'time', 'order': 'desc' },
            map { 'key': 'start', 'label': 'Start', 'type': 'time', 'order': 'desc' }
          )
          let $entries :=
            let $curr := job:current()
            for $details in job:list-details()
            let $id := $details/@id
            let $sec := (
              let $dur := xs:dayTimeDuration($details/@duration)
              return if(exists($dur)) then $dur div xs:dayTimeDuration('PT1S') else 0
            )
            let $time := data($details/@time)
            let $start := data($details/@start)
            order by $sec descending, $start descending
            return map {
              'id': $id,
              'state': $details/@state,
              'duration': html:duration($sec),
              'user': $details/@user,
              'you': if($id = $curr) then '✓' else '–',
              'time': $time,
              'start': $start otherwise $time
            }
          let $buttons := if $(admin) then (
            html:button('job-remove', 'Remove', ('CHECK', 'CONFIRM'))
          ) else ()
          let $options := map { 'sort': $sort, 'presort': 'duration' }
          return html:table($headers, $entries, $buttons, map { }, $options) update {
            (: replace job ids with links :)
            for $tr in tr[not(th)]
            for $text in $tr/td[1]/text()
            for $id in data($tr/@id)
            for $entries in $entries[?id = $id][?you = '–']
            return replace node $text with <a href='?job={ $entries?id }'>{ $text }</a>
          }
        }
        </form>
      </td>,

      if($job) then (
        let $details := job:list-details($job)
        let $cached := $details/@state = 'cached'
        return (
          <td class='vertical'/>,
          <td>
            <form method='post'>{
              <input type='hidden' name='id' value='{ $job }'/>,
              <h2>{
                'Job: ', $job, '&#xa0;',
                if($details) then html:button('job-remove', 'Remove')
              }</h2>,

              if($details) then (
                <h3>General Information</h3>,
                <table>{
                  for $value in $details/@*
                  for $name in name($value)[. != 'id']
                  return <tr>
                    <td><b>{ utils:capitalize($name) }</b></td>
                    <td>{ string($value) }</td>
                  </tr>
                }</table>,
  
                let $bindings := job:bindings($job)
                where map:size($bindings) > 0
                return (
                  <h3>Query Bindings</h3>,
                  <table>{
                    map:for-each($bindings, fn($key, $value) {
                      <tr>
                        <td><b>{ if($key) then '$' || $key else 'Context' }</b></td>
                        <td><code>{
                          utils:chop(serialize($value, map { 'method': 'basex' }), 1000)
                        }</code></td>
                      </tr>
                    })
                  }
                  </table>
                ),
  
                if($cached) then (
                  let $result := try {
                    utils:serialize(job:result($job, map { 'keep': true() }))
                  } catch * {
                    'Stopped at ' || $err:module || ', ' || $err:line-number || '/' ||
                      $err:column-number || ':' || char('\n') || $err:description
                  }
                  where $result
                  return (
                    <h3>{
                      'Result', '&#xa0;',
                      html:button('job-result', 'Download')
                    }
                    </h3>,
                    <textarea name='output' id='output' readonly='' spellcheck='false'>{
                      $result
                    }</textarea>,
                    html:js('loadCodeMirror("xml");')
                  )
                ),

                <h3>Job String</h3>,
                <textarea readonly='' spellcheck='false'>{
                  string($details)
                }</textarea>
              ) else (
                'Job has expired.'
              )
            }</form>
          </td>
        )
      ) else()
    }</tr>
  )
};
