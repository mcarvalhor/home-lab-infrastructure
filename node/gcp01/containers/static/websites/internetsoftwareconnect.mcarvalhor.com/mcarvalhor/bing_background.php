<?php

$active=true;
$curl_address="https://www.bing.com";
$curl_addresspath=$curl_address."/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=en-US";

if($active!=true || empty($curl_addresspath)){
	header("Cache-Control: no-cache, must-revalidate");
	header("Cache-Control: max-age=0");
	header("Pragma: no-cache");
	header("Last-Modified: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-240));
	header("Expires: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-120));
	exit();
}

/*if(filesize("Background_CookieFile.tmp")>131072){
	unlink("Background_CookieFile.tmp");
}*/

$curl_obj=curl_init($curl_addresspath);
$curl_options=array(
	CURLOPT_CUSTOMREQUEST=>"GET",
	CURLOPT_POST=>false,
	CURLOPT_USERAGENT=>"Mozilla/5.0 (Windows NT 6.1; rv:8.0) Gecko/20100101 Firefox/8.0",
	//CURLOPT_COOKIEFILE=>"Background_CookieFile.tmp",
	//CURLOPT_COOKIEJAR=>"Background_CookieFile.tmp",
	CURLOPT_RETURNTRANSFER=>true,     // return web page
	CURLOPT_HEADER=>false,    // don't return headers
	CURLOPT_FOLLOWLOCATION=>false,     // follow redirects
	CURLOPT_ENCODING=>"",       // handle all encodings
	CURLOPT_SSL_VERIFYPEER=>false,       // check SSL certificate
	CURLOPT_AUTOREFERER=>true,     // set referer on redirect
	CURLOPT_CONNECTTIMEOUT=>5,      // timeout on connect
	CURLOPT_TIMEOUT=>10,      // timeout on response
	CURLOPT_MAXREDIRS=>5,       // stop after 5 redirects
);
curl_setopt_array($curl_obj,$curl_options);
$curl_content=curl_exec($curl_obj);
$curl_errornumber=curl_errno($curl_obj);
$curl_httpstatus=curl_getinfo($curl_obj,CURLINFO_HTTP_CODE);
//$curl_header=curl_getinfo($curl_obj);
curl_close($curl_obj);
if(($curl_errornumber==0) && ($curl_httpstatus==200)){
	$node_obj=simplexml_load_string($curl_content);
	if(!empty($node_obj->image[0]->url)){
		header("Cache-Control: private");
		header("Cache-Control: max-age=21600");
		header("Last-Modified: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-120));
		header("Expires: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()+43200));
		header("Location: ".$curl_address.($node_obj->image[0]->url));
	}else{
		header("Cache-Control: no-cache, must-revalidate");
		header("Cache-Control: max-age=0");
		header("Pragma: no-cache");
		header("Last-Modified: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-240));
		header("Expires: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-120));
	}
}else{
	header("Cache-Control: no-cache, must-revalidate");
	header("Cache-Control: max-age=0");
	header("Pragma: no-cache");
	header("Last-Modified: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-240));
	header("Expires: ".gmstrftime("%a, %d %b %Y %H:%M:%S GMT",time()-120));
}
exit();
?>	