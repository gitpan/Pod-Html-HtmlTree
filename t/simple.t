#!/usr/bin/perl

#$Id
unshift @INC , qw ( blib/arch blib/lib );
use Pod::Html::HtmlTree;	
use Test;
use File::Path;
use File::stat;
use strict;
BEGIN{
    plan tests =>  8;
};
 
&test_my_pod;
&test_extention;
&test_args;
&test_mask;

sub test_my_pod{
    my $p = Pod::Html::HtmlTree->new;
    $p->indir ( 'lib/' );
    $p->outdir( 't/test_pod/' );
    my $outfiles = $p->create;
    # ** check outfile count
    ok ( 1 , scalar @{$outfiles} );
    # ** check html file
    ok ( -f $outfiles->[0] );
    rmtree ( 't/test_pod/' );
}
sub test_extention{
    # * no such extentions
    my $p = Pod::Html::HtmlTree->new( { indir=>'lib/' , outdir=>'t/test_pod/' } );
    my @exts = ( 'foo', 'garrr' );
    $p->pod_exts( \@exts );
    my $outfiles = $p->create;
    ok ( !defined $outfiles );
    
    # * ok extention
    $p = Pod::Html::HtmlTree->new( { indir=>'lib/' , outdir=>'t/test_pod/' } );
    @exts = ( 'pm' );
    $p->pod_exts( \@exts );
    $outfiles = $p->create;
    ok ( 1 , scalar @{$outfiles} );
    rmtree ( 't/test_pod' );
}

sub test_args{
    # * No error at Pod::Html means succeess for this test.
     my $p = Pod::Html::HtmlTree->new( { indir=>'lib/' , outdir=>'t/test_pod/' } );
     $p->args({
	 backlink  => 'top',
	 cachedir  => 't/test_pod',
	 css       => 'pod.css',
	 flush     => 0,
	 header    => 0,
	 #help      => 0,
	 htmldir   => 't/test_pod',
	 htmlroot  => 'http://localhost/pod',
	 noindex   => 0,
	 libpods   => 'perlfunc:perlmod',
	 podpath   => './../lib/Pod',
	 podroot   => 'lib',
	 quiet     => 0,
	 recurse   => 0,
	 title     => 'test title',
	 noverbose => 0, 
     });
     my $outfiles = $p->create;
     ok( 1 , scalar @{$outfiles} );
     rmtree ( 't/test_pod' );
}

sub test_mask{
    my $p = Pod::Html::HtmlTree->new;
    $p->indir ( 'lib/' );
    $p->outdir( 't/test_pod/' );
    $p->mask_dir( 0776 );
    $p->mask_html( 0777 );
    my $outfiles = $p->create;

    # ** Dir mask check.
    my $st = stat( 't/test_pod/' );
    ok ( sprintf( "%04o" , $st->mode & 0777) eq '0776' );
    $st = stat ( 't/test_pod/Pod/' );
    ok ( sprintf( "%04o" , $st->mode & 0777) eq '0776' );


    # ** Html file mask check.
    $st = stat( $outfiles->[0] );
    ok ( sprintf( "%04o" , $st->mode & 0777)  eq '0777' );
    rmtree ( 't/test_pod' );
    
}
1;
