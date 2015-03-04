<html>
<head>
	<style media="screen" type="text/css">
		body {
			background-image: url('http://www.tela-botanica.org/reseau/maintenance/fond.jpg');
			background-repeat: no-repeat;
			background-position: fixed;
			background-size: cover;
		}
		.bloc-centre {
			position: absolute;
			top:0;
			bottom: 0;
			left: 0;
			right: 0;
			width: 700px;
			height: 350px;
		    margin: auto;
			padding-top: 20px;
			text-align: center;
			border: solid #daf0da 1px;
			border-radius : 10px;
		}
		.bloc-centre h1 {
			margin-bottom: 0;
			font-family: Trebuchet MS, Calibri, Verdana, Nimbus, Times, Arial;
			font-size: 1.7em;
			color: #202020;
		}
		.bloc-centre h2 {
			margin-top: 10px;
			margin-bottom: 0;
			font-family: Trebuchet MS, Calibri, Verdana, Nimbus, Times, Arial;
			font-size: 1.3em;
			color: #808080;
		}
		.bloc-centre h3 {
			margin-top: 5px;
			margin-bottom: 0;
			font-family: Trebuchet MS, Calibri, Verdana, Nimbus, Times, Arial;
			font-size: 1em;
			font-weight: normal;
			font-style: italic;
			color: #a0a0a0;
		}
		.bloc-centre h3 strong {
			font-weight: bold;
			font-style: normal;
			color: #505050;
		}
	</style>
</head>
<body>
	<?php
		// gestion des dates : fournir une URL du type maintenance.php?debut=2015-03-04 10:15&fin=2015-03-06 18:00
		$debut = null;
		$fin = null;
		// paramètres de l'URL
		if (isset($_GET['debut']) && preg_match('/(\d{4})-(\d{2})-(\d{2})[ _](\d{2}):(\d{2})/', $_GET['debut'])) {
			$debut = strtotime(str_replace('_', ' ', $_GET['debut']));
		}
		if (isset($_GET['fin']) && preg_match('/(\d{4})-(\d{2})-(\d{2})[ _](\d{2}):(\d{2})/', $_GET['fin'])) {
			$fin = strtotime(str_replace('_', ' ', $_GET['fin']));
		}
		// donne le jour de la semaine en français
		function jour($date) {
			$j = date("N", $date);
			$jours = array('lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche');
			return $jours[$j-1];
		}
	?>
	<div class="bloc-centre">
		<img src="http://www.tela-botanica.org/reseau/maintenance/logo-petit.png" alt="Tela-Botanica"/>
		<h1>Cette application est en cours de maintenance</h1>
		<?php if ($debut != null || $fin != null): ?>
			<?php if ($debut == null): ?>
				<h3>jusqu'au <?= jour($fin) ?> <strong><?= date("d/m/Y", $fin) ?></strong> à <strong><?= date("H:i", $fin) ?></strong></h3>
			<?php elseif ($fin == null): ?>
				<h3>à partir du <?= jour($debut) ?> <strong><?= date("d/m/Y", $debut) ?></strong> à <strong><?= date("H:i", $debut) ?></strong></h3>
			<?php elseif (date("Y-m-d", $debut) == date("Y-m-d", $fin)): ?>
				<h3>le <?= jour($debut) ?> <strong><?= date("d/m/Y", $debut) ?></strong> de <strong><?= date("H:i", $debut) ?></strong> à <strong><?= date("H:i", $fin) ?></strong></h3>
			<?php else: ?>
				<h3>du <?= jour($debut) ?> <strong><?= date("d/m/Y", $debut) ?></strong> à <strong><?= date("H:i", $debut) ?></strong> au <?= jour($fin) ?> <strong><?= date("d/m/Y", $fin) ?></strong> à <strong><?= date("H:i", $fin) ?></strong></h3>
			<?php endif; ?>
		<?php endif; ?>
		<h2>Veuillez nous excuser pour la gêne occasionnée</h2>
	</div>
</body>
</html>
