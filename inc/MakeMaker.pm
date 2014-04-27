package inc::MakeMaker;

use Moose;
use Config;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_MakeFile_PL_template => sub {
	my ($self) = @_;

	my $template = <<'TEMPLATE';
use strict;
use warnings;
use Config;

use Devel::CheckLib;

my $def = '';
my $lib = '';
my $inc = '';
my $ccflags = '';

my %os_specific = (
	'darwin' => {
		'ssh2' => {
			'inc' => ['/opt/local/include'],
			'lib' => ['/opt/local/lib']
		}
	},
	'freebsd' => {
		'ssh2' => {
			'inc' => ['/usr/local/include'],
			'lib' => ['/usr/local/lib']
		}
	}
);

my $ssh2_libpath;
my $ssh2_incpath;
if (my $os_params = $os_specific{$^O}) {
	if (my $ssh2 = $os_params -> {'ssh2'}) {
		$ssh2_libpath = $ssh2 -> {'lib'};
		$ssh2_incpath = $ssh2 -> {'inc'};
	}
}

if (check_lib(lib => 'ssl')) {
	$def .= ' -DGIT_SSL';
	$lib .= ' -lssl -lcrypto';

	print "SSL support enabled\n";
} else {
	print "SSL support disabled\n";
}

if (check_lib(lib => 'ssh2', libpath => $ssh2_libpath, incpath => $ssh2_incpath)) {
	if ($ssh2_libpath) {
		$lib .= ' -L'.join (' -L', @$ssh2_libpath);
	}
	if ($ssh2_incpath) {
		$inc .= ' -I'.join (' -I', @$ssh2_incpath);
	}

	$def .= ' -DGIT_SSH';
	$lib .= ' -lssh2';

	print "SSH support enabled\n";
} else {
	print "SSH support disabled\n";
}

if ($Config{usethreads}) {
	if (check_lib(lib => 'pthread')) {
		$def .= ' -DGIT_THREADS';
		$lib .= ' -lpthread';

		print "Threads support enabled\n";
	} else {
		if ($^O eq 'MSWin32') {
			$def .= ' -DGIT_THREADS';
		} else {
			print "Threads support disabled\n";
		}
	}
}

# building with a 32-bit perl on a 64-bit OS may require this
if ($Config{ptrsize} == 4) {
	$ccflags .= ' -m32';
}

my @deps = glob 'deps/libgit2/deps/{http-parser,zlib}/*.c';
my @srcs = glob 'deps/libgit2/src/{*.c,transports/*.c,xdiff/*.c}';
push @srcs, 'deps/libgit2/src/hash/hash_generic.c';

if ($^O eq 'MSWin32') {
	push @srcs, glob 'deps/libgit2/src/{win32,compat}/*.c';
	push @srcs, 'deps/libgit2/deps/regex/regex.c';

	$inc .= ' -Ideps/libgit2/deps/regex';
	$def .= ' -DWIN32 -D_WIN32_WINNT=0x0501 -DGIT_WIN32 -D__USE_MINGW_ANSI_STDIO=1';
} else {
	push @srcs, glob 'deps/libgit2/src/unix/*.c'
}

if ($^O eq 'darwin') {
	$ccflags .= ' -Wno-deprecated-declarations -Wno-unused-const-variable -Wno-unused-function';
}

# real-time library is required for Solaris and Linux
if ($^O =~ /sun/ || $^O =~ /solaris/ || $^O eq 'linux') {
	$lib .= ' -lrt';
}

my @objs = map { substr ($_, 0, -1) . 'o' } (@deps, @srcs);

sub MY::c_o {
	return <<'EOS'
.c$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) "-I$(PERL_INC)" $(PASTHRU_DEFINE) $(DEFINE) $*.c -o $@
EOS
}

# This Makefile.PL for {{ $distname }} was generated by Dist::Zilla.
# Don't edit it but the dist.ini used to construct it.
{{ $perl_prereq ? qq[BEGIN { require $perl_prereq; }] : ''; }}
use strict;
use warnings;
use ExtUtils::MakeMaker {{ $eumm_version }};
{{ $share_dir_block[0] }}
my {{ $WriteMakefileArgs }}

$WriteMakefileArgs{DEFINE}  .= $def;
$WriteMakefileArgs{LIBS}    .= $lib;
$WriteMakefileArgs{INC}     .= $inc;
$WriteMakefileArgs{CCFLAGS} .= $ccflags;
$WriteMakefileArgs{OBJECT}  .= ' ' . join ' ', @objs;

unless (eval { ExtUtils::MakeMaker->VERSION(6.56) }) {
	my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
	my $pp = $WriteMakefileArgs{PREREQ_PM};

	for my $mod (keys %$br) {
		if (exists $pp -> {$mod}) {
			$pp -> {$mod} = $br -> {$mod}
				if $br -> {$mod} > $pp -> {$mod};
		} else {
			$pp -> {$mod} = $br -> {$mod};
		}
	}
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
	unless eval { ExtUtils::MakeMaker -> VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
{{ $share_dir_block[1] }}
TEMPLATE

	return $template;
};

override _build_WriteMakefile_args => sub {
	return +{
		%{ super() },
		INC	    => '-I. -Ideps/libgit2 -Ideps/libgit2/src -Ideps/libgit2/include -Ideps/libgit2/deps/http-parser -Ideps/libgit2/deps/zlib',
		DEFINE	=> '-DNO_VIZ -DSTDC -DNO_GZIP -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE',
		CCFLAGS	=> '-Wall -Wno-unused-variable -Wdeclaration-after-statement',
		OBJECT	=> '$(O_FILES)',
	}
};

__PACKAGE__ -> meta -> make_immutable;
