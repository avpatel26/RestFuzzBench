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
$filter->includeDirectory('/var/www/html/wp-includes/rest-api/');

$coverage=new CodeCoverage(
	(new Selector)->forLineCoverage($filter),
	$filter
);

$coverage->start($_SERVER['REQUEST_URI']);

function save_coverage()
{
	global $coverage;
	$coverage->stop();
	(new PhpReport)->process($coverage, '/home/ubuntu/log/'.$_ENV['OUTDIR'].'/'. bin2hex(random_bytes(16)) . '.cov');
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
