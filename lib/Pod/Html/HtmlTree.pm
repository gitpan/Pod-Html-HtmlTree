#$Id: HtmlTree.pm 34 2005-03-13 05:59:46Z root $
package Pod::Html::HtmlTree;
use strict;
use Pod::Html;
use File::Find;
use File::Path;
use File::Basename;
our $VERSION =  0.90;

sub new{
    my $class = shift;
    my $self  = shift || {};
    $self->{pod_exts}   = $self->{pod_exts}  || [ 'pm' ,'pl' ,'cgi','pod' ];
    $self->{mask_dir}   = $self->{mask_dir} || 0775;
    $self->{mask_html}  = $self->{mask_html}|| 0664;
    bless $self , $class;
    return $self;
}
sub create{
    my $self = shift;
    my $infiles  = $self->_get_infiles ();
    return unless defined $infiles;
    my $outfiles = $self->_get_outfiles( $infiles );
    umask 0000;
    for( my $i = 0; $i < scalar @{$infiles} ; $i++ ){
	mkpath( dirname($outfiles->[$i]) , 0 , $self->{mask_dir}  ) unless -d dirname($outfiles->[$i]);
	my @data = map ( $_ , @{$self->{data}} );
	push ( @data , '--infile='  . $infiles->[$i]  );
	push ( @data , '--outfile=' . $outfiles->[$i] );

	pod2html( @data );
	chmod ( $self->{mask_html} , $outfiles->[$i] );
    }
    # only work when cachedir is not set.
    # means user need to se tcachedir when he need tmp files.
    unlink './pod2htmd.tmp';
    unlink './pod2htmi.tmp';

    return $outfiles;
}
sub args{
    my $self = shift;
    my $arg = shift;
    $self->{data} = ();
    foreach my $key ( keys %{$arg} ){
	my $value = '';
	if ( $arg->{$key} eq '0' ){
	    $value = "--$key" ;
	}else{
	    $value = "--$key=$arg->{$key}";
	}
	push ( @{$self->{data}} , $value  );
    }
    
}
sub _get_outfiles{
    my $self     = shift;
    my $infiles  = shift;
    my $outfiles = ();
    @{$outfiles} = map( $_ , @{$infiles} );
    for( my $i = 0 ; $i < scalar @{$outfiles} ; $i++ ){
	$outfiles->[$i] =~ s/$self->{indir}/$self->{outdir}/;
	for( my $j = 0 ; $j < scalar @{$self->{pod_exts}} ; $j++ ){
	    $outfiles->[$i] =~ s/\.$self->{pod_exts}->[$j]/\.html/;
	}
    }
    return $outfiles;
}
sub _get_infiles{
    my $self     = shift;
    my $infiles = ();
    File::Find::find( 
		      sub{
			  push ( @{$infiles} , $File::Find::name ) if (!-d $_ && $self->_is_ok_ext( $_ ) )  ;
		      }
	, $self->{indir} );
    return $infiles;
}
sub _is_ok_ext{
    my $self = shift;
    my $result = 0;
    for( my $i = 0 ; $i < scalar @{$self->{pod_exts}} ; $i++ ){
	if ( /\.$self->{pod_exts}->[$i]$/ ){
	    $result =  1;
	    last;
	}
    }
    return $result;
}
sub pod_exts{
    my $self = shift;
    $self->{pod_exts} = shift;
}
sub mask_dir{
    my $self = shift;
    $self->{mask_dir} = shift;
}
sub mask_html{
    my $self = shift;
    $self->{mask_html} = shift;
}
sub indir{
    my $self = shift;
    $self->{indir} = shift;
}
sub outdir{
    my $self = shift;
    $self->{outdir} = shift;
}



1;
__END__

=head1 NAME

 Pod::Html::HtmlTree - class to convert pod files to html tree

=head1 SYNOPSIS

 use Pod::Html::HtmlTree;
 use Data::Dumper;

 my $p = Pod::Html::HtmlTree->new;
 $p->indir    ( '/usr/lib/perl5/site_perl/5.8.3/Pod' );
 $p->outdir   ( '/tmp/pod'      );	
 $p->mask_dir ( 0777 );	# default is 0775
 $p->mask_html( 0777 ); # default is 0664
 $p->pod_exts ( [ 'pm' , 'pod' ] ); # default is [pm,pod,cgi,pl]
 # * you can use all arguments same as Pod::Html has except infile and outfile.
 # * use * 0 * for argument value which does not require to have value.
 $p->args({
    css =>'http://localhost/pod.css',
    index => 0,
 });

 my $outfiles = $p->create;
 print Dumper ( $outfiles ); 

=head1 DESCRIPTION

 This module does same as Pod::Html module but make html tree.
 Read Pod::Html document for more detail.

=head1 AUTHOR

 Tomohiro Teranishi < tomohiro.teranishi@gmail.com >

=head1 SEE ALSO

 perldoc , Pod::Html

=head1 COPYRIGHT

 This program is distributed under the Artistic License

=cut
