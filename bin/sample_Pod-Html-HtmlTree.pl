#!/usr/bin/perl -w
# sample
#$Id: sample_Pod-Html-HtmlTree.pl 27 2005-03-12 15:34:24Z root $
use strict;
use Data::Dumper;
use Pod::Html::HtmlTree;

my $p =  Pod::Html::HtmlTree->new;
 $p->indir ( '/usr/lib/perl5/site_perl/5.8.3/Pod'     );
 $p->outdir( '/tmp/pod' );
 $p->args({
    css =>'http://localhost/pod.css',
    quiet=> 0 ,
 });
 $p->mask_dir ( 0777 ); # default is 0775
 $p->mask_html( 0777 ); # default is 0664
 $p->pod_exts ( [ 'pm' ] );

 my $outfiles = $p->create;
 print Dumper $outfiles;
 exit( 0 );
