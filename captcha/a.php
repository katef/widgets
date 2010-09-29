<!--
before/after
above/below
inside/outside
big/small
-->

<style>
img { height: 70px; margin: 0;
		border-radius: 15px;
	min-width: 50px;
}
ol { margin-top: 5em; padding: 0; margin: 0; margin-left: 100px; }
hr { clear: left; }
li { display: block; float: left; height: 70px; padding: 10px 5px; margin: 0 5px; }
h2 { display: block; height: 30px; clear: left; width: 800px;
	background-color: aliceblue; margin: 0; padding: 0; font-size: 12pt; font-weight: normal; }
li { border: solid 1px black; cursor: hand; }
.toggle-a {
		border: solid 1px red; background-color: pink;
		border-color: red;
	}
li.toggle-a {
		border-top: none;
		border-bottom-left-radius: 15px;
		border-bottom-right-radius: 15px;
		margin-bottom: 5px;
		padding-bottom: 5px;
		padding-top: 1px;
		margin-top: -1px;
	}
.toggle-b {
		border: solid 1px blue; background-color: aliceblue;
		border-color: blue;
	}
li.toggle-b {
		border-bottom: none;
		border-top-left-radius: 15px;
		border-top-right-radius: 15px;
		margin-top: 5px;
		padding-top: 5px;
		padding-bottom: 1px;
		margin-bottom: -1px;
	}
</style>
<script>
function x(e) {
	e.setAttribute('class', (e.getAttribute('class') == 'toggle-a') ? 'toggle-b' : 'toggle-a');
}
</script>
<?php


/** 
 * Send a GET requst using cURL 
 * @param string $url to request 
 * @param array $get values to send 
 * @param array $options for cURL 
 * @return string 
 */ 
function curl_get($url, array $get = array(), array $options = array()) 
{    
    $defaults = array( 
        CURLOPT_URL            => sprintf("%s%c%s",
	                          	$url,
	                                strpos($url, '?') === FALSE ? '?' : '',
	                                http_build_query($get)), 
        CURLOPT_HEADER         => 0, 
        CURLOPT_RETURNTRANSFER => TRUE, 
        CURLOPT_TIMEOUT        => 4 
    ); 
    
    $ch = curl_init(); 
    curl_setopt_array($ch, ($options + $defaults)); 
    if(! $result = curl_exec($ch)) { 
        trigger_error(curl_error($ch)); 
    } 
    curl_close($ch); 
    return $result; 
} 




/*
"broken window" is unclear; before window looks good
bricks are good
flying bird not good
tree/stump works well
bathroom/sky is good except sunny sky gets a picture of a tshirt
wave/soil is good
idea: roast food versus living animal
water is not clear
idea: people vs. manequins
animal vs. vegetable
animate/inanimate
liquid/solid

TODO: "after" has to be able to be caused by the previous image. likewise predator/prey
TODO: show synonyms for big/huge/large/humongous/bigger etc
*/
/* TODO: check all these give the images i want */
/* TODO: multiple words for "big" etc; find synonyms? */
$things = array(
	array(
		"big"   => array("big house", "wild elephant", "skyscraper", "planet earth", "mountain scenery"),
		"small" => array("matchbox matches", "sugar cube", "cute mouse", "dainty earring", "coin cent", "clothes button", "garden snail")
	),
	array(
		"inside"  => array("bed bedroom", "kitchen", "bathroom", "refridgerator"),
		"outside" => array("tree", "soaring bird", "fluffy clouds", "cloudy sky", "grassy field")
	),
/*
	array(
		"young" => array("cute baby", "cute kitten", "cute baby duck", "sapling"),
		"old"   => array("old aged person", "sepia victorian portrait", "penny farthing bike", "ancient tree")
	),
*/
	array(
		"before" => array("oak tree"),
		"after"  => array("tree stump")
	),
/*
	array(
		"before" => array("crockery"),
		"after"  => array("broken plate")
	),
*/
	array(
		"human"  => array("baby in duck suit"),
		"animal" => array("cute baby duck")
	),
	array(
		"above" => array("cloudy sky", "soaring bird", "flying aeroplane"),
		"below" => array("grass", "earthworm", "mole animal", "undersea", "underground tunnel")
	),
	array(
		"edible"   => array("grilled fish", "roast beef", "green apple", "red apple", "carrot vegetable"),
		"inedible" => array("brick wall", "paint tin", "fountain pen", "folded newspaper")
	),
	array(
		"wet" => array("water splash", "sea wave", "jumping whale", "waterfall"),
		"dry" => array("dry soil")
	),
	array(
		"artificial" => array("skyscraper", "robot toy"),
		"natural"    => array("oak tree", "waterfall", "volcano", "stormy weather", "tiger running")
	),
	array(
		"hot"  => array("gas flame", "fire flame"),
		"cold" => array("antarctic ice")
	),
	array(
		"predator" => array("tiger running", "lion running"),
		"prey"     => array("gazelle running", "springbok jumping", "zebra wild running")
	),
	array(
		"predator" => array("shark swimming"),
		"prey"     => array("school fish")
	),
	array(
		"inanimate" => array("toy lion"),
		"animate"   => array("lion running")
	),
	array(
		"inanimate" => array("toy plastic dolphin"),
		"animate"   => array("dolphin jumping")
	),
/*
	array(
		"liquid" => array("glass of milk", "glass of coke", "pouring molten steel"),
		"solid"  => array("ice cubes", "gold ingot")
	),
	array(
		"fake" => array("monopoly money"),
		"real" => array("money notes")
	),
*/
);


function findthings($thing) {
	$o = array();

	/* TODO: userip */
	/* TODO: key */
	/* TODO: use array for get parameters */
	/* TODO: rsz=8 max */
	$x = curl_get("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&safe=active&imgsz=medium&as_filetype=jpg&imgtype=photo&rsz=8&q=" . urlencode($thing));

	$j = json_decode($x);

	$r = $j->responseData->results;
#	echo '<ol>';
	foreach ($r as $a) {
		$o[] = $a->url;
#		echo '<li><img height="75" src="' . $a->url . '"/>';
	}
#	echo '</ol>';

	return $o;
}

$o = array();
$dirs = array();

foreach ($things[array_rand($things)] as $dir => $items) {
	$item = array_rand($items);

#	echo sprintf("<h2>%s (%s)</h2>", $dir, $items[$item]);
#	echo sprintf("<h2>%s</h2>", $dir);
	$o = array_merge($o, findthings($items[$item]));
	$dirs[] = $dir;
}

shuffle($o);
$o = array_slice($o, 0, 5);

/* TODO: output to XML and use mod_kxslt */

$d = array_rand($dirs);

echo sprintf('<h2 class="toggle-a">%s</h2>', $dirs[$d]);
echo '<ol>';
foreach ($o as $a) {
	echo '<li class="toggle-b" onclick="x(this)"><img height="75" src="' . $a . '"/>';
}
echo '</ol>';
echo sprintf('<h2 class="toggle-b">%s</h2>', $dirs[1 - $d]);

?>

