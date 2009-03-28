#!/usr/bin/perl

use lib qw(blib/lib blib/arch);
use strict;

use Audio::Scan;
use Benchmark qw(cmpthese);

my $file = shift || die "Usage: $0 [file]\n\n";

if ( $file =~ /\.mp(2|3)$/i ) {
  require MP3::Info;
  
  cmpthese( -5, {
    mp3_pp => sub {
      MP3::Info::get_mp3info($file);
      MP3::Info::get_mp3tag($file);
    },
    mp3_c  => sub {
      Audio::Scan->scan($file);
    },
  } );
}
elsif ( $file =~ /\.ogg$/i ) {
  require Ogg::Vorbis::Header::PurePerl;
  
  cmpthese( -5, {
    ogg_pp => sub {
      my $ogg = Ogg::Vorbis::Header::PurePerl->new($file);
      $ogg->info;
      $ogg->comment_tags;
    },
    ogg_c  => sub {
      Audio::Scan->scan($file);
    },
  } );
}
elsif ( $file =~ /\.fla?c$/i ) {
  require Audio::FLAC::Header;
  
  cmpthese( -5, {
    flac_pp => sub {
      Audio::FLAC::Header->new($file)
    },
    flac_c  => sub {
      Audio::Scan->scan($file);
    },
  } );
}
else {
  die "Unsupported file type: $file\n\n";
}