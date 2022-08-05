#!/usr/bin/env perl
require "$root/Daemon.pm";
require "$root/Memento/Command.pm";

package Memento::Tool::docker;

use feature 'say';
our @ISA = qw(Memento::Command);
use strict; use warnings;
use Encode qw(decode);
use Cwd;
use Getopt::Long;
use Switch;
use Text::Trim;
use Data::Dumper;

our ($cwd);
$cwd = getcwd();
$cwd =~ s/^\s+|\s+$//g; # trim string
$cwd .= '/'; # add trailing slash

sub cmd {
  my $class = shift;
  my @arguments = @_;

  my $dockerProjectRoot = _retrieve_docker_project_root();
  my $dockerProjectScript = '.bmeme/bin/app';
  my $dockerProjectSubPath = substr($cwd, length($dockerProjectRoot));

  if ( $dockerProjectRoot ) {
    my $dockerProjectScriptFull = "${dockerProjectRoot}${dockerProjectScript}";
    my $fullCmd = $dockerProjectSubPath ne "" ? "$dockerProjectScriptFull cd \"${dockerProjectSubPath}\" \\; @arguments" : "$dockerProjectScriptFull @arguments";
    # say Daemon::printColor("Command to run: $fullCmd");
    Daemon::system($fullCmd);
  } else {
    say Daemon::printColor("Unable to run 'cmd' command, docker project root not found!");
  }
}

sub configure {
  my $class = shift;
  my @arguments = @_;

  my $dockerProjectRoot = _retrieve_docker_project_root();

  if ( $dockerProjectRoot ) {
    my $fullCmd = "cd $dockerProjectRoot > /dev/null && .bmeme/build/configure @arguments";
    # say Daemon::printColor("Command to run: $fullCmd");
    Daemon::system($fullCmd);
  } else {
    say Daemon::printColor("Unable to run 'configure' command, docker project root not found!");
  }
}

# OVERRIDDEN METHODS ###########################################################



# PRIVATE METHODS ##############################################################

sub _retrieve_docker_project_root {
  my $dockerProjectScript = '.bmeme/bin/c';
  my $dockerProjectRoot = $cwd;
  my $dockerProjectRootFound = 0;

  # Search until project dir is found or we reach root directory '/'
  while ($dockerProjectRootFound eq 0 && $dockerProjectRoot ne '' && $dockerProjectRoot ne '/') {
    if ( -e "${dockerProjectRoot}${dockerProjectScript}") {
      $dockerProjectRootFound = 1;
      last;
    }
    # Move to parent directory
    $dockerProjectRoot =~ s/[^\/]+\/?$//;
  }

  if ( $dockerProjectRootFound ) {
    return $dockerProjectRoot;
  } else {
    say Daemon::printColor("Docker project root not found!");
    return;
  }
}

1;