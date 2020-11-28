#!/usr/bin/perl -w
#
# Compare package versions in OSGeo-Live against Debian & Ubuntu.
#
# Required dependencies (Debian/Ubuntu):
#
#  libdbi-perl libdbd-pg-perl libfile-slurp-perl libio-compress-perl
#  libwww-perl libdpkg-perl libjson-perl
#  
# Copyright (C) 2016, Bas Couwenberg <sebastic@xs4all.nl>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use DBI;
use Dpkg::Version;
use File::Basename;
use File::Slurp;
use File::Temp;
use Getopt::Long qw(:config bundling no_ignore_case);

use LWP::UserAgent;
use HTTP::Request::Common;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);

use JSON;

$|=1;

my %cfg = (
	    udd_db_host => 'udd-mirror.debian.net',
	    udd_db_port => '5432',
	    udd_db_name => 'udd',
	    udd_db_user => 'public-udd-mirror',
	    udd_db_pass => 'public-udd-mirror',
	    ppa_url     => 'http://ppa.launchpad.net/osgeolive/nightly/ubuntu',
	    ppa_series  => 'focal',
	    format      => 'text',
	    verbose     => 0,
	    help        => 0,
	  );

my $result = GetOptions(
			 'H|udd-db-host=s' => \$cfg{udd_db_host},
			 'P|udd-db-port=s' => \$cfg{udd_db_port},
			 'D|udd-db-name=s' => \$cfg{udd_db_name},
			 'U|udd-db-user=s' => \$cfg{udd_db_user},
			 'W|udd-db-pass=s' => \$cfg{udd_db_pass},
			 'u|ppa-url=s'     => \$cfg{ppa_url},
			 's|ppa-series=s'  => \$cfg{ppa_series},
			 'f|format=s'      => \$cfg{format},
			 'v|verbose'       => \$cfg{verbose},
			 'h|help'          => \$cfg{help},
		       );

if(!$result || $cfg{help}) {
	print STDERR "\n" if(!$result);

	print "Usage: ". basename($0) ." [OPTIONS]\n\n";
	print "Options:\n";
        print "\n";
        print "-H, --udd-db-host <HOST>      UDD database host     ($cfg{udd_db_host})\n";
        print "-P, --udd-db-port <PORT>      UDD database port     ($cfg{udd_db_port})\n";
        print "-D, --udd-db-name <NAME>      UDD database name     ($cfg{udd_db_name})\n";
        print "-U, --udd-db-user <USER>      UDD database username ($cfg{udd_db_user})\n";
        print "-W, --udd-db-pass <PASS>      UDD database password (". ('*' x length($cfg{udd_db_pass})) .")\n";
        print "\n";
        print "-u, --ppa-url <URL>           PPA base URL  ($cfg{ppa_url})\n";
        print "-s, --ppa-series <SERIES>     Distribution  ($cfg{ppa_series})\n";
        print "\n";
	print "-f, --format <FORMAT>         Output format ($cfg{format})\n";
	print "                              Valid formats: text (default), json\n";
	print "-v, --verbose                 Enable verbose output\n";
	print "-h, --help                    Display this usage information\n";

	exit 1;
}

my %packages = ();

print "Connecting to Ultimate Debian Database on $cfg{udd_db_host}\n" if($cfg{verbose});

our $udd_dbh = DBI->connect(
                             'dbi:Pg:dbname='.$cfg{udd_db_name}.';host='.$cfg{udd_db_host}.';port='.$cfg{udd_db_port},
                             $cfg{udd_db_user},
                             $cfg{udd_db_pass},
                             { AutoCommit => 0, RaiseError => 1, PrintError => 1 }
                           ) || die DBI->errstr;

our $ua = new LWP::UserAgent(agent => basename($0));


get_debiangis_packages();

get_debian_packages();

get_ubuntu_packages();

get_osgeolive_packages();

check_package_versions();

list_package_versions();


$udd_dbh->disconnect();

exit 0;

################################################################################
# Subroutines

sub get_debiangis_packages {
	my $query = '';
	my @param = ();

	print "Retrieving source package information for Debian GIS...\n" if($cfg{verbose});

	my $source       = 'debian-gis';
	my $distribution = 'debian';
	my $release      = 'sid';

	$query = "
	          SELECT s.source,
	                 s.version
	            FROM sources AS s
	           WHERE s.source = ?
                     AND s.distribution = ?
	             AND s.release = ?
	        ORDER BY s.source,
	                 s.version DESC
	         ";
	@param = ($source, $distribution, $release);

	my $sth = $udd_dbh->prepare($query) || die $udd_dbh->errstr;

	$sth->execute(@param) || die $sth->errstr;
	while(my $r = $sth->fetchrow_hashref) {
		print " src: ". $r->{source} ." (". $r->{version}  .")\n" if($cfg{verbose});

		$query = "
		          SELECT p.package,
		                 p.version,
		                 p.depends,
		                 p.recommends,
		                 p.suggests
		            FROM packages AS p
                           WHERE p.source = ?
                             AND p.source_version = ?
                             AND p.distribution = ?
	                     AND p.release = ?
		         ";
		@param = ($r->{source}, $r->{version}, $distribution, $release);

		my $sth2 = $udd_dbh->prepare($query) || die $udd_dbh->errstr;

		$sth2->execute(@param) || die $sth2->errstr;
		while(my $r = $sth2->fetchrow_hashref) {
			print " bin: ". $r->{package} ." (". $r->{version}  .")\n" if($cfg{verbose});
			print "   D: ". $r->{depends}    ."\n" if($cfg{verbose} && $r->{depends});
			print "   R: ". $r->{recommends} ."\n" if($cfg{verbose} && $r->{recommends});
			print "   S: ". $r->{suggests}   ."\n" if($cfg{verbose} && $r->{suggests});

			if($r->{recommends}) {
				my @packages = split /, /, $r->{recommends};

				my $package_list = "?," x ($#packages + 1);
				   $package_list =~ s/,$//;

				$query = "
				          SELECT p.source,
				                 p.source_version AS version
				            FROM packages AS p
				           WHERE p.package IN ($package_list)
			                     AND p.distribution = ?
				             AND p.release = ?
				        ORDER BY p.source,
				                 p.source_version DESC
				         ";

				@param = (@packages, $distribution, $release);

				my $sth3 = $udd_dbh->prepare($query) || die $udd_dbh->errstr;

				$sth3->execute(@param) || die $sth3->errstr;
				while(my $r = $sth3->fetchrow_hashref) {
					next if($packages{$r->{source}} && $packages{$r->{source}}{debiangis});

					print " add: ". $r->{source} ." (". $r->{version}  .")\n" if($cfg{verbose});

					$packages{$r->{source}}{debiangis} = $r;
				}
				$sth3->finish() || die $sth3->errstr;
			}
		}
		$sth2->finish() || die $sth2->errstr;
	}
	$sth->finish() || die $sth->errstr;

	print "\n" if($cfg{verbose});
}

sub get_debian_packages {
	my $query = '';
	my @param = ();

	print "Retrieving source package information for Debian...\n" if($cfg{verbose});

	my $distribution = 'debian';
	my $release      = 'sid';

	$query = "
	          SELECT s.source,
	                 s.version,
	                 s.vcs_url,
	                 s.vcs_browser,
	                 v.status                 AS vcs_status,
	                 v.changelog_version      AS vcs_changelog_version,
	                 v.changelog_distribution AS vcs_changelog_distribution,
	                 v.changelog              AS vcs_changelog
	            FROM sources  AS s
	       LEFT JOIN vcswatch AS v ON s.source = v.source AND s.version = v.version
	           WHERE s.distribution = ?
	             AND s.release = ?
	        ORDER BY s.source,
	                 s.version DESC
	         ";
	@param = ($distribution, $release);

	my $sth = $udd_dbh->prepare($query) || die $udd_dbh->errstr;

	$sth->execute(@param) || die $sth->errstr;
	while(my $r = $sth->fetchrow_hashref) {
		next if($packages{$r->{source}} && $packages{$r->{source}}{debian});

		$packages{$r->{source}}{debian} = $r;

		print " ". $r->{source} ." (". $r->{version}  .")\n" if($cfg{verbose});
	}
	$sth->finish() || die $sth->errstr;

	print "\n" if($cfg{verbose});
}

sub get_ubuntu_packages {
	my $query = '';
	my @param = ();

	print "Retrieving source package information for Ubuntu...\n" if($cfg{verbose});

	my $distribution = 'ubuntu';
	my $release      = $cfg{ppa_series};

	$query = "
	          SELECT s.source,
	                 s.version,
	                 s.vcs_url,
	                 s.vcs_browser
	            FROM ubuntu_sources AS s
	           WHERE s.distribution = ?
	             AND s.release = ?
	        ORDER BY s.source,
	                 s.version DESC
	         ";
	@param = ($distribution, $release);

	my $sth = $udd_dbh->prepare($query) || die $udd_dbh->errstr;

	$sth->execute(@param) || die $sth->errstr;
	while(my $r = $sth->fetchrow_hashref) {
		next if($packages{$r->{source}} && $packages{$r->{source}}{ubuntu});

		$packages{$r->{source}}{ubuntu} = $r;

		print " ". $r->{source} ." (". $r->{version}  .")\n" if($cfg{verbose});
	}
	$sth->finish() || die $sth->errstr;

	print "\n" if($cfg{verbose});
}

sub get_osgeolive_packages {
	print "Retrieving source package information for OSGeo-Live...\n" if($cfg{verbose});

	my $url = $cfg{ppa_url}.'/dists/'.$cfg{ppa_series}.'/main/source/Sources.gz';

        my $req = GET $url;

        my $res = $ua->request($req);
        if(!$res->is_success) {
                print "Error: Request failed! ($url)\n";
                print "HTTP Status: ".$res->code." ".$res->message."\n";

		exit 1;
        }
                
	my $content = $res->content;

	my $gz_tempfile = File::Temp->new(
                                           SUFFIX => '.gz',
                                         );
	
	write_file($gz_tempfile->filename, $content);

	my $tempfile = File::Temp->new();

	gunzip $gz_tempfile->filename => $tempfile->filename or die "Error: gunzip failed ($GunzipError)\n";

        my @paragraphs = split /\n\n/, read_file($tempfile->filename);
	foreach my $paragraph (sort @paragraphs) {
		my $pkg = '';
		foreach(split /\n/, $paragraph) {
			if(/^Package: (\S+)/) {
				$pkg = $1;
			}
			elsif($pkg && /^Version: (\S+)/) {
				my $version = $1;

				$packages{$pkg}{osgeolive} = {
							       source  => $pkg,
							       version => $version,
							     };

				print " $pkg ($version)\n" if($cfg{verbose});

				last;
			}
		}
	}

	print "\n" if($cfg{verbose});
}

sub check_package_versions {
	foreach my $package (sort keys %packages) {
		if($packages{$package}{osgeolive} && $packages{$package}{osgeolive}{version}) {
			my $osgeolive_version = Dpkg::Version->new($packages{$package}{osgeolive}{version});
		
			if($packages{$package}{debian} && $packages{$package}{debian}{version}) {
				my $debian_version = Dpkg::Version->new($packages{$package}{debian}{version});

				my $compare = version_compare($osgeolive_version->version(), $debian_version->version());

				if($compare == -1) {
					$packages{$package}{status} = "New upstream version in Debian";
				}
				elsif($compare == 0) {
					$packages{$package}{status} = "Same version in Debian & OSGeo-Live";
				}
				elsif($compare == 1) {
					$packages{$package}{status} = "Old upstream version in Debian";
				}
			}
			elsif($packages{$package}{ubuntu} && $packages{$package}{ubuntu}{version}) {
				my $ubuntu_version = Dpkg::Version->new($packages{$package}{ubuntu}{version});

				my $compare = version_compare($osgeolive_version->version(), $ubuntu_version->version());

				if($compare == -1) {
					$packages{$package}{status} = "New upstream version in Ubuntu";
				}
				elsif($compare == 0) {
					$packages{$package}{status} = "Same version in Ubuntu & OSGeo-Live";
				}
				elsif($compare == 1) {
					$packages{$package}{status} = "Old upstream version in Ubuntu";
				}
			}
			else {
				$packages{$package}{status} = "Only in OSGeo-Live";
			}
		}
		elsif($packages{$package}{ubuntu} && $packages{$package}{ubuntu}{version}) {
			my $ubuntu_version = Dpkg::Version->new($packages{$package}{ubuntu}{version});

			if($packages{$package}{debian} && $packages{$package}{debian}{version}) {
				my $debian_version = Dpkg::Version->new($packages{$package}{debian}{version});

				my $compare = version_compare($ubuntu_version->version(), $debian_version->version());

				if($compare == -1) {
					# Ubuntu version is older than in Debian

					$packages{$package}{status} = "New upstream version in Debian";
				}
				elsif($compare == 0) {
					$packages{$package}{status} = "Same version in Debian & Ubuntu";
				}
				else {
					$packages{$package}{status} = "Old upstream version in Debian";
				}
			}
		}
		elsif($packages{$package}{debian} && $packages{$package}{debian}{version}) {
			$packages{$package}{status} = "Only in Debian";
		}
	}
}

sub list_package_versions {
	if(!$cfg{format} || $cfg{format} eq 'text') {
		package_version_table();
	}
	elsif($cfg{format} eq 'json') {
		package_version_json();
	}
	else {
		print "Error: Format not supported: $cfg{format}\n";
		exit 1;
	}
}

sub package_version_table {
	# ╔═══════════╤══════════════╤════════════════════════╤═════════════════════╗
	# ║ Package   │ Debian       │ OSGeo-Live             │ Ubuntu              ║
	# ╟───────────┼──────────────┼────────────────────────┼─────────────────────╢
	# ║ gdal      │ 2.1.1+dfsg-1 │ 2.1.0+dfsg-1~xenial0   │ 1.11.3+dfsg-3build2 ║
	# ║ mapserver │ 7.0.1-3      │ 7.0.1-4~xenial1~php5.6 │ 7.0.0-9ubuntu3      ║
	# ╚═══════════╧══════════════╧════════════════════════╧═════════════════════╝

	my @columns = qw(
	                  package
                          debian
                          osgeolive
                          ubuntu
                          status
	                );

	my %title = (
	              package   => 'Package',
	              debian    => 'Debian',
	              ubuntu    => 'Ubuntu',
	              osgeolive => 'OSGeo-Live',
	              vcs       => 'VCS',
	              status    => 'Status',
	            );

	my %longest = (
	                package   => length($title{package}),
	                debian    => length($title{debian}),
	                ubuntu    => length($title{ubuntu}),
	                osgeolive => length($title{osgeolive}),
	                vcs       => length($title{vcs}),
	                status    => length($title{status}),
	              );

	foreach my $package (sort keys %packages) {
		next if(!$packages{$package}{debiangis} && !$packages{$package}{osgeolive});

		my $length = length($package);

		$longest{package} = $length if($length > $longest{package});

		foreach my $key (qw(debian ubuntu osgeolive)) {
			if($packages{$package}{$key} && $packages{$package}{$key}{version}) {
				$length = length($packages{$package}{$key}{version});

				$longest{$key} = $length if($length > $longest{$key});
			}
		}

		if($packages{$package}{debian} && $packages{$package}{debian}{vcs_changelog_version}) {
			$length = length($packages{$package}{debian}{vcs_changelog_version});

			$longest{vcs} = $length if($length > $longest{vcs});
		}

		if($packages{$package}{status}) {
			$length = length($packages{$package}{status});

			$longest{status} = $length if($length > $longest{status});
		}
	}

	my $head = '';
	my $line = '';
	my $tail = '';

	$head .= '╔';
	$line .= '╟';
	$tail .= '╚';
	
	foreach my $column (@columns) {
		$head .= '═';
		$head .= '═' x $longest{$column};
		$head .= '═';
		$head .= '╤' if($column ne $columns[-1]);

		$line .= '─';
		$line .= '─' x $longest{$column};
		$line .= '─';
		$line .= '┼' if($column ne $columns[-1]);

		$tail .= '═';
		$tail .= '═' x $longest{$column};
		$tail .= '═';
		$tail .= '╧' if($column ne $columns[-1]);
	}

	$head .= '╗';
	$line .= '╢';
	$tail .= '╝';
	
	$head .= "\n";
	$line .= "\n";
	$tail .= "\n";

	print $head;

	print '║';
	foreach my $column (@columns) {
		print ' ';
		print $title{$column};
		print ' ' x ($longest{$column} - length($title{$column}));
		print ' ';
		print '│' if($column ne $columns[-1]);
	}
	print '║';
	print "\n";

	print $line;

	foreach my $package (sort keys %packages) {
		next if(!$packages{$package}{debiangis} && !$packages{$package}{osgeolive});

		my %value = (
			      package   => $package,
			      debian    => '',
			      ubuntu    => '',
			      osgeolive => '',
			      vcs       => '',
			      status    => '',
			    );

		foreach my $key (qw(debian ubuntu osgeolive)) {
			if($packages{$package}{$key} && $packages{$package}{$key}{version}) {
				$value{$key} = $packages{$package}{$key}{version};
			}
		}

		if($packages{$package}{debian} && $packages{$package}{debian}{vcs_changelog_version}) {
			$value{vcs} = $packages{$package}{debian}{vcs_changelog_version};
		}

		if($packages{$package}{status}) {
			$value{status} = $packages{$package}{status};
		}

		print '║';
		foreach my $column (@columns) {
			print ' ';
			print $value{$column};
			print ' ' x ($longest{$column} - length($value{$column}));
			print ' ';
			print '│' if($column ne $columns[-1]);
		}
		print '║';
		print "\n";
	}
	
	print $tail;
}

sub package_version_json {
	my $data = {};

	foreach my $package (sort keys %packages) {
		next if(!$packages{$package}{debiangis} && !$packages{$package}{osgeolive});

		$data->{packages}->{$package} = $packages{$package};
	}

	print to_json($data, { pretty => 1 });
}

