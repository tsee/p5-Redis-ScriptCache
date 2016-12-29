# NAME

Redis::ScriptCache - Cached Lua scripts on a Redis server

# SYNOPSIS

    use Redis;
    use Redis::ScriptCache;

    my $conn = Redis->new(server => ...);
    my $cache = Redis::ScriptCache->new(redis_conn => $conn);

    # some Lua script to execute on the server
    my $script = q{
      local x = redis.call('get', KEYS[1]);
      redis.call('set', 'temp', x);
      return x;
    };
    my $script_name = $cache->register_script('myscript', $script);

    # later:
    my ($value) = $cache->run_script('myscript', [1, 'somekey']);

    # alternatively, if you have a script_dir
    my $cache = Redis::ScriptCache->new(
      redis_conn => $conn,
      script_dir => 'path/to/lua/scripts',
    );
    $cache->register_all_scripts();
    # path/to/lua/scripts/*.lua gets registered
    $cache->run_script('myscript1', [1, 'somekey']); # myscript1.lua

# DESCRIPTION

Recent versions of Redis can execute Lua scripts on the server.  This appears
to be the most effective and efficient way to group interactions with Redis
atomically. In order to avoid having to re-transmit (and compile) the scripts
themselves on every request, Redis has a set of commands related to executing
previously seen scripts again using the SHA-1 as identification.

This module offers a way to avoid re-transmission of the full script without
checking for script existence on the server manually each time.  For that
purpose, it offers an interface that will load the given script onto the Redis
server and on subsequent uses avoid doing so.

Do not use this module if it can happen that all scripts are flushed from the
Redis instance during the life time of a script cache object.

# METHODS

## new

Expects key/value pairs of options.  The only mandatory option is
`redis_conn`, an instance of the [Redis](https://metacpan.org/pod/Redis) module to use to talk to the Redis
server.

`script_dir` is optional, and can also be specified in `register_all_scripts` as
well (see below).

## register\_script

Given a Lua script (as a scalar, or scalar ref) to register as the first
argument, this makes sure that the script is available via its SHA-1 on the
Redis server.

Returns the script's name, which will be used to invoke the script using
`run_script`, see below.  The SHA-1 is opaque to the user and is internally
cached to avoid repeat registration and unnecessary roundtrips.

## run\_script

Given a registered script's name as first argument and an array reference as
second argument, executes the corresponding Lua script on the Redis server and
passes the contents of the array reference as parameters to the
`$redis->evalsha($sha, ...)` call. Refer to
[http://redis.io/commands/evalsha](http://redis.io/commands/evalsha) for details.

If the second parameter is omitted, it's assumed to be a script
call without parameters, so that

    $cache->run_script($script_name);

is the same as:

    $cache->run_script($script_name, [0]);

It is expected that the script is pre-registered via `register_script`,
`register_file`, or `register_all_scripts`.

Returns the results of the `evalsha` call.

## register\_all\_scripts

Given a `script_dir` (specified in `new` or `register_all_scripts`), will
register them all under their Lua script names.

Returns an array of names all registered scripts.

## register\_file

Given a filename under `script_dir` will register that file and return the
name of that script. Handy if you don't want to register everything, but just a
select script on disk.

## scripts

Returns an array of all scripts registered in the script cache.

## flush\_all\_scripts

Flushes the Redis script cache, and the local script cache.

# SEE ALSO

[Redis](https://metacpan.org/pod/Redis)

[http://redis.io](http://redis.io)

# AUTHOR

Steffen Mueller, `smueller@cpan.org`

# CONTRIBUTORS

Iftekharul Haque, `iftekhar@cpan.org`

Tom Rathborne, `lsd@acm.org`

Omar Othman, `omar.m.othman@gmail.com`

Marc Mims, `marc@questright.com`

# COPYRIGHT AND LICENSE

    (C) 2012-2016 Steffen Mueller. All rights reserved.

    This code is available under the same license as Perl version
    5.8.1 or higher.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
