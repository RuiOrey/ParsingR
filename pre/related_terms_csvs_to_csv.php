<?php 
//edit this path to correct csv path. TODO : change to argument
$csv_dir="./adjacent_terms/";

$files = array();
$lines = array();
$newlin="";
$id=0;
$sqlStr="INSERT INTO `related` (`id`, `keyword`, `related_keyword`, `score`) VALUES \n";
$sqlFinal=$sqlStr;
$newSql="
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";



CREATE TABLE IF NOT EXISTS `related` (
  `id` int(11) NOT NULL,
  `keyword` varchar(50) NOT NULL,
  `related_keyword` varchar(50) NOT NULL,
  `score` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `related`
--";
foreach (glob($csv_dir."*.csv") as $filename) {
    // Open the file

	if( $handle = @fopen( $filename, "r") )
	{
        $x = 0; // Start the line counter
        $newEntry="";
        

        // Cycle each line until end or reach the lines to return limit
        while(! feof( $handle ) )

        {           

        	$line = fgets($handle); // Read the line
        	$lessons[$filename][] = $line;            

        	if ($x!=0 && (! feof( $handle) ) )
        	{


        		$newEntry.=$id.",\"".basename($filename,".csv")."\"".",".$line;

        		if($id%300 == 0) {
        			if ($id != 0 )$newSql.= ";\n";
        			$newSql .= $sqlStr;
        		}
        		else $newSql .= ",\n";
        		$line = str_replace(array("\n", "\r"), '', $line);
        		 $newSql.= "('".$id."',\"".basename($filename,".csv")."\"".",".$line.")";

        		 //echo "('".$id."',\"".basename($filename,".csv")."\"".",".$line.")";

        		


        		$id++;
        	}
            $x++; // Increase the counter
        }
        $newlin.=$newEntry;
        echo basename($filename,".csv")."\n";
        //echo $newlin;
    }

    $fp = fopen("./related_words.csv","wb");
    fwrite($fp,$newlin);
    fclose($fp);

    file_put_contents("related.sql",$newSql);
}
?>