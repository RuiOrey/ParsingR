<?php
set_time_limit (0);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Where to go?</title>

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">

<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

<script src="d3-cloud-master/lib/d3/d3.js"></script>
<script src="d3-cloud-master/d3.layout.cloud.js"></script>

</head>

<style>

  .abstract {
  color: rgb(84, 84, 84);
  font-family: arial, sans-serif;
  font-size: 13px;
  font-weight: normal;
  height: auto;
  line-height: 20.2222232818604px;
  text-align: left;
  visibility: visible;
  width: auto;
}

</style>


<body>

<?php
$database = array();
$ok = false;
$m = 0;
$wlist = array();

function findWord($word) {
  GLOBAL $database;
  GLOBAL $ok;
  GLOBAL $m;
  GLOBAL $wlist;
  GLOBAL $conn;
  


  $mwe = 0;
  $mwo = 0;
  $ok = true;

  unset($temp_database);
  $temp_database = array();

  $sql = "SELECT word_id FROM words WHERE word = '".htmlentities($word, ENT_QUOTES)."'";
  $result = $conn->query($sql);
  $row = $result->fetch_assoc();
  
  $sql = "SELECT co.weight, co.times, ci.name, ci.abstract, ci.gps1, ci.gps2, ci.valid_dest FROM conn co ,cities ci WHERE word = '".$row['word_id']."' AND co.city = ci.city_id";
  $result = $conn->query($sql);
  while($row = $result->fetch_assoc()) {

    if($row['weight']>$mwe) $mwe = $row['weight'];
    if($row['times']>$mwo) $mwo = $row['times'];

    //DEBUG
    /*
    if($row['name'] == "Boracay" || $row['name'] == "Mykonos") {
    echo $row['name']." => ".$row['weight']." ".$row['times']."<br>";
    }
    */
    
    $temp_database[$row['name']] = array($row['weight'], $row['times'], $row['abstract'], $row['gps1'], $row['gps2'], $row['valid_dest']);
  }
  
  foreach($temp_database as $key => $item) {
    $database[$key][0] += ($item[0]*100)/$mwe;
    $database[$key][1] += ($item[1]*100)/$mwo;
    $database[$key][2] = $item[2];
    $database[$key][3] = $item[3];
    $database[$key][4] = $item[4];
    $database[$key][5] = $item[5];
  }


  /*
  $ok = true;
  $sql = "SELECT word_id FROM words WHERE word = '".htmlentities($word, ENT_QUOTES)."'";
  $result = $conn->query($sql);
  $row = $result->fetch_assoc();
  
  $sql = "SELECT co.weight, co.times, ci.name, ci.abstract FROM conn co ,cities ci WHERE word = '".$row['word_id']."' AND co.city = ci.city_id";
  $result = $conn->query($sql);
  while($row = $result->fetch_assoc()) {
    $database[$row['name']] = array($row['weight'], $row['times'], $row['abstract']);
  }
   
  foreach($database as $key => $item) {
    if($item[1] > $m) $m = $item[1];
  }
  */
}


function findWord2($word1, $word2) {
  GLOBAL $database;
  GLOBAL $ok;
  GLOBAL $m;
  GLOBAL $wlist;
  GLOBAL $conn;
  
  $mwe = 0;
  $mwo = 0;
  $ok = true;

  unset($temp_database);
  $temp_database = array();

  $sql = "SELECT word_id FROM words WHERE word = '".htmlentities($word1, ENT_QUOTES)."'";
  $result = $conn->query($sql);
  $row = $result->fetch_assoc();
  
  $sql = "SELECT co.weight, co.times, ci.name, ci.abstract, ci.gps1, ci.gps2, ci.valid_dest  FROM conn co ,cities ci WHERE word = '".$row['word_id']."' AND co.city = ci.city_id";
  $result = $conn->query($sql);
  while($row = $result->fetch_assoc()) {

    if($row['weight']>$mwe) $mwe = $row['weight'];
    if($row['times']>$mwo) $mwo = $row['times'];

    //DEBUG
    /*
    if($row['name'] == "Boracay" || $row['name'] == "Mykonos") {
    echo $row['name']." => ".$row['weight']." ".$row['times']."<br>";
    }
    */
    
    $temp_database[$row['name']] = array($row['weight'], $row['times'], $row['abstract'], $row['gps1'], $row['gps2'],$row['valid_dest']);
  }
  
  foreach($temp_database as $key => $item) {
    $database[$key][0] = ($item[0]*100)/$mwe;
    $database[$key][1] = ($item[1]*100)/$mwo;
    $database[$key][2] = $item[2];
    $database[$key][3] = $item[3];
    $database[$key][4] = $item[4];
    $database[$key][5] = $item[5];
  }



  // WORD 2
  $mwe = 0;
  $mwo = 0;
  unset($temp_database);
  $temp_database = array();

  $sql = "SELECT word_id FROM words WHERE word = '".htmlentities($word2, ENT_QUOTES)."'";
  $result = $conn->query($sql);
  $row = $result->fetch_assoc();
  
  $sql = "SELECT co.weight, co.times, ci.name, ci.abstract, ci.gps1, ci.gps2, ci.valid_dest FROM conn co ,cities ci WHERE word = '".$row['word_id']."' AND co.city = ci.city_id";
  $result = $conn->query($sql);
  while($row = $result->fetch_assoc()) {

    if($row['weight']>$mwe) $mwe = $row['weight'];
    if($row['times']>$mwo) $mwo = $row['times'];

    //DEBUG
    /*
    if($row['name'] == "Boracay" || $row['name'] == "Mykonos") {
    echo $row['name']." => ".$row['weight']." ".$row['times']."<br>";
    }
    */
    
    $temp_database[$row['name']] = array($row['weight'], $row['times'], $row['abstract'], $row['gps1'], $row['gps2'], $row['valid_dest'] );
  }
  
  foreach($temp_database as $key => $item) {
    $database[$key][0] *= ($item[0]*100)/$mwe;
    $database[$key][1] *= ($item[1]*100)/$mwo;
    $database[$key][2] = $item[2];
    $database[$key][3] = $item[3];
    $database[$key][4] = $item[4];
    $database[$key][5] = $item[5];
  }




}


if($_POST['action'] == 'submit') {

  $servername = "localhost";
  $username = "words2_user";
  $password = "teamdorey69";
  // Create connection
  $conn = new mysqli($servername, $username, $password);
  // Check connection
  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  } 
  //echo "Connected successfully";
  $conn->select_db("words2");
  
  //$database = json_decode(file_get_contents('db.json'), true);
 
  $pieces = explode(" ", $_POST['keywords']);
  $num_words = count($pieces);

  if(count($pieces) == 1) {
    findWord($_POST['keywords']);
  } else if(count($pieces) > 1) {
    findWord2($pieces[0], $pieces[1]);
  }
  
}
?>


<div class="container-fluid" >
  <div class="row" style='height:60px;background-color: #f1f1f1;border-bottom: 1px solid #666;border-color: #e5e5e5;'>


<form class="form-inline" method='post' style='padding-top:12px;padding-left:20px;'>

<img src='http://www.moontrip.pt/css/moontrip.png' height='35' class=''>

    <div class="form-group">
    <label for="exampleInputEmail1">Search</label>
   <input type="text" name='keywords' class="form-control" id="exampleInputEmail1" placeholder="Add your interests and let us do the rest" style='width:560px;'>
  <input type='hidden' name='action' value='submit'>
  </div>


<button type="submit" class="btn btn-default btn-md">
  <span class="glyphicon glyphicon-search" aria-hidden="true"></span>
</button>

</form>

  </div>
</div>


<div class='container' style='margin-top:45px;'>

  <div class="row">
   <div class="col-md-4">
   <!-- Search Results -->

<?php
  if ($ok == true) {

    echo "<div style='font-family: arial, sans-serif;font-size: 13px;'>Best places in the world for <b> '".$_POST['keywords']."' </b>- About ".count($database)." results.</div>";

    $list = array();
    $word = $_POST['keywords'];
    foreach($database as $key => $item) {
      //echo "{text: \"".$key."\", size: ".(($item[0]*0.3) + ((($item[1]*100)/$m)*0.7) )."}";
      $list[$key] = (($item[0]*0.3) + ($item[1]*0.7) )/$num_words;
      if(log($list[$key]) > $m) $m = log($list[$key]);
    }
    
    asort($list);
    $preserved = array_reverse($list, true);

    $c=0;
    foreach($preserved as $key => $item) {
    
if($database[$key][3]!='0' && $database[$key][4]!='0') {
    $gps = "<span style='font-size:12px;'>Latitude: ".$database[$key][3]." - Longitude: ".$database[$key][4]."  </span><a target='_blank' href='https://www.google.com/maps?q=".$database[$key][3].",".$database[$key][4]."&z=15'><img src='https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Map_mag.png/25px-Map_mag.png' border='0'></a> ";
} else {
  $gps = "";
}

      echo "<div style='padding-bottom:10px;'>";
      echo "<div><h2 style='margin-bottom:0px;'><a href='https://en.wikivoyage.org/wiki/".$key."' target='_blank'>".$key."</a> - <span style='font-size:16px;'>".round($item,2)."</span> <br>".$gps."</h2></div>";
      $var = str_word_count($database[$key][2], 1);
	if ($database[$key][5]==1)
	echo "<p style='color:green'>CLASSIFIED AS DESTINATION</p>";
	else
	echo "<p style='color:red'>NOT CLASSIFIED AS DESTINATION</p>";
      echo "<div class='abstract'>".implode(" ",array_splice($var, 0, 26))."...</div>";
      echo "<div style=''><a href='http://www.booking.com/".$key."-Hotels' style='color:#FF6633;' target='_blank'>Booking</a> - ";
      echo "<a href='https://www.google.pt/maps/place/".$key."' style='color:red;' target='_blank'>Google Maps</a> - ";

      echo "<a href='http://www.tripadvisor.com/".$key."' style='color:#6BA454;' target='_blank'>TripAdvisor</a> - ";
echo "<a href='http://www.ryanair.com/en/flights-to-".$key."' style='color:#9900CC;' target='_blank'>Flights</a></div>";



      echo "</div>";
      $c++;
      if($c==50) break;
    }
    

  }
?>
   
   </div>
   <div class="col-md-4" style='text-align:center;'>

<!--<img src='http://freeqi.poooch.net/img/teste_memoria.gif'>-->

   </div>
   <div class="col-md-4" id="cloud">

<script>
  var fill = d3.scale.category20();

  d3.layout.cloud().size([390, 600])
.words([
<?php
	if ($ok == true) {
	  $word = $_POST['keywords'];
	  $i=0;
	  foreach($preserved as $key => $item) {
	    if($i!=0) echo ",";
	    echo "{text: \"".$key."\", size: ".((log($item)/$m)*50)."}";
	    $i++;
	    if($i==50) break;
	  }
	}
?>
])
      .padding(5)
      .rotate(function() { return ~~(Math.random() * 2) * 90; })
      .font("Impact")
      .fontSize(function(d) { return d.size; })
      .on("end", draw)
      .start();

  function draw(words) {
    d3.select("#cloud").append("svg")
        .attr("width", 390)
        .attr("height", 600)
      .append("g")
        .attr("transform", "translate(195,300)")
      .selectAll("text")
        .data(words)
      .enter().append("text")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("font-family", "Impact")
        .style("fill", function(d, i) { return fill(i); })
        .attr("text-anchor", "middle")
        .attr("transform", function(d) {
	    return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
        })
        .text(function(d) { return d.text; });
  }
</script>

  </div>
  
  </div>

</div>

</body>
</html>