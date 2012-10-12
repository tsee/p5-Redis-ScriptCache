use 5.008001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Redis::ScriptCache',
    VERSION_FROM      => 'lib/Redis/ScriptCache.pm', # finds $VERSION
    PREREQ_PM         => {
      'Carp' => '0',
      'Redis' => '1.955',
      'Class::XSAccessor' => '1.12',
      'Digest::SHA1' => '0',
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Redis/ScriptCache.pm', # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
);
