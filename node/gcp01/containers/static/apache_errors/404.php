<?php

const ERROR_CODE = 404;
const ERROR_TITLE = 'Not Found';
const ERROR_MSG = 'The content you are looking for is not available at this time.\n\n'
				. 'Check the web address, refresh your DNS cache and try again later.';


const PAGE_TITLE = 'Error %1$d (%2$s)';
const BODY_TITLE = 'Error %1$d: %2$s!';

const LINK_TITLE = 'Home Page';

http_response_code(ERROR_CODE);
?><!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width,height=device-height,initial-scale=1">
		<meta name="robots" content="noindex,nofollow,noarchive,noodp,noydir">
		<meta name="author" content="https://www.mcarvalhor.com/">
		<link rel="author" href="https://www.mcarvalhor.com/">
		<link rel="icon" type="image/png" sizes="16x16 32x32 64x64" href="//resources.mcarvalhor.com/client/favicon_64.png">
		<link rel="icon" type="image/png" sizes="128x128 256x256 512x512" href="//resources.mcarvalhor.com/client/favicon.png">
		<title><?php echo sprintf(_(PAGE_TITLE), ERROR_CODE, _(ERROR_TITLE)); ?></title>
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
				transition: background-color,color 0.25s,0.25s;
			}
			section > div.links a:hover {
				background-color: rgb(119, 156, 191);
			}
		</style>
	</head>
	<body>
		<section>
			<header>
				<h1><?php echo sprintf(_(BODY_TITLE), ERROR_CODE, _(ERROR_TITLE)); ?></h1>
			</header>
			<div class="body">
				<?php
					$pars = explode('\n', trim(_(ERROR_MSG)));
					if($pars !== FALSE) {
						foreach($pars as $par) {
							if(empty($par)) {
								continue;
							}
							echo '<p>' . htmlspecialchars($par, ENT_QUOTES | ENT_HTML5) . '</p>';
						}
					}
				?>
			</div>
			<figure>
				<img alt="" src="//resources.mcarvalhor.com/client/http-status.png" onerror="this.style.display='none';" />
			</figure>
			<div class="links">
				<a href="https://www.mcarvalhor.com/"><?php echo LINK_TITLE; ?></a>
			</div>
		</section>
	</body>
</html>
