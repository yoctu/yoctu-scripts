#!/usr/bin/env php
<?php 

/*
    PHP Shell gzinflate/deflate (Why does php need some custom things :()
*/

$opts                   = "M:f:S:sh";
$softname               = $argv[0];
$softname               = preg_replace('/.*\//', '', $softname);
$usage                  = "USAGE: $softname [$opts]";
$help                   = "

    $usage

    Options:
        -M      Method (deflate/inflate)
        -s      Read from Stdin
        -f      From File content
        -S      String
        -h      Help

";


function _quit($retCode, $msg){
    echo "$msg\n";
    exit($retCode);
};

function fromStdin(){
    if (posix_isatty(STDIN)){
        _quit(2,"No Stdin data!");
    };

    return file_get_contents("php://stdin");
};

function fromFile($file){
    if (!file_exists($file)) {
        _quit(2, "File ($file) does not exists!");
    };

    return file_get_contents($file);
};

function fromString($string){
    return $string;
}

$options = getopt($opts);

if(isset($options["h"]) || !is_array($options))
{
    _quit(0,$help);
};

foreach($options as $keyOpt => $valueOpt)
{
    switch($keyOpt){
        case 'M':
            $method = $options["M"];
            break;
	case 's':
	    $from = "stdin";
	    break;
	case 'f':
	    $from = "file";
            $file = $options["f"];
	    break;
        case 'S':
            $from = "string";
            $string = $options["S"];
            break;
        default:
            _quit(2,"$help");
            break;
    }
}

isset($from) or $from = 'stdin';

isset($method) or $method = 'deflate';

if ($method == "deflate" or $method == "inflate") {
    $flateMethod = "gz$method";
};

if (!isset($flateMethod)){
    _quit(2,$help);
};

//_quit(1,fromFile($file));

switch($from){
    case 'stdin':
        echo $flateMethod(fromStdin());
        break;
    case 'file':
        echo $flateMethod(fromFile($file));
        break;
    case 'argv':
        echo $flateMethod(fromString($string));
        break;
    default:
        echo $flateMethod(fromStdin());
        break;
}

