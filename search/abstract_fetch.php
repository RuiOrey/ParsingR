<?php
set_time_limit (0);

$servername = "localhost";
$username = "words2_user";
$password = "teamdorey69";
// Create connection
$conn = new mysqli($servername, $username, $password);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
echo "Connected successfully";
$conn->select_db("words2");


$xml=simplexml_load_file("enwikivoyage-latest-abstract.xml") or die("Error: Cannot create object");

//$xml->doc[0]->url;
//$xml->doc[0]->abstract;

//20_40


$rangeS = 0;
$rangeE = 20000;
$i=0;
foreach($xml->doc as $item) {
  if($i>=$rangeS) {
    $titleA = explode(": ", $item->title);
    $title = $titleA[1];
    //echo $title."\n";
    //echo $item->url."\n";

    $sql = "SELECT city_id FROM cities WHERE name = '".htmlentities($title, ENT_QUOTES)."'";
    $result = $conn->query($sql);
    if(mysqli_num_rows($result) > 0) {
      $row = $result->fetch_assoc();
      $res = $conn->query("UPDATE cities SET abstract = '".htmlentities($item->abstract, ENT_QUOTES)."' WHERE city_id = '".$row['city_id']."'");
    }
  }
  $i++;
  if($i==$rangeE) break;
}

