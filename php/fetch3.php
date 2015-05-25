<?php
set_time_limit (0);

$stopwords = array("cspanu", "a", "about", "above", "above", "across", "after", "afterwards", "again", "against", "all", "almost", "alone", "along", "already", "also","although","always","am","among", "amongst", "amoungst", "amount",  "an", "and", "another", "any","anyhow","anyone","anything","anyway", "anywhere", "are", "around", "as",  "at", "back","be","became", "because","become","becomes", "becoming", "been", "before", "beforehand", "behind", "being", "below", "beside", "besides", "between", "beyond", "bill", "both", "bottom","but", "by", "call", "can", "cannot", "cant", "co", "con", "could", "couldnt", "cry", "de", "describe", "detail", "do", "done", "down", "due", "during", "each", "eg", "eight", "either", "eleven","else", "elsewhere", "empty", "enough", "etc", "even", "ever", "every", "everyone", "everything", "everywhere", "except", "few", "fifteen", "fify", "fill", "find", "fire", "first", "five", "for", "former", "formerly", "forty", "found", "four", "from", "front", "full", "further", "get", "give", "go", "had", "has", "hasnt", "have", "he", "hence", "her", "here", "hereafter", "hereby", "herein", "hereupon", "hers", "herself", "him", "himself", "his", "how", "however", "hundred", "ie", "if", "in", "inc", "indeed", "interest", "into", "is", "it", "its", "itself", "keep", "last", "latter", "latterly", "least", "less", "ltd", "made", "many", "may", "me", "meanwhile", "might", "mill", "mine", "more", "moreover", "most", "mostly", "move", "much", "must", "my", "myself", "name", "namely", "neither", "never", "nevertheless", "next", "nine", "no", "nobody", "none", "noone", "nor", "not", "nothing", "now", "nowhere", "of", "off", "often", "on", "once", "one", "only", "onto", "or", "other", "others", "otherwise", "our", "ours", "ourselves", "out", "over", "own","part", "per", "perhaps", "please", "put", "rather", "re", "same", "see", "seem", "seemed", "seeming", "seems", "serious", "several", "she", "should", "show", "side", "since", "sincere", "six", "sixty", "so", "some", "somehow", "someone", "something", "sometime", "sometimes", "somewhere", "still", "such", "system", "take", "ten", "than", "that", "the", "their", "them", "themselves", "then", "thence", "there", "thereafter", "thereby", "therefore", "therein", "thereupon", "these", "they", "thickv", "thin", "third", "this", "those", "though", "three", "through", "throughout", "thru", "thus", "to", "together", "too", "top", "toward", "towards", "twelve", "twenty", "two", "un", "under", "until", "up", "upon", "us", "very", "via", "was", "we", "well", "were", "what", "whatever", "when", "whence", "whenever", "where", "whereafter", "whereas", "whereby", "wherein", "whereupon", "wherever", "whether", "which", "while", "whither", "who", "whoever", "whole", "whom", "whose", "why", "will", "with", "within", "without", "would", "yet", "you", "your", "yours", "yourself", "yourselves", "the");

$database = array();
$elements = array();
$words = array();

$last = microtime(true);


$cities_STR_ = "INSERT INTO `cities` (`city_id`, `name`, `abstract`, `valid_dest`, `gps1`, `gps2`) VALUES \n";
$words_STR_ = "INSERT INTO `words` (`word_id`, `word`) VALUES \n";
$conns_STR_ = "INSERT INTO `conn` (`conn_id`, `word`, `city`, `weight`, `times`) VALUES \n";

$cities_STR = $cities_STR_;
$words_STR = $words_STR_;
$conns_STR = $conns_STR_;

$citie_id = 1;
$wi = 1;
$cj = 1;

$servername = "localhost";
$username = "root";
$password = "1979Kayov";
// Create connection
$conn = new mysqli($servername, $username, $password);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
echo "Connected successfully\n";
$conn->select_db("words2");


function lessThen($var)
{
  return(strlen($var)<30);
}

function processFile($file, $name, $gps1, $gps2, $type, $quality, $father, $inv_less, $inv_region, $inv_big, $inv_quality) {

  GLOBAL $stopwords;
  GLOBAL $database;
  GLOBAL $conn;

  GLOBAL $cities_STR_;
  GLOBAL $cities_STR;
  GLOBAL $citie_id;

  GLOBAL $last;

  if($citie_id%200 == 0) {
    echo $citie_id." ";
    $new = microtime(true);
    echo ($new - $last)."\n";
    $last = $new;
  }

  
  //array_push($elements,$name);
  //echo $file."\n";

  //$des = file_get_contents($file);
  $des = $file;
  $clear = preg_replace('/[^a-zA-Z0-9\s]/', '', strip_tags(html_entity_decode(strtolower($des))));
  
  $list = str_word_count($clear, 2);
  
  $list2 = array_filter($list, "lessThen");
  
  // remove stopwords
  $result = array_diff($list2, $stopwords);
  

  //invalid destinations check
  if(count($result) <= 100) {
    $inv_less = 1;
  }
  $valid = 0;
  if(!$inv_less && !$inv_region && !$inv_big && !$inv_quality) {
    $valid = 1;
  }


  $count = array_count_values($result);
  
  asort($count);
  
  //print_r($count);
  $m = max($count);

  //$sql = "INSERT INTO cities VALUES('default','".htmlentities($name, ENT_QUOTES)."','','0','0','0')";
  
  if($citie_id%300 == 0) {
    $cities_STR .= ";\n";
    $cities_STR .= $cities_STR_;
  }

  if($citie_id != 1 && $citie_id%300 != 0) $cities_STR .= ",\n";


  $cities_STR .="('".$citie_id."','".htmlentities($name, ENT_QUOTES)."','','".$valid."','".$gps1."','".$gps2."', '".$type."', '".$quality."', '".$father."', '".$inv_less."', '".$inv_region."', '".$inv_big."', '".$inv_quality."')";

  //echo $sql."\n";
  //$res = $conn->query($sql);
  //$cId = $conn->insert_id;
  $cId = $citie_id;
  $citie_id++;
  

  foreach($count as $key => $item) {
    $arr = array((($item*100)/$m),$item,$cId);
    //print_r($arr);
    $database[$key][$name] = $arr;
    //echo $key." ".$name."\n";
    //$arr[$name] = ($item*100)/$m;
    //array_push($database[$key],$arr);
  }
}



//echo $argv[1]."\n";

$xml=simplexml_load_file("enwikivoyage-latest-pages-articles.xml") or die("Error: Cannot create object");
echo "XML loaded\n";


//$lines = file("rui.txt", FILE_IGNORE_NEW_LINES);

//$xml->doc[0]->url;
//$xml->doc[0]->abstract;

//20_40

$rangeS = 0;
$rangeE = 40000;
$i=0;
foreach($xml->page as $item) {
  if($i>=$rangeS) {
    
    $title = (string)$item->title;
    $text = $item->revision->text;


    $quality = -1;
    if(stripos($text, "{{vfd") !== false) {
      $quality = 0;
    }

    if(stripos($text, "{{stub") !== false) {
      $quality = 1;
    }

    if(stripos($text, "{{outline") !== false) {
      $quality = 2;
    }

    if(stripos($text, "{{usable") !== false) {
      $quality = 3;
    }

    if(stripos($text, "{{guide") !== false) {
      $quality = 4;
    }

    if(stripos($text, "{{star") !== false) {
      $quality = 5;
    }

    if($quality == -1) continue;
     
    $type = -1;
    if(stripos($text, "city}}") !== false) {
      $type = 1;
    }
  
    if(stripos($text, "country}}") !== false) {
      $type = 2;
    }

    if(stripos($text, "region}}") !== false) {
      $type = 3;
    }

    if($type == -1) continue;
    
    $pattern = "/\{[gG]eo\\|(.*?)\\|(.*?)[\\}\\|]/";
    preg_match($pattern, $text, $matches);
    if(!empty($matches[1]) && !empty($matches[2])) {
      $gps1 = $matches[1];
      $gps2 = $matches[2];
    } else {
      $gps1 = 0;
      $gps2 = 0;
    }
    

    $pattern = "/[iI]s[pP]art[oO]f\\|(.*?)\\}/";
    preg_match($pattern, $text, $matches);
    if(!empty($matches[1])) {
      $father = $matches[1];
    } else {
      $father = '';
    }
    

    //echo $i." ".$item->title."\n";
    
    
    $pos = strpos($title, ":");
    if ($pos == true) {
      continue;
    } else {
      //echo $i." ".$item->title."\n";
    }
    

    //invalid destinations check
    $inv_less = 0;$inv_region = 0;$inv_quality = 0;
    $inv_big = 1;
    if($quality <= 1) $inv_quality = 1;
    if( $type == 3) $inv_region = 1;
    

    $pattern1 = "/=[gG]o [nN]ext=/";
    $pattern2 = "/=[Cc]ities=/";
    $pattern3 = "/=[oO]ther [dD]estinations=/";
    preg_match($pattern1, $text, $matches1);
    preg_match($pattern2, $text, $matches2);
    preg_match($pattern3, $text, $matches3);

    if( $type!=2 || (!empty($matches1[1]) && empty($matches2[1]) && empty($matches3[1]))) {
      $inv_big = 0;
    }

    //$sql = "SELECT city_id FROM cities WHERE name = '".htmlentities($title, ENT_QUOTES)."'";
    //$result = $conn->query($sql);
    //if(mysqli_num_rows($result) == 0 || 1==1) {
    //echo $i." ".$item->title."\n";
    if($i%1000==0 && $i!=0) {
      //$cities_STR .= ";\n";
      echo "Matrix generated\n";
      generate();
      $database = array();
    }
    processFile($text, $title, $gps1, $gps2, $type, $quality, $father, $inv_less, $inv_region, $inv_big, $inv_quality);
    
    $i++;
    //}
    
    //echo $i;
  }
  if($i==$rangeE) break;
}

//exit();

//print_r($database);
//exit();

//generate();

function generate() {
  
  GLOBAL $database;
  GLOBAL $words;

  GLOBAL $cities_STR_;
  GLOBAL $cities_STR;
  GLOBAL $words_STR_;
  GLOBAL $words_STR;
  GLOBAL $conns_STR;
  GLOBAL $conns_STR_;

  GLOBAL $wi;
  GLOBAL $cj;
  $list = array();
  $total = count($database);

  $per = 0;
  foreach($database as $word => $item2) {
    echo round((($per*100)/$total),2)."%\r";
    $per++;
    /*
      $sql = "SELECT word_id FROM words WHERE word = '".htmlentities($word, ENT_QUOTES)."'";
      $result = $conn->query($sql);
      if(mysqli_num_rows($result) == 0) {
      $result = $conn->query("INSERT INTO words VALUES('default','".htmlentities($word, ENT_QUOTES)."')");
      $wId = $conn->insert_id;
      } else {
      $row = $result->fetch_assoc();
      $wId = $row['word_id'];
      }
    */
    

    if(!isset($words[$word])) {

      if($wi%300 == 0) {
	$words_STR .= ";\n";
	$words_STR .= $words_STR_;
      }
      if($wi != 1 && $wi%300 != 0) $words_STR .= ",\n";
      
      $words_STR .= "('".$wi."','".htmlentities($word, ENT_QUOTES)."')";
      $words[$word] = $wi;
      $wId = $wi;
      $wi++;
    } else {
      $wId = $words[$word];
    }
    
    foreach($database[$word] as $key => $item) {
      
      $cId = $item[2];
      
      
      if($cj%300 == 0) {
	$conns_STR .= ";\n";
	$conns_STR .= $conns_STR_;
      }
      if($cj != 1 && $cj%300 != 0) $conns_STR .= ",\n";
      
      $conns_STR .= "('".$cj."','".$wId."','".$cId."',".$item[0].",".$item[1].")";
      $cj++;
    }
  }
 
  
}

echo "Matrix generated\n";
generate();

$cities_STR .= ";\n";
$words_STR .=";\n";
$conns_STR .= ";\n";

file_put_contents("out1.txt",$cities_STR.$words_STR.$conns_STR);

/*
echo $cities_STR;
echo $words_STR;
echo $conns_STR;
*/
