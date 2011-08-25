<?php

function mylog($data)
{
    $ch = curl_init();
    $postData = http_build_query(array('json' => json_encode($data)));
    $opts = array(
      CURLOPT_URL            => 'http://localhost:8888/td.kzk.www_access?',
      CURLOPT_CONNECTTIMEOUT => 2,
      CURLOPT_POST           => true,
      CURLOPT_POSTFIELDS     => $postData,
      CURLOPT_RETURNTRANSFER => true,
      CURLOPT_TIMEOUT        => 2,
      // disable the 'Expect: 100-continue' behaviour. This causes CURL to wait
      // for 2 seconds if the server does not support this header.
      CURLOPT_HTTPHEADER     => array('Expect:'));
    curl_setopt_array($ch, $opts);

    curl_exec($ch);
    if (curl_errno($ch)) {
        var_dump(sprintf('[TreasureDataLogger] curl error: "%s"', curl_error($ch)));
    }
    curl_close($ch);
}

$data = array();
for ($a = 0; $a < 100; $a++) {
    $data['a' . $a] = "b" . $a;
}
mylog($data);

?>
