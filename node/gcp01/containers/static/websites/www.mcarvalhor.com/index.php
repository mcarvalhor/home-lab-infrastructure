<?php

$socialLinks = [ ];

$headerImage = "picture-default.jpg";

$content = "This website is not bootstraped yet. See '.config.php.template' file.";
$subtitle = "Home Page";
$seoDescription = "";
$seoKeywords = "";

$mail = ["", ""];
$phone = ["", ""];
$location = ["", ""];

$footer = '<span>' . date("Y") . '</span>';

$turnstilePublicToken = "";
$turnstileSecretToken = "";

if (file_exists("config.php")) {
	include("config.php");
}

$requestType = $_GET["req"];
if ($requestType == "submit") {
	if(!empty($_POST["cf-turnstile-response"])){
		$requestData = ["secret" => $turnstileSecretToken, "response" => $_POST["cf-turnstile-response"], "remoteip" => $_SERVER["REMOTE_ADDR"]];
		try {
			$requestOptions = ["http" => ["header" => "Content-type: application/x-www-form-urlencoded\r\n", "method" => "POST", "content" => http_build_query($requestData)]];
			$requestStreamContext = stream_context_create($requestOptions);
			$requestResults = json_decode(file_get_contents("https://challenges.cloudflare.com/turnstile/v0/siteverify", false, $requestStreamContext), true);
			if($requestResults["success"] == true) {
				$headerLinks = "";
				$footerLinks = "";
				if (!empty($mail[0])) {
					if (empty($mail[1])) {
						$footerLinks .= '<div><span class="fas fa-envelope"></span> ' . $mail[0] . '</div>';
					} else {
						$footerLinks .= '<div><a href="' . $mail[1] . '"><span class="fas fa-envelope"></span> ' . $mail[0] . '</a></div>';
					}
				}
				if (!empty($phone[0])) {
					if (empty($phone[1])) {
						$footerLinks .= '<div><span class="fas fa-phone"></span> ' . $phone[0] . '</div>';
					} else {
						$footerLinks .= '<div><a href="' . $phone[1] . '"><span class="fas fa-phone"></span> ' . $phone[0] . '</a></div>';
					}
				}
				if (!empty($location[0])) {
					if (empty($location[1])) {
						$footerLinks .= '<div><span class="fas fa-map-marked-alt"></span> ' . $location[0] . '</div>';
					} else {
						$footerLinks .= '<div><a href="' . $location[1] . '"><span class="fas fa-map-marked-alt"></span> ' . $phone[0] . '</a></div>';
					}
				}
				foreach ($socialLinks as &$link) {
					if (is_string($link[2])) {
						$headerLinks .= '<a href="' . $link[2] . '" target="_blank" title="' . $link[1] . '" class="fab fa-' . $link[0] . '"></a>';
					} else {
						$headerLinks .= '<a href="' . $link[2][0] . '" title="' . $link[1] . '" onclick="messageText(this.getAttribute(\'data-msg\')); return false;" data-msg="' . htmlentities($link[2][1]) . '" class="fab fa-' . $link[0] . '"></a>';
					}
				}
				$headerLinks = json_encode($headerLinks);
				$footerLinks = json_encode($footerLinks);
				$footer = json_encode($footer);
				echo '{"status": "success", "data": [' . $headerLinks . ', ' . $footerLinks . ', ' . $footer . ']}';
			} else {
				echo '{"status": "error", "data": "token"}';
			}
		} catch(Exception $e) {
			echo '{"status": "error", "data": "token"}';
		}
	} else {
		echo '{"status": "error", "data": "token"}';
	}
	exit();
}
?><!DOCTYPE html>
<html>

<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width,height=device-height,initial-scale=1,user-scalable=no">
	<meta name="robots" content="index,follow,archive,noimageindex">
	<meta name="author" content="https://www.mcarvalhor.com/">
	<meta name="description" content="<?php echo $seoDescription; ?>">
	<meta name="keywords" content="<?php echo $seoKeywords; ?>">
	<link rel="author" href="https://www.mcarvalhor.com/">
	<link rel="icon" type="image/png" sizes="16x16 32x32 64x64" href="https://resources.mcarvalhor.com/client/favicon_64.png">
	<link rel="icon" type="image/png" sizes="128x128 256x256 512x512" href="https://resources.mcarvalhor.com/client/favicon.png">
	<link rel="stylesheet" href="css/fontawesome-free-6.5.1-all.min.css">
	<title>Matheus CR. (Matt) | <?php echo $subtitle; ?></title>
	<style type="text/css">
		:root {
			--font-sans:
				system-ui, -apple-system, "Segoe UI", Roboto, Ubuntu, Cantarell,
				"Noto Sans", "Liberation Sans", Arial, sans-serif,
				"Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji";

			--font-mono:
				ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas,
				"Liberation Mono", "DejaVu Sans Mono", monospace;
		}
		@media not all and (min-width: 360px) and (min-height: 310px){
			#main-noscreen {
				display: block;
			}
			#main {
				display:none;
			}
		}
		@media all and (min-width: 360px) and (min-height: 310px){
			#main-noscreen {
				display:none;
			}
			#main {
				display:block;
			}
			#header-image {
				display: block;
			}
			#header-info {
				display: block;
				text-align: center;
			}
			#footer-links div {
				display: block;
			}
		}
		@media all and (min-width: 1000px) and (min-height: 310px) {
			#header-image {
				display: inline-block;
			}
			#header-info {
				display: inline-block;
				text-align: left;
				margin-left: 10px;
				float: right;
			}
			#footer-links div {
				display: inline-block;
				width: 32%;
			}
		}
		body {
			display: block;
			margin: 0 auto;
			background-color: rgb(0, 0, 0);
			color: rgb(255, 255, 255);
			font-size: 1.1em;
			font-family: var(--font-mono);
		}
		#main {
			width: 90%;
			min-width: 350px;
			max-width: 1080px;
			margin: 50px auto;
			color: rgb(0, 0, 0);
			border-radius: 15px;
			background-color: rgb(255, 255, 255);
			box-shadow: 0px 0px 5px 5px rgb(255, 255, 255);
		}
		#main-noscreen {
			margin: 3px;
			color: rgb(255,0,0);
			text-align: justify;
		}
		#windowShadow {
			overflow: hidden;
		}
		#windowShadowEffect {
			position: fixed;
			width: 100%;
			height: 100%;
			top: 0px;
			left: 0px;
			background-color: rgba(0, 0, 0, 0.5);
			overflow: hidden;
			z-index: 500;
		}
		#botWindow {
			position: fixed;
			width: 302px;
			height: 68px;
			top: 50%;
			left: 50%;
			margin-left: -151px;
			margin-top: -38px;
			padding: 5px;
			border-radius: 5px;
			background-color: rgb(255, 255, 255);
			text-align: center;
			overflow: hidden;
			z-index: 1000;
		}
		#messageWindow {
			position: fixed;
			width: 302px;
			height: 76px;
			top: 50%;
			left: 50%;
			margin-left: -151px;
			margin-top: -38px;
			padding-left: 5px;
			padding-top: 15px;
			padding-right: 5px;
			padding-bottom: 5px;
			border-radius: 5px;
			background-color: rgb(255, 255, 255);
			text-align: center;
			overflow: hidden;
			z-index: 1005;
		}
		#messageWindow a {
			color: rgb(0, 0, 0);
			text-decoration: none;
		}
		#messageWindow a:hover {
			color: rgb(50, 119, 255);
		}
		#header {
			display: block;
			padding: 50px;
			border-bottom: 1px solid rgb(100, 100, 100);
			text-align: center;
			overflow: auto;
		}
		#header-wrapper {
			display: inline-block;
		}
		#header-image a {
			display: block;
			text-decoration: none;
		}
		#header-image img {
			display:block;
			width: 230px;
			max-height: 300px;
			border: none;
			border-radius: 100%;
			margin: 0 auto;
		}
		#header-title {
			display: block;
			color: rgb(50, 119, 255);
			font-size: 2.5em;
			font-weight: bold;
			margin-bottom: 10px;
		}
		#header-title a {
			color: rgb(50, 119, 255);
			text-decoration: none;
		}
		#header-subtitle {
			display: block;
			font-size: 1.5em;
			color: rgb(100, 100, 100);
		}
		#header-links {
			display: block;
			margin-top: 10px;
		}
		#header-links a {
			display: inline-block;
			width: 50px;
			height: 50px;
			line-height: 50px;
			vertical-align: middle;
			text-align: center;
			font-size: 25px;
			margin: 2px 2px;
			color: rgb(255, 255, 255);
			background-color: rgba(200, 200, 200, 0.75);
			border-radius: 100%;
			text-decoration: none;
			transition: background-color,color 0.5s,0.5s;
		}
		#header-links a:hover {
			background-color: rgb(0, 0, 0);
		}
		#header-links .botchallenge-l {
			color: rgb(200, 200, 200);
			background-color: transparent;
		}
		#header-links .botchallenge-l:hover {
			color: rgb(255, 255, 255);
			background-color: rgba(200, 200, 200, 0.75);
		}
		<?php
			foreach ($socialLinks as &$link) {
				if(!empty($link[3])) {
					echo "#header-links .fa-" . $link[0] . ":hover {";
					echo "background: " . $link[3] . ";";
					echo "} ";
				}
			}
		?>
		#content {
			display: block;
			padding: 50px;
			border-bottom: 1px solid rgb(100, 100, 100);
		}
		#content p {
			text-align: justify;
		}
		#footer {
			display: block;
			padding: 20px;
		}
		#footer-links {
			display: block;
			text-align: center;
		}
		#footer-links div {
			color: rgb(50, 119, 255);
			font-weight: bold;
		}
		#footer-links a {
			color: rgb(50, 119, 255);
			text-decoration: none;
			transition: color 0.5s;
		}
		#footer-links a:hover {
			color: rgb(0, 0, 0);
		}
		#footer-links span:first-child {
			margin-right: 2px;
		}
		#footer-about {
			display: block;
			margin-top:20px;
			text-align: right;
		}
	</style>
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
	<script type="text/javascript">
		function messageText(msg) {
			document.getElementById("messageWindow").innerHTML = msg;
			document.getElementById("messageWindow").style.display = "block";
			document.getElementById("botWindow").style.display = "none";
			$("#windowShadow").stop().fadeIn(1000);
		}
		function botChallenge() {
			document.getElementById("botWindow").style.display = "block";
			document.getElementById("messageWindow").style.display = "none";
			$("#windowShadow").stop().fadeIn(1000);
		}
		function closeWindow() {
			$("#windowShadow").stop().fadeOut(1000);
		}
		function submitBotChallenge() {
			document.getElementById("botWindow").style.display = "none";
			$.ajax({
				url: "?req=submit&datatype=json",
				cache: false,
				method: "POST",
				data: $("#botChallengeForm").serializeArray(),
				dataType: "text",
				timeout: 30000,
				success: function(reqResults) {
					try {
						var successResults = JSON.parse(reqResults);
						if (successResults.status == "success") {
							document.getElementById("header-links").innerHTML = successResults.data[0];
							document.getElementById("footer-links").innerHTML = successResults.data[1];
							document.getElementById("footer-about").innerHTML = successResults.data[2];
							$('#windowShadow').stop().fadeOut(1000);
						} else {
							alert("Try again.");
							$("#windowShadow").stop().fadeOut(1000);
						}
					} catch(e) {
						alert("Unable to gather the information");
						$("#windowShadow").stop().fadeOut(1000);
					}
				},
				error: function() {
					alert("Unable to gather the information.");
					$("#windowShadow").stop().fadeOut(1000);
				}
			});
		}
	</script>
</head>

<body style="overflow: auto;">
	<div id="main">
		<div id="windowShadow" style="display: none;">
			<div id="windowShadowEffect" onclick="closeWindow();"></div>
			<div id="botWindow" style="display: none;">
				<form action="?req=submit" method="post" id="botChallengeForm" onsubmit="submitBotChallenge(); return false;">
					<div class="cf-turnstile" data-sitekey="<?php echo $turnstilePublicToken; ?>" data-action="reveal-personal-data" data-theme="light" data-size="flexible" data-appearance="execute" data-response-field-name="cf-turnstile-response" data-callback="submitBotChallenge" data-refresh-timeout="auto" data-refresh-expired="auto" data-execution="render"></div>
				</form>
			</div>
			<div id="messageWindow" style="display: none;">
			</div>
		</div>
		<div id="header">
			<div id="header-wrapper">
				<div id="header-image">
				<img src="<?php echo $headerImage; ?>" onerror="document.getElementById('header-image').style.display = 'none';" alt="">
				</div>
				<div id="header-info">
					<div id="header-title">Matheus CR.</div>
					<div id="header-subtitle"><?php echo $subtitle; ?></div>
					<div id="header-links">
						<?php
							$privateLinks = false;
							foreach ($socialLinks as &$link) {
								if(empty($link[4]) or $link[4] == false) {
									if(is_string($link[2])){
										echo '<a href="' . $link[2] . '" target="_blank" title="' . $link[1] . '" class="fab fa-' . $link[0] . '"></a>';
									} else {
										echo '<a href="' . $link[2][0] . '" title="' . $link[1] . '" onclick="messageText(this.getAttribute(\'data-msg\')); return false;" data-msg="' . htmlentities($link[2][1]) . '" class="fab fa-' . $link[0] . '"></a>';
									}
								} else {
									$privateLinks = true;
								}
							}
							if($privateLinks) {
								echo '<a href="javascript:void(0);" onclick="botChallenge(); return false;" title="More" class="fas fa-caret-right botchallenge-l"></a>';
							}
						?>
					</div>
				</div>
			</div>
		</div>
		<?php
			if (!empty($content)) {
				echo '<div id="content">' . $content . '</div>';
			}
		?>
		<div id="footer">
			<div id="footer-links">
				<?php
					if (!empty($mail[0])) {
						echo '<div><a href="javascript:void(0);" onclick="botChallenge(); return false;"><span class="fas fa-envelope"></span>Email</a></div>';
					}
					if (!empty($phone[0])) {
						echo '<div><a href="javascript:void(0);" onclick="botChallenge(); return false;"><span class="fas fa-phone"></span>Call</a></div>';
					}
					if (!empty($location[0])) {
						echo '<div><a href="javascript:void(0);" onclick="botChallenge(); return false;"><span class="fas fa-comments"></span>Meet</a></div>';
					}
				?>
			</div>
			<div id="footer-about">
				<span><?php echo date("Y"); ?></span>
			</div>
		</div>
	</div>
	<div id="main-noscreen">
		<span>Your screen is too small to display this webpage.</span>
	</div>
</body>

</html>