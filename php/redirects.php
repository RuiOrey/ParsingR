<?php
set_time_limit (0);

$servername = "localhost";
$username = "root";
$password = "1979Kayov";
// Create connection
$conn = new mysqli($servername, $username, $password);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
//echo "Connected successfully\n";
$conn->select_db("t");


// XML
$xml=simplexml_load_file("enwikivoyage-latest-pages-articles.xml") or die("Error: Cannot create object");
//echo "XML loaded\n";

$i=1;
foreach($xml->page as $item) {

  
  $title = (string)$item->title;
  $text = $item->revision->text;

  if(stripos($text, "REDIRECT") !== false) {
    
    $pattern = "/\\[\\[(.*?)\\]\\]/";
    preg_match($pattern, $text, $matches);
    if(!empty($matches[1])) {
      
      $sql = "INSERT INTO redirects VALUES('".$i."','".$title."','".$matches[1]."')";
      $res = $conn->query($sql);
      echo $sql."\n";

      //echo $i.";".$title.";".$matches[1]."\n";
      $i++;
    }
   

  }
  

  /*
  $sql = "SELECT city_id FROM cities WHERE name = '".htmlentities($title, ENT_QUOTES)."'";
  $result = $conn->query($sql);
  if(mysqli_num_rows($result) > 0) {
    $row = $result->fetch_assoc();
    $sql = "UPDATE cities SET father = '".$father."' WHERE city_id = '".$row['city_id']."'";
    $res = $conn->query($sql);
    //echo $sql."\n";
    //echo $title." -> ".$father."\n";
  }
  */
  
}