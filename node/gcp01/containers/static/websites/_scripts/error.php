<?php

const PAGE_TITLE = 'Error %1$d (%2$s)';
const BODY_TITLE = 'Error %1$d: %2$s!';

const LINK_HREF = 'https://www.mcarvalhor.com/';
const LINK_TITLE = 'Home Page';

const DEFAULT_ERROR = [
	'title' => 'Unknown Error',
	'msg' => 'The content you are looking for is not available at this time.\n\n'
			. 'Check the web address, refresh your DNS cache or try again later.',
];

const ERROR_LIST = [
	400 => [
		'title' => 'Bad Request',
		'msg' => 'The request could not be understood by the server due to malformed syntax.\n\n'
				 . 'Check the web address and try again.',
	],
	401 => [
		'title' => 'Unauthorized',
		'msg' => 'You need to be authenticated to access the content you are looking for.\n\n'
				 . 'Please sign in and try again.',
	],
	403 => [
		'title' => 'Forbidden',
		'msg' => 'You do not have permission to access the content you are looking for.\n\n'
				 . 'Check your credentials or contact the administrator.',
	],
	404 => [
		'title' => 'Not Found',
		'msg' => 'The content you are looking for was not found.\n\n'
				 . 'Check the web address or try again later.',
	],
	405 => [
		'title' => 'Method Not Allowed',
		'msg' => 'The request method is not supported for the content you are looking for.\n\n'
				 . 'Check the web address and try again.',
	],
	408 => [
		'title' => 'Request Timeout',
		'msg' => 'The server timed out waiting for the request.\n\n'
				 . 'Please try again.',
	],
	429 => [
		'title' => 'Too Many Requests',
		'msg' => 'You have sent too many requests in a short period of time.\n\n'
				 . 'Please wait a moment and try again.',
	],
	500 => [
		'title' => 'Internal Server Error',
		'msg' => 'Something wrong happened on the server\'s end and the content you are looking for failed to be loaded at this time.\n\n'
				 . 'Try again later.',
	],
	501 => [
		'title' => 'Not Implemented',
		'msg' => 'The content you are looking for is not available yet.\n\n'
				 . 'Try again later.',
	],
	502 => [
		'title' => 'Bad Gateway',
		'msg' => 'The server received an invalid response from an upstream server.\n\n'
				 . 'Try again later.',
	],
	503 => [
		'title' => 'Service Unavailable',
		'msg' => 'The service is temporarily unavailable, possibly due to maintenance or overload.\n\n'
				 . 'Try again later.',
	],
	504 => [
		'title' => 'Gateway Timeout',
		'msg' => 'The server did not receive a timely response from an upstream server.\n\n'
				 . 'Try again later.',
	],
];



$errorCode = (int) ($_SERVER["REDIRECT_STATUS"] ?? 0);
$errorTitle = DEFAULT_ERROR["title"];
$errorMsg = DEFAULT_ERROR["msg"];

if($errorCode < 100 || $errorCode > 599) {
	$errorCode = 200;
}

if(isset(ERROR_LIST[$errorCode])) {
	$errorTitle = ERROR_LIST[$errorCode]["title"];
	$errorMsg = ERROR_LIST[$errorCode]["msg"];
}

http_response_code($errorCode);
?><!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width,height=device-height,initial-scale=1">
		<meta name="robots" content="noindex,nofollow,noarchive,noodp,noydir">
		<meta name="description" content="<?php echo htmlspecialchars(sprintf(_(PAGE_TITLE), $errorCode, _($errorTitle)), ENT_QUOTES | ENT_HTML5); ?>">
		<meta name="author" content="https://www.mcarvalhor.com/">
		<link rel="author" href="https://www.mcarvalhor.com/">
		<link rel="icon" type="image/png" sizes="16x16 32x32 64x64" href="//resources.mcarvalhor.com/client/favicon_64.png">
		<link rel="icon" type="image/png" sizes="128x128 256x256 512x512" href="//resources.mcarvalhor.com/client/favicon.png">
		<title><?php echo htmlspecialchars(sprintf(_(PAGE_TITLE), $errorCode, _($errorTitle)), ENT_QUOTES | ENT_HTML5); ?></title>
		<style type="text/css">
			body {
				color: rgb(80,80,80);
				background-color: rgb(255, 255, 255);
			}
			section {
				display: grid;
				grid-template-columns: auto 30%;
				grid-template-rows: auto auto auto;
				margin: 50px auto;
				width: 90%;
				max-width: 500px;
				border: solid 2px rgb(200,200,200);
				border-radius: 10px;
				padding: 20px;
			}
			section > header {
				grid-column-start: 1;
				grid-column-end: span 1;
				grid-row-start: 1;
				grid-row-end: span 1;
				margin-bottom: 20px;
			}
			section > header h1 {
				margin: 0px;
			}
			section > div.body {
				grid-column-start: 1;
				grid-column-end: span 1;
				grid-row-start: 2;
				grid-row-end: span 1;
				text-align: justify;
			}
			section > figure {
				grid-column-start: 2;
				grid-column-end: span 1;
				grid-row-start: 1;
				grid-row-end: span 2;
				justify-self: center;
				align-self: center;
				margin: 0px;
				padding: 5px;
			}
			section > figure img {
				width: 100%;
				border: none;
			}
			section > div.links {
				grid-column-start: 1;
				grid-column-end: span 2;
				grid-row-start: 3;
				grid-row-end: span 1;
				justify-self: center;
				align-self: center;
				padding: 5px;
			}
			section > div.links a {
				display: inline-block;
				margin: 2px;
				padding: 5px;
				text-align: center;
				background-color: rgb(65, 113, 155);
				color: rgb(255, 255, 255);
				border-radius: 5px;
				text-decoration: none;
				transition: background-color 0.25s, color 0.25s;
			}
			section > div.links a:hover {
				background-color: rgb(119, 156, 191);
			}
		</style>
	</head>
	<body>
		<section>
			<header>
				<h1><?php echo htmlspecialchars(sprintf(_(BODY_TITLE), $errorCode, _($errorTitle)), ENT_QUOTES | ENT_HTML5); ?></h1>
			</header>
			<div class="body">
				<?php
					$pars = preg_split('/\R+/', trim(_($errorMsg)));
					if($pars !== false) {
						foreach($pars as $par) {
							$par = trim($par);
							if($par === '') {
								continue;
							}
							echo '<p>' . htmlspecialchars($par, ENT_QUOTES | ENT_HTML5) . '</p>';
						}
					}
				?>
			</div>
			<figure>
				<img alt="Error" src="//resources.mcarvalhor.com/client/http-status.png" onerror="this.style.display='none';" />
			</figure>
			<div class="links">
				<a href="<?php echo htmlspecialchars(LINK_HREF, ENT_QUOTES | ENT_HTML5); ?>"><?php echo htmlspecialchars(LINK_TITLE, ENT_QUOTES | ENT_HTML5); ?></a>
			</div>
		</section>
	</body>
</html>