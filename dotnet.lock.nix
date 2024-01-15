{ fetchurl
, fetchFromGitHub
, stdenv
, lib
, unzip
, dotnet2nix-fetchNuGet ? (
    { name, version, ... } @ attrs:
      stdenv.mkDerivation {
        name = name;
        pversion = version;
        phases = [ "buildPhase" ];
        src =
          if attrs ? url then
            fetchurl (
              (
                builtins.removeAttrs attrs [
                  "version"
                ]
              ) // {
                inherit name;
              }
            )
          else
            builtins.path {
              path = ./. + ("/" + attrs.file);
              sha256 = attrs.sha256;
            };
        dontUnpack = true;
        buildPhase = ''
          mkdir -p "$out"
          cp $src "$out/${lib.strings.toLower name}.${lib.strings.toLower version}.nupkg"
        '';
      }
  )
, dotnet2nix-fetchFromGitHubForPaket ? (
    { group, owner, repo, rev, file, ... } @ attrs:
      let
        group2 =
          if group == null then "" else "${group}/";
      in
        stdenv.mkDerivation {
          name = "${if group == null then "" else "${group}_"}${owner}_${repo}_${builtins.replaceStrings [ "/" "_" ] [ "_" "__" ] file}";
          pversion = rev;
          phases = [ "buildPhase" ];
          src = fetchFromGitHub (
            (
              builtins.removeAttrs attrs [
                "file"
                "group"
              ]
            )
          );
          buildPhase = ''
            fileDir=$(dirname "$out/${group2}${owner}/${repo}/${file}")
            mkdir -p "$fileDir"
            cp "$src/${file}" "$out/${group2}${owner}/${repo}/${file}"
            echo "${rev}" > "$fileDir/paket.version"
          '';
        }
  )
}:
let
  fetchNuGet = dotnet2nix-fetchNuGet;
  fetchFromGitHubForPaket = dotnet2nix-fetchFromGitHubForPaket;
in
{
  nuget = [
    (
      fetchNuGet {
        name = "argu";
        version = "6.1.4";
        url = "https://api.nuget.org/v3-flatcontainer/argu/6.1.4/argu.6.1.4.nupkg";
        sha256 = "0mvbmch04d6ih0v5br47q8f5ddhxvsijpmfl4m3ppx7gq4cp5r0w";
      }
    )
    (
      fetchNuGet {
        name = "chessie";
        version = "0.6.0";
        url = "https://api.nuget.org/v3-flatcontainer/chessie/0.6.0/chessie.0.6.0.nupkg";
        sha256 = "1qz7ynwmglqwgsvjxkv9ps3b834psvldbvpk4420ii5bzqp4dsvk";
      }
    )
    (
      fetchNuGet {
        name = "fsharp.collections.parallelseq";
        version = "1.2.0";
        url = "https://api.nuget.org/v3-flatcontainer/fsharp.collections.parallelseq/1.2.0/fsharp.collections.parallelseq.1.2.0.nupkg";
        sha256 = "0nsji0w089fhs6xa6m7w8r8zqdi3gm29nzpl386kk5r1vfrw3zfv";
      }
    )
    (
      fetchNuGet {
        name = "fsharp.core";
        version = "6.0.3";
        url = "https://api.nuget.org/v3-flatcontainer/fsharp.core/6.0.3/fsharp.core.6.0.3.nupkg";
        sha256 = "0r2awf0iznlm4np455cixv9h19xpching8wi8vxykkjccl51qw59";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.csharp";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.csharp/4.7.0/microsoft.csharp.4.7.0.nupkg";
        sha256 = "0gd67zlw554j098kabg887b5a6pq9kzavpa3jjy5w53ccjzjfy8j";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.netcore.platforms";
        version = "7.0.4";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.platforms/7.0.4/microsoft.netcore.platforms.7.0.4.nupkg";
        sha256 = "0afmivk3m0hmwsiqnl87frzi7g57aiv5fwnjds0icl66djpb6zsm";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.netcore.targets";
        version = "5.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.targets/5.0.0/microsoft.netcore.targets.5.0.0.nupkg";
        sha256 = "0z3qyv7qal5irvabc8lmkh58zsl42mrzd1i0sssvzhv4q4kl3cg6";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.win32.primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.primitives/4.0.1/microsoft.win32.primitives.4.0.1.nupkg";
        sha256 = "1n8ap0cmljbqskxpf8fjzn7kh1vvlndsa75k01qig26mbw97k2q7";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.win32.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.primitives/4.3.0/microsoft.win32.primitives.4.3.0.nupkg";
        sha256 = "0j0c1wj4ndj21zsgivsc24whiya605603kxrbiw6wkfdync464wq";
      }
    )
    (
      fetchNuGet {
        name = "mono.cecil";
        version = "0.11.5";
        url = "https://api.nuget.org/v3-flatcontainer/mono.cecil/0.11.5/mono.cecil.0.11.5.nupkg";
        sha256 = "1l388sy7ibsq4b2pj08g3di0g8yppq47chd7ip10kwml6mpp1wcw";
      }
    )
    (
      fetchNuGet {
        name = "netstandard.library";
        version = "1.6.0";
        url = "https://api.nuget.org/v3-flatcontainer/netstandard.library/1.6.0/netstandard.library.1.6.0.nupkg";
        sha256 = "0nmmv4yw7gw04ik8ialj3ak0j6pxa9spih67hnn1h2c38ba8h58k";
      }
    )
    (
      fetchNuGet {
        name = "netstandard.library";
        version = "2.0.3";
        url = "https://api.nuget.org/v3-flatcontainer/netstandard.library/2.0.3/netstandard.library.2.0.3.nupkg";
        sha256 = "1fn9fxppfcg4jgypp2pmrpr6awl3qz1xmnri0cygpkwvyx27df1y";
      }
    )
    (
      fetchNuGet {
        name = "newtonsoft.json";
        version = "13.0.3";
        url = "https://api.nuget.org/v3-flatcontainer/newtonsoft.json/13.0.3/newtonsoft.json.13.0.3.nupkg";
        sha256 = "0xrwysmrn4midrjal8g2hr1bbg38iyisl0svamb11arqws4w2bw7";
      }
    )
    (
      fetchNuGet {
        name = "nuget.common";
        version = "6.8.0";
        url = "https://api.nuget.org/v3-flatcontainer/nuget.common/6.8.0/nuget.common.6.8.0.nupkg";
        sha256 = "0l3ij8iwy7wj6s7f93lzi9168r4wz8zyin6a08iwgk7hvq44cia1";
      }
    )
    (
      fetchNuGet {
        name = "nuget.configuration";
        version = "6.8.0";
        url = "https://api.nuget.org/v3-flatcontainer/nuget.configuration/6.8.0/nuget.configuration.6.8.0.nupkg";
        sha256 = "0x03p408smkmv1gv7pmvsia4lkn0xaj4wfrkl58pjf8bbv51y0yw";
      }
    )
    (
      fetchNuGet {
        name = "nuget.frameworks";
        version = "6.8.0";
        url = "https://api.nuget.org/v3-flatcontainer/nuget.frameworks/6.8.0/nuget.frameworks.6.8.0.nupkg";
        sha256 = "0i2xvhgkjkjr496i3pg8hamwv6505fia45qhn7jg5m01wb3cvsjl";
      }
    )
    (
      fetchNuGet {
        name = "nuget.packaging";
        version = "6.8.0";
        url = "https://api.nuget.org/v3-flatcontainer/nuget.packaging/6.8.0/nuget.packaging.6.8.0.nupkg";
        sha256 = "031z4s905bxi94h3f0qy4j1b6jxdxgqgpkzqvvpfxch07szxcbim";
      }
    )
    (
      fetchNuGet {
        name = "nuget.versioning";
        version = "6.8.0";
        url = "https://api.nuget.org/v3-flatcontainer/nuget.versioning/6.8.0/nuget.versioning.6.8.0.nupkg";
        sha256 = "1sd25h46fd12ng780r02q4ijcx1imkb53kj1y2y7cwg5myh537ks";
      }
    )
    (
      fetchNuGet {
        name = "paket.core";
        version = "8.0.3";
        url = "https://api.nuget.org/v3-flatcontainer/paket.core/8.0.3/paket.core.8.0.3.nupkg";
        sha256 = "1ziwk0m90i0x3svhvzgdpssyd7zg7d13rs1glhfrarrx7x79k5fm";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.8-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.debian.8-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.debian.8-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1sdb281bv1pia0z3inmfjip39rn55pqvp5p0znpg5nh443rp9vv6";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.9-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.debian.9-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.debian.9-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "13pm6sb40fvkdyjvmcabr0x7mgixxk5s9qwrhx3a017c0psqxiix";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.23-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.fedora.23-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.fedora.23-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1s85cwdcdcmnglvl6a8q8kam9sysb9xdvy7ly9gv7ffpxg6naqvj";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.24-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.fedora.24-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.fedora.24-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1iqs6ksljjx2m2iywhy7lcx9rc0710npdsijz750g7x5k840zqc5";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.27-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.fedora.27-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.fedora.27-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1bphf0w7gd5amcv0fjcbxf3pv2vl27y2d1v68ac2b9l3v4y6x64c";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.28-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.fedora.28-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.fedora.28-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "18y9vb7w569z8zg9b2m95hhah9gy42widpyy7qg6vb5fxpgirgrn";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system/4.3.1/runtime.native.system.4.3.1.nupkg";
        sha256 = "1jmnni2bfwpmcsg8xawzlmv3xgddvhzpyasmwwbqx4pzry5nfg0k";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.io.compression";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.io.compression/4.1.0/runtime.native.system.io.compression.4.1.0.nupkg";
        sha256 = "0d720z4lzyfcabmmnvh0bnj76ll7djhji2hmfh3h44sdkjnlkknk";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.io.compression";
        version = "4.3.2";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.io.compression/4.3.2/runtime.native.system.io.compression.4.3.2.nupkg";
        sha256 = "1pih9a3405hrpf0bdkrgik4whx7n4rq8i5xzq8yxqxkjdklf81s4";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.net.http";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.net.http/4.3.1/runtime.native.system.net.http.4.3.1.nupkg";
        sha256 = "0inahnrdx97v2944wqs1b6ps6najgajscq551ysq31ick4badjab";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.security.cryptography.apple";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.security.cryptography.apple/4.3.1/runtime.native.system.security.cryptography.apple.4.3.1.nupkg";
        sha256 = "00swk14hmdw42q883wwgn3vjgq9vnr3s3wlnqakp5rj76c191p9j";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.security.cryptography.openssl/4.3.3/runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "0i431bzb3bdb3f7i4js1lg6fl53vcirw69ylnzimsxirqr1a57df";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.13.2-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.opensuse.13.2-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.opensuse.13.2-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "00ziac5cbsak58h6qryq5397m77sv2fbnq35dzq6d6s0zmsm2lai";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.1-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.opensuse.42.1-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.opensuse.42.1-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "0d9f9sz5sbg4cnml95k8fmxr02iym8ja3jdk7c42blqhfmg2hdbd";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.3-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.opensuse.42.3-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.opensuse.42.3-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1r5v6hh2s6dhxnghgl122x2f2n7sjxqym2jyhb0f2c02ysggsqjl";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.system.security.cryptography.apple";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.osx.10.10-x64.runtime.native.system.security.cryptography.apple/4.3.1/runtime.osx.10.10-x64.runtime.native.system.security.cryptography.apple.4.3.1.nupkg";
        sha256 = "1ibps5wbk0xvcgps5ydimci1jzayk5pz666vshscslhz4b6lg517";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.osx.10.10-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.osx.10.10-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "0qvd8fqzx06xjnx8h2dq3w387j89fl5qfrwq0gz77p25ipd0g3gg";
      }
    )
    (
      fetchNuGet {
        name = "runtime.rhel.7-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.rhel.7-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.rhel.7-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1jz7j20iy4dn75x43xwxnz0hsqhx0sajs8zbbckjk9597vapckjy";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.14.04-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.ubuntu.14.04-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.ubuntu.14.04-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "02kv19qdfnb9g1sijm9swnyj8qz1cjds8j5606vw64sxfx39f48x";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.04-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.ubuntu.16.04-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.ubuntu.16.04-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "0c572zac55rblrkwkvzlxg8pvyd4cxvz3p7rv2v4gdjjmna6yyv5";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.10-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.ubuntu.16.10-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.ubuntu.16.10-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "1bal0x5w3di961hlqbwxrwshqrxrq3s9krfnnxpmq67xrcn9kv29";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.18.04-x64.runtime.native.system.security.cryptography.openssl";
        version = "4.3.3";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.ubuntu.18.04-x64.runtime.native.system.security.cryptography.openssl/4.3.3/runtime.ubuntu.18.04-x64.runtime.native.system.security.cryptography.openssl.4.3.3.nupkg";
        sha256 = "0vs408583zin8m3aa1iblkgliqfxx67d6876bqw553qhdxpba4ff";
      }
    )
    (
      fetchNuGet {
        name = "system.appcontext";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.appcontext/4.1.0/system.appcontext.4.1.0.nupkg";
        sha256 = "0fv3cma1jp4vgj7a8hqc9n7hr1f1kjp541s6z0q1r6nazb4iz9mz";
      }
    )
    (
      fetchNuGet {
        name = "system.appcontext";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.appcontext/4.3.0/system.appcontext.4.3.0.nupkg";
        sha256 = "1649qvy3dar900z3g817h17nl8jp4ka5vcfmsr05kh0fshn7j3ya";
      }
    )
    (
      fetchNuGet {
        name = "system.buffers";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.buffers/4.0.0/system.buffers.4.0.0.nupkg";
        sha256 = "13s659bcmg9nwb6z78971z1lr6bmh2wghxi1ayqyzl4jijd351gr";
      }
    )
    (
      fetchNuGet {
        name = "system.buffers";
        version = "4.5.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.buffers/4.5.1/system.buffers.4.5.1.nupkg";
        sha256 = "04kb1mdrlcixj9zh1xdi5as0k0qi8byr5mi3p3jcxx72qz93s2y3";
      }
    )
    (
      fetchNuGet {
        name = "system.collections";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections/4.3.0/system.collections.4.3.0.nupkg";
        sha256 = "19r4y64dqyrq6k4706dnyhhw7fs24kpp3awak7whzss39dakpxk9";
      }
    )
    (
      fetchNuGet {
        name = "system.collections.concurrent";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.concurrent/4.3.0/system.collections.concurrent.4.3.0.nupkg";
        sha256 = "0wi10md9aq33jrkh2c24wr2n9hrpyamsdhsxdcnf43b7y86kkii8";
      }
    )
    (
      fetchNuGet {
        name = "system.collections.nongeneric";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.nongeneric/4.3.0/system.collections.nongeneric.4.3.0.nupkg";
        sha256 = "07q3k0hf3mrcjzwj8fwk6gv3n51cb513w4mgkfxzm3i37sc9kz7k";
      }
    )
    (
      fetchNuGet {
        name = "system.collections.specialized";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.specialized/4.3.0/system.collections.specialized.4.3.0.nupkg";
        sha256 = "1sdwkma4f6j85m3dpb53v9vcgd0zyc9jb33f8g63byvijcj39n20";
      }
    )
    (
      fetchNuGet {
        name = "system.componentmodel";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.componentmodel/4.3.0/system.componentmodel.4.3.0.nupkg";
        sha256 = "0986b10ww3nshy30x9sjyzm0jx339dkjxjj3401r3q0f6fx2wkcb";
      }
    )
    (
      fetchNuGet {
        name = "system.componentmodel.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.componentmodel.primitives/4.3.0/system.componentmodel.primitives.4.3.0.nupkg";
        sha256 = "1svfmcmgs0w0z9xdw2f2ps05rdxmkxxhf0l17xk9l1l8xfahkqr0";
      }
    )
    (
      fetchNuGet {
        name = "system.componentmodel.typeconverter";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.componentmodel.typeconverter/4.3.0/system.componentmodel.typeconverter.4.3.0.nupkg";
        sha256 = "17ng0p7v3nbrg3kycz10aqrrlw4lz9hzhws09pfh8gkwicyy481x";
      }
    )
    (
      fetchNuGet {
        name = "system.configuration.configurationmanager";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.configuration.configurationmanager/8.0.0/system.configuration.configurationmanager.8.0.0.nupkg";
        sha256 = "08dadpd8lx6x7craw3h3444p7ncz4wk0a3j1681lyhhd56ln66f6";
      }
    )
    (
      fetchNuGet {
        name = "system.console";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.console/4.0.0/system.console.4.0.0.nupkg";
        sha256 = "0ynxqbc3z1nwbrc11hkkpw9skw116z4y9wjzn7id49p9yi7mzmlf";
      }
    )
    (
      fetchNuGet {
        name = "system.console";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.console/4.3.1/system.console.4.3.1.nupkg";
        sha256 = "1p4lz47f2r67y5hpv0k26h3hj9amrmhhjad7wrlimb3l39427y7a";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.debug";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.debug/4.3.0/system.diagnostics.debug.4.3.0.nupkg";
        sha256 = "00yjlf19wjydyr6cfviaph3vsjzg3d5nvnya26i2fvfg53sknh3y";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.diagnosticsource";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.diagnosticsource/8.0.0/system.diagnostics.diagnosticsource.8.0.0.nupkg";
        sha256 = "0nzra1i0mljvmnj1qqqg37xs7bl71fnpl68nwmdajchh65l878zr";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.eventlog";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.eventlog/8.0.0/system.diagnostics.eventlog.8.0.0.nupkg";
        sha256 = "1xnvcidh2qf6k7w8ij1rvj0viqkq84cq47biw0c98xhxg5rk3pxf";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.tools";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tools/4.0.1/system.diagnostics.tools.4.0.1.nupkg";
        sha256 = "19cknvg07yhakcvpxg3cxa0bwadplin6kyxd8mpjjpwnp56nl85x";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.tools";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tools/4.3.0/system.diagnostics.tools.4.3.0.nupkg";
        sha256 = "0in3pic3s2ddyibi8cvgl102zmvp9r9mchh82ns9f0ms4basylw1";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.tracing";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tracing/4.3.0/system.diagnostics.tracing.4.3.0.nupkg";
        sha256 = "1m3bx6c2s958qligl67q7grkwfz3w53hpy7nc97mh6f7j5k168c4";
      }
    )
    (
      fetchNuGet {
        name = "system.dynamic.runtime";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.dynamic.runtime/4.3.0/system.dynamic.runtime.4.3.0.nupkg";
        sha256 = "1d951hrvrpndk7insiag80qxjbf2y0y39y8h5hnq9612ws661glk";
      }
    )
    (
      fetchNuGet {
        name = "system.formats.asn1";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.formats.asn1/8.0.0/system.formats.asn1.8.0.0.nupkg";
        sha256 = "04h75wflmzl0qh125p0209wx006rkyxic1y404m606yjvpl2alq1";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization/4.3.0/system.globalization.4.3.0.nupkg";
        sha256 = "1cp68vv683n6ic2zqh2s1fn4c2sd87g5hpp6l4d4nj4536jz98ki";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization.calendars";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization.calendars/4.3.0/system.globalization.calendars.4.3.0.nupkg";
        sha256 = "1xwl230bkakzzkrggy1l1lxmm3xlhk4bq2pkv790j5lm8g887lxq";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization.extensions";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization.extensions/4.3.0/system.globalization.extensions.4.3.0.nupkg";
        sha256 = "02a5zfxavhv3jd437bsncbhd2fp1zv4gxzakp1an9l6kdq1mcqls";
      }
    )
    (
      fetchNuGet {
        name = "system.io";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io/4.3.0/system.io.4.3.0.nupkg";
        sha256 = "05l9qdrzhm4s5dixmx68kxwif4l99ll5gqmh7rqgw554fx0agv5f";
      }
    )
    (
      fetchNuGet {
        name = "system.io.compression";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression/4.1.0/system.io.compression.4.1.0.nupkg";
        sha256 = "0iym7s3jkl8n0vzm3jd6xqg9zjjjqni05x45dwxyjr2dy88hlgji";
      }
    )
    (
      fetchNuGet {
        name = "system.io.compression";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression/4.3.0/system.io.compression.4.3.0.nupkg";
        sha256 = "084zc82yi6yllgda0zkgl2ys48sypiswbiwrv7irb3r0ai1fp4vz";
      }
    )
    (
      fetchNuGet {
        name = "system.io.compression.zipfile";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression.zipfile/4.0.1/system.io.compression.zipfile.4.0.1.nupkg";
        sha256 = "0h72znbagmgvswzr46mihn7xm7chfk2fhrp5krzkjf29pz0i6z82";
      }
    )
    (
      fetchNuGet {
        name = "system.io.compression.zipfile";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression.zipfile/4.3.0/system.io.compression.zipfile.4.3.0.nupkg";
        sha256 = "1yxy5pq4dnsm9hlkg9ysh5f6bf3fahqqb6p8668ndy5c0lk7w2ar";
      }
    )
    (
      fetchNuGet {
        name = "system.io.filesystem";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem/4.3.0/system.io.filesystem.4.3.0.nupkg";
        sha256 = "0z2dfrbra9i6y16mm9v1v6k47f0fm617vlb7s5iybjjsz6g1ilmw";
      }
    )
    (
      fetchNuGet {
        name = "system.io.filesystem.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem.primitives/4.3.0/system.io.filesystem.primitives.4.3.0.nupkg";
        sha256 = "0j6ndgglcf4brg2lz4wzsh1av1gh8xrzdsn9f0yznskhqn1xzj9c";
      }
    )
    (
      fetchNuGet {
        name = "system.linq";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq/4.3.0/system.linq.4.3.0.nupkg";
        sha256 = "1w0gmba695rbr80l1k2h4mrwzbzsyfl2z4klmpbsvsg5pm4a56s7";
      }
    )
    (
      fetchNuGet {
        name = "system.linq.expressions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq.expressions/4.1.0/system.linq.expressions.4.1.0.nupkg";
        sha256 = "1gpdxl6ip06cnab7n3zlcg6mqp7kknf73s8wjinzi4p0apw82fpg";
      }
    )
    (
      fetchNuGet {
        name = "system.linq.expressions";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq.expressions/4.3.0/system.linq.expressions.4.3.0.nupkg";
        sha256 = "0ky2nrcvh70rqq88m9a5yqabsl4fyd17bpr63iy2mbivjs2nyypv";
      }
    )
    (
      fetchNuGet {
        name = "system.memory";
        version = "4.5.5";
        url = "https://api.nuget.org/v3-flatcontainer/system.memory/4.5.5/system.memory.4.5.5.nupkg";
        sha256 = "08jsfwimcarfzrhlyvjjid61j02irx6xsklf32rv57x2aaikvx0h";
      }
    )
    (
      fetchNuGet {
        name = "system.net.http";
        version = "4.3.4";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http/4.3.4/system.net.http.4.3.4.nupkg";
        sha256 = "0kdp31b8819v88l719j6my0yas6myv9d1viql3qz5577mv819jhl";
      }
    )
    (
      fetchNuGet {
        name = "system.net.http.winhttphandler";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http.winhttphandler/8.0.0/system.net.http.winhttphandler.8.0.0.nupkg";
        sha256 = "0lqg9zfqcz18r34sgz7x50dsxbikh0lp8pdkb1y3m55gslmbj8n1";
      }
    )
    (
      fetchNuGet {
        name = "system.net.primitives";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.primitives/4.3.1/system.net.primitives.4.3.1.nupkg";
        sha256 = "1hxsc1d1vfakfqifsg7y0d95l3n0iirz36r76ngw859r1a6qb058";
      }
    )
    (
      fetchNuGet {
        name = "system.net.sockets";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.sockets/4.1.0/system.net.sockets.4.1.0.nupkg";
        sha256 = "1385fvh8h29da5hh58jm1v78fzi9fi5vj93vhlm2kvqpfahvpqls";
      }
    )
    (
      fetchNuGet {
        name = "system.net.sockets";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.sockets/4.3.0/system.net.sockets.4.3.0.nupkg";
        sha256 = "1ssa65k6chcgi6mfmzrznvqaxk8jp0gvl77xhf1hbzakjnpxspla";
      }
    )
    (
      fetchNuGet {
        name = "system.numerics.vectors";
        version = "4.5.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.numerics.vectors/4.5.0/system.numerics.vectors.4.5.0.nupkg";
        sha256 = "1kzrj37yzawf1b19jq0253rcs8hsq1l2q8g69d7ipnhzb0h97m59";
      }
    )
    (
      fetchNuGet {
        name = "system.objectmodel";
        version = "4.0.12";
        url = "https://api.nuget.org/v3-flatcontainer/system.objectmodel/4.0.12/system.objectmodel.4.0.12.nupkg";
        sha256 = "1sybkfi60a4588xn34nd9a58png36i0xr4y4v4kqpg8wlvy5krrj";
      }
    )
    (
      fetchNuGet {
        name = "system.objectmodel";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.objectmodel/4.3.0/system.objectmodel.4.3.0.nupkg";
        sha256 = "191p63zy5rpqx7dnrb3h7prvgixmk168fhvvkkvhlazncf8r3nc2";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection/4.3.0/system.reflection.4.3.0.nupkg";
        sha256 = "0xl55k0mw8cd8ra6dxzh974nxif58s3k1rjv1vbd7gjbjr39j11m";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit/4.0.1/system.reflection.emit.4.0.1.nupkg";
        sha256 = "0ydqcsvh6smi41gyaakglnv252625hf29f7kywy2c70nhii2ylqp";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit/4.7.0/system.reflection.emit.4.7.0.nupkg";
        sha256 = "121l1z2ypwg02yz84dy6gr82phpys0njk7yask3sihgy214w43qp";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit.ilgeneration";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.ilgeneration/4.0.1/system.reflection.emit.ilgeneration.4.0.1.nupkg";
        sha256 = "1pcd2ig6bg144y10w7yxgc9d22r7c7ww7qn1frdfwgxr24j9wvv0";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit.ilgeneration";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.ilgeneration/4.7.0/system.reflection.emit.ilgeneration.4.7.0.nupkg";
        sha256 = "0l8jpxhpgjlf1nkz5lvp61r4kfdbhr29qi8aapcxn3izd9wd0j8r";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit.lightweight";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.lightweight/4.0.1/system.reflection.emit.lightweight.4.0.1.nupkg";
        sha256 = "1s4b043zdbx9k39lfhvsk68msv1nxbidhkq6nbm27q7sf8xcsnxr";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.emit.lightweight";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.lightweight/4.7.0/system.reflection.emit.lightweight.4.7.0.nupkg";
        sha256 = "0mbjfajmafkca47zr8v36brvknzks5a7pgb49kfq2d188pyv6iap";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.extensions";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.extensions/4.0.1/system.reflection.extensions.4.0.1.nupkg";
        sha256 = "0m7wqwq0zqq9gbpiqvgk3sr92cbrw7cp3xn53xvw7zj6rz6fdirn";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.extensions";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.extensions/4.3.0/system.reflection.extensions.4.3.0.nupkg";
        sha256 = "02bly8bdc98gs22lqsfx9xicblszr2yan7v2mmw3g7hy6miq5hwq";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.primitives/4.3.0/system.reflection.primitives.4.3.0.nupkg";
        sha256 = "04xqa33bld78yv5r93a8n76shvc8wwcdgr1qvvjh959g3rc31276";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.typeextensions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.typeextensions/4.1.0/system.reflection.typeextensions.4.1.0.nupkg";
        sha256 = "1bjli8a7sc7jlxqgcagl9nh8axzfl11f4ld3rjqsyxc516iijij7";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.typeextensions";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.typeextensions/4.7.0/system.reflection.typeextensions.4.7.0.nupkg";
        sha256 = "04qw9km34pmzr2alckb3mqdb4fpqwlvzk59lg8c7jfidghcl4jqq";
      }
    )
    (
      fetchNuGet {
        name = "system.resources.resourcemanager";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.resources.resourcemanager/4.3.0/system.resources.resourcemanager.4.3.0.nupkg";
        sha256 = "0sjqlzsryb0mg4y4xzf35xi523s4is4hz9q4qgdvlvgivl7qxn49";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime/4.3.1/system.runtime.4.3.1.nupkg";
        sha256 = "03ch4d2acf6q037a4njxpll2kkx3dwzlg07yxr4z5m6j1kqgmm27";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.compilerservices.unsafe";
        version = "6.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.compilerservices.unsafe/6.0.0/system.runtime.compilerservices.unsafe.6.0.0.nupkg";
        sha256 = "0qm741kh4rh57wky16sq4m0v05fxmkjjr87krycf5vp9f0zbahbc";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.extensions";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.extensions/4.3.1/system.runtime.extensions.4.3.1.nupkg";
        sha256 = "1bzkwqm1yhvm70yq2bx2s3mqfx2lr01sqsay8cl5n5xcbq07ynf6";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.handles";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.handles/4.3.0/system.runtime.handles.4.3.0.nupkg";
        sha256 = "0sw2gfj2xr7sw9qjn0j3l9yw07x73lcs97p8xfc9w1x9h5g5m7i8";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.interopservices";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices/4.3.0/system.runtime.interopservices.4.3.0.nupkg";
        sha256 = "00hywrn4g7hva1b2qri2s6rabzwgxnbpw9zfxmz28z09cpwwgh7j";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.interopservices.runtimeinformation";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices.runtimeinformation/4.0.0/system.runtime.interopservices.runtimeinformation.4.0.0.nupkg";
        sha256 = "0glmvarf3jz5xh22iy3w9v3wyragcm4hfdr17v90vs7vcrm7fgp6";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.interopservices.runtimeinformation";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices.runtimeinformation/4.3.0/system.runtime.interopservices.runtimeinformation.4.3.0.nupkg";
        sha256 = "0q18r1sh4vn7bvqgd6dmqlw5v28flbpj349mkdish2vjyvmnb2ii";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.numerics";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.numerics/4.3.0/system.runtime.numerics.4.3.0.nupkg";
        sha256 = "19rav39sr5dky7afygh309qamqqmi9kcwvz3i0c5700v0c5cg61z";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.serialization.formatters";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.serialization.formatters/4.3.0/system.runtime.serialization.formatters.4.3.0.nupkg";
        sha256 = "114j35n8gcvn3sqv9ar36r1jjq0y1yws9r0yk8i6wm4aq7n9rs0m";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.serialization.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.serialization.primitives/4.3.0/system.runtime.serialization.primitives.4.3.0.nupkg";
        sha256 = "01vv2p8h4hsz217xxs0rixvb7f2xzbh6wv1gzbfykcbfrza6dvnf";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.algorithms";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.algorithms/4.3.1/system.security.cryptography.algorithms.4.3.1.nupkg";
        sha256 = "1m2wnzg3m3c0s11jg4lshcl2a47d78zri8khc21yrz34jjkbyls2";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.cng";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.cng/4.3.0/system.security.cryptography.cng.4.3.0.nupkg";
        sha256 = "1k468aswafdgf56ab6yrn7649kfqx2wm9aslywjam1hdmk5yypmv";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.cng";
        version = "5.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.cng/5.0.0/system.security.cryptography.cng.5.0.0.nupkg";
        sha256 = "06hkx2za8jifpslkh491dfwzm5dxrsyxzj5lsc0achb6yzg4zqlw";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.csp";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.csp/4.3.0/system.security.cryptography.csp.4.3.0.nupkg";
        sha256 = "1x5wcrddf2s3hb8j78cry7yalca4lb5vfnkrysagbn6r9x6xvrx1";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.encoding";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.encoding/4.3.0/system.security.cryptography.encoding.4.3.0.nupkg";
        sha256 = "1jr6w70igqn07k5zs1ph6xja97hxnb3mqbspdrff6cvssgrixs32";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.openssl";
        version = "5.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.openssl/5.0.0/system.security.cryptography.openssl.5.0.0.nupkg";
        sha256 = "0wahqrzf2sfl26qv0syymxjxx1s5p5ris1kvliqnwkv45baz16na";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.pkcs";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.pkcs/8.0.0/system.security.cryptography.pkcs.8.0.0.nupkg";
        sha256 = "04kqf1lhsq3fngiljanmrz2774x5h2fc8p57v04c51jwwqhwi9ya";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.primitives";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.primitives/4.3.0/system.security.cryptography.primitives.4.3.0.nupkg";
        sha256 = "0pyzncsv48zwly3lw4f2dayqswcfvdwq2nz0dgwmi7fj3pn64wby";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.protecteddata";
        version = "8.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.protecteddata/8.0.0/system.security.cryptography.protecteddata.8.0.0.nupkg";
        sha256 = "1ysjx3b5ips41s32zacf4vs7ig41906mxrsbmykdzi0hvdmjkgbx";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.x509certificates";
        version = "4.3.2";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.x509certificates/4.3.2/system.security.cryptography.x509certificates.4.3.2.nupkg";
        sha256 = "0bfazl3gsas055ixxxkcl113w24b2a3i4flzsxpv14d2ias80imj";
      }
    )
    (
      fetchNuGet {
        name = "system.text.encoding";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding/4.3.0/system.text.encoding.4.3.0.nupkg";
        sha256 = "1f04lkir4iladpp51sdgmis9dj4y8v08cka0mbmsy0frc9a4gjqr";
      }
    )
    (
      fetchNuGet {
        name = "system.text.encoding.extensions";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding.extensions/4.0.11/system.text.encoding.extensions.4.0.11.nupkg";
        sha256 = "08nsfrpiwsg9x5ml4xyl3zyvjfdi4mvbqf93kjdh11j4fwkznizs";
      }
    )
    (
      fetchNuGet {
        name = "system.text.encoding.extensions";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding.extensions/4.3.0/system.text.encoding.extensions.4.3.0.nupkg";
        sha256 = "11q1y8hh5hrp5a3kw25cb6l00v5l5dvirkz8jr3sq00h1xgcgrxy";
      }
    )
    (
      fetchNuGet {
        name = "system.text.regularexpressions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.regularexpressions/4.1.0/system.text.regularexpressions.4.1.0.nupkg";
        sha256 = "1mw7vfkkyd04yn2fbhm38msk7dz2xwvib14ygjsb8dq2lcvr18y7";
      }
    )
    (
      fetchNuGet {
        name = "system.text.regularexpressions";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.regularexpressions/4.3.1/system.text.regularexpressions.4.3.1.nupkg";
        sha256 = "1hr4qqzrij3y2ayi8jj70yfg0i9imf6fpdam1gr8qgp795kh86qg";
      }
    )
    (
      fetchNuGet {
        name = "system.threading";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading/4.3.0/system.threading.4.3.0.nupkg";
        sha256 = "0rw9wfamvhayp5zh3j7p1yfmx9b5khbf4q50d8k5rk993rskfd34";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.tasks";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks/4.3.0/system.threading.tasks.4.3.0.nupkg";
        sha256 = "134z3v9abw3a6jsw17xl3f6hqjpak5l682k2vz39spj4kmydg6k7";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.tasks.extensions";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks.extensions/4.0.0/system.threading.tasks.extensions.4.0.0.nupkg";
        sha256 = "1cb51z062mvc2i8blpzmpn9d9mm4y307xrwi65di8ri18cz5r1zr";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.tasks.extensions";
        version = "4.5.4";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks.extensions/4.5.4/system.threading.tasks.extensions.4.5.4.nupkg";
        sha256 = "0y6ncasgfcgnjrhynaf0lwpkpkmv4a07sswwkwbwb5h7riisj153";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.timer";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.timer/4.0.1/system.threading.timer.4.0.1.nupkg";
        sha256 = "15n54f1f8nn3mjcjrlzdg6q3520571y012mx7v991x2fvp73lmg6";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.timer";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.timer/4.3.0/system.threading.timer.4.3.0.nupkg";
        sha256 = "1nx773nsx6z5whv8kaa1wjh037id2f1cxhb69pvgv12hd2b6qs56";
      }
    )
    (
      fetchNuGet {
        name = "system.xml.readerwriter";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.readerwriter/4.0.11/system.xml.readerwriter.4.0.11.nupkg";
        sha256 = "0c6ky1jk5ada9m94wcadih98l6k1fvf6vi7vhn1msjixaha419l5";
      }
    )
    (
      fetchNuGet {
        name = "system.xml.readerwriter";
        version = "4.3.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.readerwriter/4.3.1/system.xml.readerwriter.4.3.1.nupkg";
        sha256 = "15f9vd7r0bxmyv754238bdckfg6sxaa3d4yx71hdzkz9k0mhjcky";
      }
    )
    (
      fetchNuGet {
        name = "system.xml.xdocument";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xdocument/4.0.11/system.xml.xdocument.4.0.11.nupkg";
        sha256 = "0n4lvpqzy9kc7qy1a4acwwd7b7pnvygv895az5640idl2y9zbz18";
      }
    )
    (
      fetchNuGet {
        name = "system.xml.xdocument";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xdocument/4.3.0/system.xml.xdocument.4.3.0.nupkg";
        sha256 = "08h8fm4l77n0nd4i4fk2386y809bfbwqb7ih9d7564ifcxr5ssxd";
      }
    )
    (
      fetchNuGet {
        name = "system.xml.xmldocument";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xmldocument/4.3.0/system.xml.xmldocument.4.3.0.nupkg";
        sha256 = "0bmz1l06dihx52jxjr22dyv5mxv6pj4852lx68grjm7bivhrbfwi";
      }
    )
  ];
  github = [
  ];
}
