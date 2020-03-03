{ fetchurl
, fetchFromGitHub
, stdenv
, lib
, unzip
, dotnet2nix-fetchNuGet ? (
    { url, name, version, ... } @ attrs:
      stdenv.mkDerivation {
        name = name;
        pversion = version;
        phases = [ "buildPhase" ];
        src = fetchurl (
          (
            builtins.removeAttrs attrs [
              "version"
            ]
          ) // {
            inherit name url;
          }
        );
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
        version = "6.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/argu/6.0.0/argu.6.0.0.nupkg";
        sha256 = "1zybqx0ka89s2cxp7y2bc9bfiy9mm3jn8l3593f58z6nshwh3f2j";
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
        version = "1.1.2";
        url = "https://api.nuget.org/v3-flatcontainer/fsharp.collections.parallelseq/1.1.2/fsharp.collections.parallelseq.1.1.2.nupkg";
        sha256 = "042c4iafwhxwrw6wzav4g2vx7nbcaqzbz27nl7dh0xi43a9v6wc7";
      }
    )
    (
      fetchNuGet {
        name = "fsharp.core";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/fsharp.core/4.7.0/fsharp.core.4.7.0.nupkg";
        sha256 = "0j11325gmaaa97jvx6xfl7a5ya86zixjjydjmgj64pdx0rpbi9pd";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.netcore.platforms";
        version = "3.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.platforms/3.1.0/microsoft.netcore.platforms.3.1.0.nupkg";
        sha256 = "1gc1x8f95wk8yhgznkwsg80adk1lc65v9n5rx4yaa4bc5dva0z3j";
      }
    )
    (
      fetchNuGet {
        name = "microsoft.netcore.targets";
        version = "1.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.targets/1.0.1/microsoft.netcore.targets.1.0.1.nupkg";
        sha256 = "0ppdkwy6s9p7x9jix3v4402wb171cdiibq7js7i13nxpdky7074p";
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
        name = "microsoft.win32.systemevents";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.systemevents/4.7.0/microsoft.win32.systemevents.4.7.0.nupkg";
        sha256 = "0pjll2a62hc576hd4wgyasva0lp733yllmk54n37svz5ac7nfz0q";
      }
    )
    (
      fetchNuGet {
        name = "mono.cecil";
        version = "0.11.2";
        url = "https://api.nuget.org/v3-flatcontainer/mono.cecil/0.11.2/mono.cecil.0.11.2.nupkg";
        sha256 = "114idyjaa6npi580d61gvr7i5xfcy5xi2yc1pfr9y82pj5kj7x5a";
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
        version = "12.0.3";
        url = "https://api.nuget.org/v3-flatcontainer/newtonsoft.json/12.0.3/newtonsoft.json.12.0.3.nupkg";
        sha256 = "17dzl305d835mzign8r15vkmav2hq8l6g7942dfjpnzr17wwl89x";
      }
    )
    (
      fetchNuGet {
        name = "paket.core";
        version = "5.242.2";
        url = "https://www.nuget.org/api/v2/package/Paket.Core/5.242.2";
        sha256 = "0q09m3is744isq2h1dwqkip606y2fzvr1mskf91qcwj3g5ik8ijk";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system/4.0.0/runtime.native.system.4.0.0.nupkg";
        sha256 = "1ppk69xk59ggacj9n7g6fyxvzmk1g5p4fkijm0d7xqfkig98qrkf";
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
        name = "runtime.native.system.net.http";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.net.http/4.0.1/runtime.native.system.net.http.4.0.1.nupkg";
        sha256 = "1hgv2bmbaskx77v8glh7waxws973jn4ah35zysnkxmf0196sfxg6";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.system.security.cryptography";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system.security.cryptography/4.0.0/runtime.native.system.security.cryptography.4.0.0.nupkg";
        sha256 = "0k57aa2c3b10wl3hfqbgrl7xq7g8hh3a3ir44b31dn5p61iiw3z9";
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
        name = "system.buffers";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.buffers/4.0.0/system.buffers.4.0.0.nupkg";
        sha256 = "13s659bcmg9nwb6z78971z1lr6bmh2wghxi1ayqyzl4jijd351gr";
      }
    )
    (
      fetchNuGet {
        name = "system.buffers";
        version = "4.5.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.buffers/4.5.0/system.buffers.4.5.0.nupkg";
        sha256 = "1ywfqn4md6g3iilpxjn5dsr0f5lx6z0yvhqp4pgjcamygg73cz2c";
      }
    )
    (
      fetchNuGet {
        name = "system.collections";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections/4.0.11/system.collections.4.0.11.nupkg";
        sha256 = "1ga40f5lrwldiyw6vy67d0sg7jd7ww6kgwbksm19wrvq9hr0bsm6";
      }
    )
    (
      fetchNuGet {
        name = "system.collections.concurrent";
        version = "4.0.12";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.concurrent/4.0.12/system.collections.concurrent.4.0.12.nupkg";
        sha256 = "07y08kvrzpak873pmyxs129g1ch8l27zmg51pcyj2jvq03n0r0fc";
      }
    )
    (
      fetchNuGet {
        name = "system.configuration.configurationmanager";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.configuration.configurationmanager/4.7.0/system.configuration.configurationmanager.4.7.0.nupkg";
        sha256 = "0pav0n21ghf2ax6fiwjbng29f27wkb4a2ddma0cqx04s97yyk25d";
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
        name = "system.diagnostics.debug";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.debug/4.0.11/system.diagnostics.debug.4.0.11.nupkg";
        sha256 = "0gmjghrqmlgzxivd2xl50ncbglb7ljzb66rlx8ws6dv8jm0d5siz";
      }
    )
    (
      fetchNuGet {
        name = "system.diagnostics.diagnosticsource";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.diagnosticsource/4.0.0/system.diagnostics.diagnosticsource.4.0.0.nupkg";
        sha256 = "1n6c3fbz7v8d3pn77h4v5wvsfrfg7v1c57lg3nff3cjyh597v23m";
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
        name = "system.diagnostics.tracing";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tracing/4.1.0/system.diagnostics.tracing.4.1.0.nupkg";
        sha256 = "1d2r76v1x610x61ahfpigda89gd13qydz6vbwzhpqlyvq8jj6394";
      }
    )
    (
      fetchNuGet {
        name = "system.drawing.common";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.drawing.common/4.7.0/system.drawing.common.4.7.0.nupkg";
        sha256 = "0yfw7cpl54mgfcylvlpvrl0c8r1b0zca6p7r3rcwkvqy23xqcyhg";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization/4.0.11/system.globalization.4.0.11.nupkg";
        sha256 = "070c5jbas2v7smm660zaf1gh0489xanjqymkvafcs4f8cdrs1d5d";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization.calendars";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization.calendars/4.0.1/system.globalization.calendars.4.0.1.nupkg";
        sha256 = "0bv0alrm2ck2zk3rz25lfyk9h42f3ywq77mx1syl6vvyncnpg4qh";
      }
    )
    (
      fetchNuGet {
        name = "system.globalization.extensions";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization.extensions/4.0.1/system.globalization.extensions.4.0.1.nupkg";
        sha256 = "0hjhdb5ri8z9l93bw04s7ynwrjrhx2n0p34sf33a9hl9phz69fyc";
      }
    )
    (
      fetchNuGet {
        name = "system.io";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io/4.1.0/system.io.4.1.0.nupkg";
        sha256 = "1g0yb8p11vfd0kbkyzlfsbsp5z44lwsvyc0h3dpw6vqnbi035ajp";
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
        name = "system.io.compression.zipfile";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression.zipfile/4.0.1/system.io.compression.zipfile.4.0.1.nupkg";
        sha256 = "0h72znbagmgvswzr46mihn7xm7chfk2fhrp5krzkjf29pz0i6z82";
      }
    )
    (
      fetchNuGet {
        name = "system.io.filesystem";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem/4.0.1/system.io.filesystem.4.0.1.nupkg";
        sha256 = "0kgfpw6w4djqra3w5crrg8xivbanh1w9dh3qapb28q060wb9flp1";
      }
    )
    (
      fetchNuGet {
        name = "system.io.filesystem.primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem.primitives/4.0.1/system.io.filesystem.primitives.4.0.1.nupkg";
        sha256 = "1s0mniajj3lvbyf7vfb5shp4ink5yibsx945k6lvxa96r8la1612";
      }
    )
    (
      fetchNuGet {
        name = "system.linq";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq/4.1.0/system.linq.4.1.0.nupkg";
        sha256 = "1ppg83svb39hj4hpp5k7kcryzrf3sfnm08vxd5sm2drrijsla2k5";
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
        name = "system.memory";
        version = "4.5.3";
        url = "https://api.nuget.org/v3-flatcontainer/system.memory/4.5.3/system.memory.4.5.3.nupkg";
        sha256 = "0naqahm3wljxb5a911d37mwjqjdxv9l0b49p5dmfyijvni2ppy8a";
      }
    )
    (
      fetchNuGet {
        name = "system.net.http";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http/4.1.0/system.net.http.4.1.0.nupkg";
        sha256 = "1i5rqij1icg05j8rrkw4gd4pgia1978mqhjzhsjg69lvwcdfg8yb";
      }
    )
    (
      fetchNuGet {
        name = "system.net.http.winhttphandler";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http.winhttphandler/4.7.0/system.net.http.winhttphandler.4.7.0.nupkg";
        sha256 = "0vhd62yqafxjcqibxwaql2r94s96y891b6sm61yj8zzvvym13zrc";
      }
    )
    (
      fetchNuGet {
        name = "system.net.primitives";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.primitives/4.0.11/system.net.primitives.4.0.11.nupkg";
        sha256 = "10xzzaynkzkakp7jai1ik3r805zrqjxiz7vcagchyxs2v26a516r";
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
        name = "system.reflection";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection/4.1.0/system.reflection.4.1.0.nupkg";
        sha256 = "1js89429pfw79mxvbzp8p3q93il6rdff332hddhzi5wqglc4gml9";
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
        name = "system.reflection.emit.ilgeneration";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.ilgeneration/4.0.1/system.reflection.emit.ilgeneration.4.0.1.nupkg";
        sha256 = "1pcd2ig6bg144y10w7yxgc9d22r7c7ww7qn1frdfwgxr24j9wvv0";
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
        name = "system.reflection.extensions";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.extensions/4.0.1/system.reflection.extensions.4.0.1.nupkg";
        sha256 = "0m7wqwq0zqq9gbpiqvgk3sr92cbrw7cp3xn53xvw7zj6rz6fdirn";
      }
    )
    (
      fetchNuGet {
        name = "system.reflection.primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.primitives/4.0.1/system.reflection.primitives.4.0.1.nupkg";
        sha256 = "1bangaabhsl4k9fg8khn83wm6yial8ik1sza7401621jc6jrym28";
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
        name = "system.resources.resourcemanager";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.resources.resourcemanager/4.0.1/system.resources.resourcemanager.4.0.1.nupkg";
        sha256 = "0b4i7mncaf8cnai85jv3wnw6hps140cxz8vylv2bik6wyzgvz7bi";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime/4.1.0/system.runtime.4.1.0.nupkg";
        sha256 = "02hdkgk13rvsd6r9yafbwzss8kr55wnj8d5c7xjnp8gqrwc8sn0m";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.compilerservices.unsafe";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.compilerservices.unsafe/4.7.0/system.runtime.compilerservices.unsafe.4.7.0.nupkg";
        sha256 = "16r6sn4czfjk8qhnz7bnqlyiaaszr0ihinb7mq9zzr1wba257r54";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.extensions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.extensions/4.1.0/system.runtime.extensions.4.1.0.nupkg";
        sha256 = "0rw4rm4vsm3h3szxp9iijc3ksyviwsv6f63dng3vhqyg4vjdkc2z";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.handles";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.handles/4.0.1/system.runtime.handles.4.0.1.nupkg";
        sha256 = "1g0zrdi5508v49pfm3iii2hn6nm00bgvfpjq1zxknfjrxxa20r4g";
      }
    )
    (
      fetchNuGet {
        name = "system.runtime.interopservices";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices/4.1.0/system.runtime.interopservices.4.1.0.nupkg";
        sha256 = "01kxqppx3dr3b6b286xafqilv4s2n0gqvfgzfd4z943ga9i81is1";
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
        name = "system.runtime.numerics";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.numerics/4.0.1/system.runtime.numerics.4.0.1.nupkg";
        sha256 = "1y308zfvy0l5nrn46mqqr4wb4z1xk758pkk8svbz8b5ij7jnv4nn";
      }
    )
    (
      fetchNuGet {
        name = "system.security.accesscontrol";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.accesscontrol/4.7.0/system.security.accesscontrol.4.7.0.nupkg";
        sha256 = "0n0k0w44flkd8j0xw7g3g3vhw7dijfm51f75xkm1qxnbh4y45mpz";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.algorithms";
        version = "4.2.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.algorithms/4.2.0/system.security.cryptography.algorithms.4.2.0.nupkg";
        sha256 = "148s9g5dgm33ri7dnh19s4lgnlxbpwvrw2jnzllq2kijj4i4vs85";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.cng";
        version = "4.2.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.cng/4.2.0/system.security.cryptography.cng.4.2.0.nupkg";
        sha256 = "118jijz446kix20blxip0f0q8mhsh9bz118mwc2ch1p6g7facpzc";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.csp";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.csp/4.0.0/system.security.cryptography.csp.4.0.0.nupkg";
        sha256 = "1cwv8lqj8r15q81d2pz2jwzzbaji0l28xfrpw29kdpsaypm92z2q";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.encoding";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.encoding/4.0.0/system.security.cryptography.encoding.4.0.0.nupkg";
        sha256 = "0a8y1a5wkmpawc787gfmnrnbzdgxmx1a14ax43jf3rj9gxmy3vk4";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.openssl";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.openssl/4.0.0/system.security.cryptography.openssl.4.0.0.nupkg";
        sha256 = "16sx3cig3d0ilvzl8xxgffmxbiqx87zdi8fc73i3i7zjih1a7f4q";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.primitives";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.primitives/4.0.0/system.security.cryptography.primitives.4.0.0.nupkg";
        sha256 = "0i7cfnwph9a10bm26m538h5xcr8b36jscp9sy1zhgifksxz4yixh";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.protecteddata";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.protecteddata/4.7.0/system.security.cryptography.protecteddata.4.7.0.nupkg";
        sha256 = "1s1sh8k10s0apa09c5m2lkavi3ys90y657whg2smb3y8mpkfr5vm";
      }
    )
    (
      fetchNuGet {
        name = "system.security.cryptography.x509certificates";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.x509certificates/4.1.0/system.security.cryptography.x509certificates.4.1.0.nupkg";
        sha256 = "0clg1bv55mfv5dq00m19cp634zx6inm31kf8ppbq1jgyjf2185dh";
      }
    )
    (
      fetchNuGet {
        name = "system.security.permissions";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.permissions/4.7.0/system.security.permissions.4.7.0.nupkg";
        sha256 = "13f366sj36jwbvld957gk2q64k2xbj48r8b0k9avrri2nlq1fs04";
      }
    )
    (
      fetchNuGet {
        name = "system.security.principal.windows";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.principal.windows/4.7.0/system.security.principal.windows.4.7.0.nupkg";
        sha256 = "1a56ls5a9sr3ya0nr086sdpa9qv0abv31dd6fp27maqa9zclqq5d";
      }
    )
    (
      fetchNuGet {
        name = "system.text.encoding";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding/4.0.11/system.text.encoding.4.0.11.nupkg";
        sha256 = "1dyqv0hijg265dwxg6l7aiv74102d6xjiwplh2ar1ly6xfaa4iiw";
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
        name = "system.text.regularexpressions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.regularexpressions/4.1.0/system.text.regularexpressions.4.1.0.nupkg";
        sha256 = "1mw7vfkkyd04yn2fbhm38msk7dz2xwvib14ygjsb8dq2lcvr18y7";
      }
    )
    (
      fetchNuGet {
        name = "system.threading";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading/4.0.11/system.threading.4.0.11.nupkg";
        sha256 = "19x946h926bzvbsgj28csn46gak2crv2skpwsx80hbgazmkgb1ls";
      }
    )
    (
      fetchNuGet {
        name = "system.threading.tasks";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks/4.0.11/system.threading.tasks.4.0.11.nupkg";
        sha256 = "0nr1r41rak82qfa5m0lhk9mp0k93bvfd7bbd9sdzwx9mb36g28p5";
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
        name = "system.threading.timer";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.timer/4.0.1/system.threading.timer.4.0.1.nupkg";
        sha256 = "15n54f1f8nn3mjcjrlzdg6q3520571y012mx7v991x2fvp73lmg6";
      }
    )
    (
      fetchNuGet {
        name = "system.windows.extensions";
        version = "4.7.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.windows.extensions/4.7.0/system.windows.extensions.4.7.0.nupkg";
        sha256 = "11dmyx3j0jafjx5r9mkj1v4w2a4rzrdn8fgwm2d1g7fs1ayqcvy9";
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
        name = "system.xml.xdocument";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xdocument/4.0.11/system.xml.xdocument.4.0.11.nupkg";
        sha256 = "0n4lvpqzy9kc7qy1a4acwwd7b7pnvygv895az5640idl2y9zbz18";
      }
    )
  ];
  github = [
  ];
}
