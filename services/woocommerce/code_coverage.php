<?php

require 'vendor/autoload.php';

use SebastianBergmann\CodeCoverage\Filter;
use SebastianBergmann\CodeCoverage\Driver\Selector;
use SebastianBergmann\CodeCoverage\CodeCoverage;
use SebastianBergmann\CodeCoverage\Report\PHP as PhpReport;

$dotenv = Dotenv\Dotenv::createImmutable(__DIR__,'.env');
$dotenv->load();

$skip_count = (int)$_ENV['SKIPCOUNT'];
$run_count = (int)$_ENV['RUNCOUNT'];

$old='RUNCOUNT='.$run_count;

if($skip_count==$run_count){

$filter = new Filter;
$filter->includeDirectory('/var/www/html/wp-content/plugins/woocommerce/includes/rest-api/Controllers/');

$coverage=new CodeCoverage(
	(new Selector)->forLineAndPathCoverage($filter),
	$filter
);

$coverage->start($_SERVER['REQUEST_URI']);

function save_coverage()
{
	global $coverage;
	$coverage->stop();
	(new PhpReport)->process($coverage, '/home/ubuntu/log/'.$_ENV['OUTDIR'].'/'. bin2hex(random_bytes(16)) . '.cov');
	 $merge='php /home/ubuntu/phpcov.phar merge --text /home/ubuntu/log/coverage.txt /home/ubuntu/log/'.$_ENV['OUTDIR'].'/ 2>&1';
        shell_exec($merge);

        $time=$_SERVER['REQUEST_TIME'];
        $file = file("/home/ubuntu/log/coverage.txt");

        $branch = $file[9];
        $branch = trim($branch);
        $branch = explode(" ",$branch);
        $branch_per = substr($branch[4],0,-1);
        $exp="/\([0-9]+\//";
        preg_match($exp,$branch[5],$x);
        $branch_abs = substr($x[0],1,-1);

        $line = $file[10];
        $line = trim($line);
        $line = explode(" ",$line);
        $l_per= substr($line[3],0,-1);
        $exp="/\([0-9]+\//";
        preg_match($exp,$line[4],$x);
        $l_abs=substr($x[0],1,-1);
	$list=array($time,$l_per,$l_abs,$branch_per,$branch_abs);
	
        $fp=fopen('/home/ubuntu/covfile','a');
	fputcsv($fp,$list);
        fclose($fp);
        shell_exec("rm home/ubuntu/log/coverage.txt");
}

register_shutdown_function('save_coverage');
}

$run_count = $run_count - 1;
if($run_count==-1){
	$run_count = $skip_count;
}

$replace='RUNCOUNT='.$run_count;
$file = file_get_contents('/home/ubuntu/.env');
$file = str_replace($old,$replace,$file);
file_put_contents('/home/ubuntu/.env',$file);

?>
