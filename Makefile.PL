use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'File::Find::Rule::Permissions',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-File-Find-Rule-Permissions'
        }
    },
    VERSION_FROM => 'lib/File/Find/Rule/Permissions.pm',
    PREREQ_PM    => {
        'File::Find::Rule'      => 0.1,
        'Devel::AssertOS::Unix' => 1.0,
        'Test::More'            => 0,
    }
);
