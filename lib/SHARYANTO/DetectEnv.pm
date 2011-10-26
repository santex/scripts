package SHARYANTO::DetectEnv;

our $env;

if (-f "/etc/.backpacker-hpmini") {
    $env = "netbook-hpmini";
} elsif (-f "/etc/.backpacker-eee") {
    $env = "netbook-eee";
} elsif ("/etc/.builder") {
    $env = "pc";
} else {
    die "Can't detect environment (e.g. /etc/.builder means builder)";
}

1;

