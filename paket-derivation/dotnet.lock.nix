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
        name = "0x53A.ReferenceAssemblies.Paket";
        version = "0.2.0";
        url = "https://www.nuget.org/api/v2/package/0x53A.ReferenceAssemblies.Paket/0.2.0";
        sha256 = "01b6h99x6pmv2clpcwy53qs95zfkj1k4kv25hl3z79p1sizcr19c";
      }
    )
    (
      fetchNuGet {
        name = "Argu";
        version = "5.1.0";
        url = "https://www.nuget.org/api/v2/package/Argu/5.1.0";
        sha256 = "1d36hkkxac0p68bkyhis0qds7p3q8xa9gj9hkdxwjdaccpvg0s7j";
      }
    )
    (
      fetchNuGet {
        name = "Castle.Core";
        version = "4.1.1";
        url = "https://www.nuget.org/api/v2/package/Castle.Core/4.1.1";
        sha256 = "0igabnpdv7n7d1dqc2m7gi6jr85zr3rw8kn29sdchghha7bk1wf3";
      }
    )
    (
      fetchNuGet {
        name = "Chessie";
        version = "0.6.0";
        url = "https://www.nuget.org/api/v2/package/Chessie/0.6.0";
        sha256 = "1qz7ynwmglqwgsvjxkv9ps3b834psvldbvpk4420ii5bzqp4dsvk";
      }
    )
    (
      fetchNuGet {
        name = "FAKE";
        version = "4.64.17";
        url = "https://www.nuget.org/api/v2/package/FAKE/4.64.17";
        sha256 = "0hwq81gkc5gjljci75rrxff3ikjgm8nzqmgsc19gb600n11g30vc";
      }
    )
    (
      fetchNuGet {
        name = "FSharp.Compiler.Service";
        version = "17.0.1";
        url = "https://www.nuget.org/api/v2/package/FSharp.Compiler.Service/17.0.1";
        sha256 = "1ad43vwfm355nfnm2blcmf055b7x1zf7z0ypyza3vs1ka7a4z8ql";
      }
    )
    (
      fetchNuGet {
        name = "FSharp.Core";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/FSharp.Core/4.3.4";
        sha256 = "1sg6i4q5nwyzh769g76f6c16876nvdpn83adqjr2y9x6xsiv5p5j";
      }
    )
    (
      fetchNuGet {
        name = "FSharp.Formatting";
        version = "3.0.0-beta09";
        url = "https://ci.appveyor.com/nuget/fsharp-formatting/api/v2/package/FSharp.Formatting/3.0.0-beta09";
        sha256 = "1x6366037f6czrj8vdhw1adzdzvk7k47jc4kdf0fkp0v312v9y7r";
      }
    )
    (
      fetchNuGet {
        name = "FsCheck";
        version = "2.9.0";
        url = "https://www.nuget.org/api/v2/package/FsCheck/2.9.0";
        sha256 = "1y083ljhsgvriizpbc92bbmjcz867p7i3gwml15gdj3sxbyi4sfh";
      }
    )
    (
      fetchNuGet {
        name = "ILRepack";
        version = "2.0.18";
        url = "https://www.nuget.org/api/v2/package/ILRepack/2.0.18";
        sha256 = "0l3hhg8frpyn48w3hi76a4i6655rbwapyccf85xj94cjhan209h8";
      }
    )
    (
      fetchNuGet {
        name = "Libuv";
        version = "1.10.0";
        url = "https://www.nuget.org/api/v2/package/Libuv/1.10.0";
        sha256 = "1ly5dkpw3m6cbgncxk5wdvzmiib2q3q4lai6pz8gv3j9a9zszxwg";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.AspNet.Razor";
        version = "3.2.4";
        url = "https://www.nuget.org/api/v2/package/Microsoft.AspNet.Razor/3.2.4";
        sha256 = "025mv2gzif3ifalxxjndwskvs9rcgr3bihsdrxj31xr11qqbz0rr";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Build.Framework";
        version = "15.1.548";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.build.framework/15.1.548/microsoft.build.framework.15.1.548.nupkg";
        sha256 = "1f7p6ry58b70q88frnmiv8wldvir44gxfcgcyj9a7d4zs409fkni";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Build.Framework";
        version = "15.3.409";
        url = "https://www.nuget.org/api/v2/package/Microsoft.Build.Framework/15.3.409";
        sha256 = "1dhanwb9ihbfay85xj7cwn0byzmmdz94hqfi3q6r1ncwdjd8y1s2";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Build.Utilities.Core";
        version = "15.1.548";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.build.utilities.core/15.1.548/microsoft.build.utilities.core.15.1.548.nupkg";
        sha256 = "05jgl7lhdcqzad5indirihvih528xg7ihfpfyzd8dpg68ipbz6ns";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Build.Utilities.Core";
        version = "15.3.409";
        url = "https://www.nuget.org/api/v2/package/Microsoft.Build.Utilities.Core/15.3.409";
        sha256 = "1p8a0l9sxmjj86qha748qjw2s2n07q8mn41mj5r6apjnwl27ywnf";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CSharp";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CSharp/4.4.0";
        sha256 = "1niyzqqfyhvh4zpxn8bcyyldynqlw0rfr1apwry4b3yrdnjh1hhh";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CodeAnalysis.Analyzers";
        version = "2.6.1";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.Analyzers/2.6.1";
        sha256 = "1plk343h9fyxg08b9bcnlqyaq00cbnc1v73pj9nbcyphmgf5bqfp";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CodeAnalysis.CSharp";
        version = "2.9.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.CSharp/2.9.0";
        sha256 = "01d1bmk2nzir51zghmmqr43135g4shyc8lxnsdcdfyaq2pqf35xv";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CodeAnalysis.Common";
        version = "2.9.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.Common/2.9.0";
        sha256 = "1ax3xq04ij5n2xrcb074mincf86g9326ak7pd945w3l9rl5qfvdd";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CodeAnalysis.VisualBasic";
        version = "2.9.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CodeAnalysis.VisualBasic/2.9.0";
        sha256 = "1wcn7p0sil68s01anba5iyc448garw4sz19sfnb0fms372ymfgya";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.CodeCoverage";
        version = "16.4.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.CodeCoverage/16.4.0";
        sha256 = "11dlvcl3p7v9sjnqsfhii7gj4f0mvqv7h5znqxlxgc9cbg7g9vhf";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.DiaSymReader.Native";
        version = "1.7.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.DiaSymReader.Native/1.7.0";
        sha256 = "0l2w3xpr7dpni20mqx41hqdzkrl0k6w9a0wqmjzdqv5f1jrwhfxn";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.DotNet.InternalAbstractions";
        version = "1.0.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.DotNet.InternalAbstractions/1.0.0";
        sha256 = "0mp8ihqlb7fsa789frjzidrfjc1lrhk88qp3xm5qvr7vf4wy4z8x";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NET.Test.Sdk";
        version = "16.2.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NET.Test.Sdk/16.2.0";
        sha256 = "1nr5jxchdy3p7jm4fm73d5yivghjisdsyafma8fs5d1v49bhgckq";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.App";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.app/2.1.0/microsoft.netcore.app.2.1.0.nupkg";
        sha256 = "1qgw6njwz30l5cwkvgf2fbsjqkc9vy0w3939c24iabmvjnzjr6a4";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.App";
        version = "2.1.4";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.App/2.1.4";
        sha256 = "1wvb43y12059r30w4cinqdyvqjhvrgd924vvcab3y5r2m88clw3z";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetAppHost";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnetapphost/2.1.0/microsoft.netcore.dotnetapphost.2.1.0.nupkg";
        sha256 = "10hnhkix2av0c7djp2q88pw407m8gk3im4r06x762a3cs6f2jprd";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetAppHost";
        version = "2.1.4";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.DotNetAppHost/2.1.4";
        sha256 = "12y1nfvq7xk5ri4h9m37as2vfj5mi0c8zpp1c3bbhn51dn326kq5";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetHostPolicy";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethostpolicy/2.1.0/microsoft.netcore.dotnethostpolicy.2.1.0.nupkg";
        sha256 = "1xh8ij7zyfkrk20rgpwqs00mxdy2qiwr7qar2xk397zk2bh2d90n";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetHostPolicy";
        version = "2.1.4";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.DotNetHostPolicy/2.1.4";
        sha256 = "0jwzdpm3grfz0vp0p1x8n2py188nqbwi5jxyrhrxirrfzy688w2m";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetHostResolver";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.dotnethostresolver/2.1.0/microsoft.netcore.dotnethostresolver.2.1.0.nupkg";
        sha256 = "1384k3cg4sjcn3hyalcm43fhmlfj5pnywpzd9zpgc4jsr2c16x76";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.DotNetHostResolver";
        version = "2.1.4";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.DotNetHostResolver/2.1.4";
        sha256 = "0j1yd0rx8hlrs8c5w6l91ab0mp2007prhybkdzwnaih5drsiy20r";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Jit";
        version = "2.0.8";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Jit/2.0.8";
        sha256 = "0mwb7sy5qxl2sxs1djbmqp4mlz7q09s8i05ngv7ark1i15f12bs7";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Platforms";
        version = "1.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.platforms/1.1.0/microsoft.netcore.platforms.1.1.0.nupkg";
        sha256 = "08vh1r12g6ykjygq5d3vq09zylgb84l63k49jc4v8faw9g93iqqm";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Platforms";
        version = "2.0.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Platforms/2.0.0";
        sha256 = "1fk2fk2639i7nzy58m9dvpdnzql4vb8yl8vr19r2fp8lmj9w2jr0";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Platforms";
        version = "2.0.1";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Platforms/2.0.1";
        sha256 = "1j2hmnivgb4plni2dd205kafzg6mkg7r4knrd3s7mg75wn2l25np";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Platforms";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.platforms/2.1.0/microsoft.netcore.platforms.2.1.0.nupkg";
        sha256 = "0nmdnkmwyxj8cp746hs9an57zspqlmqdm55b00i7yk8a22s6akxz";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Platforms";
        version = "2.1.1";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Platforms/2.1.1";
        sha256 = "0lix54wffdfd24hhy9bw7ihlj4gh9ipkslap9gr3nh5wzb1qsqf0";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Runtime.CoreCLR";
        version = "2.0.8";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Runtime.CoreCLR/2.0.8";
        sha256 = "07hg8sq3i3a98dll1k06ng08xkcfyilkmhybx0llzicrkq68ga1f";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Targets";
        version = "1.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.targets/1.1.0/microsoft.netcore.targets.1.1.0.nupkg";
        sha256 = "193xwf33fbm0ni3idxzbr5fdq3i2dlfgihsac9jj7whj0gd902nh";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Targets";
        version = "2.0.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.NETCore.Targets/2.0.0";
        sha256 = "0nsrrhafvxqdx8gmlgsz612bmlll2w3l2qn2ygdzr92rp1nqyka2";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETCore.Targets";
        version = "2.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netcore.targets/2.1.0/microsoft.netcore.targets.2.1.0.nupkg";
        sha256 = "1dav8x5551nwdqfigxf9zfsml5l9lakg86x38s9dvps81xs5d9zq";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETFramework.ReferenceAssemblies";
        version = "1.0.0-preview.2";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netframework.referenceassemblies/1.0.0-preview.2/microsoft.netframework.referenceassemblies.1.0.0-preview.2.nupkg";
        sha256 = "0r28vb05547nbvn9227hxrm0hp4q6dqzliizgi94h6z63bjjlnqj";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.NETFramework.ReferenceAssemblies.net461";
        version = "1.0.0-preview.2";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.netframework.referenceassemblies.net461/1.0.0-preview.2/microsoft.netframework.referenceassemblies.net461.1.0.0-preview.2.nupkg";
        sha256 = "0907wi6agdw8qs9xjly9whka274pvx3mmnlwl0jvav3fwavcih2s";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.TestPlatform.ObjectModel";
        version = "16.4.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.TestPlatform.ObjectModel/16.4.0";
        sha256 = "1alnv3m4mg3ldc2wlfgy4sziz43ah0lsr3db6079c3pwhczm1kj5";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.TestPlatform.TestHost";
        version = "16.4.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.TestPlatform.TestHost/16.4.0";
        sha256 = "0vy3za9xfrqszw18dyxqihrzv0lby03law7l90s0g45i0n7gwfv8";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.VisualBasic";
        version = "10.3.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.VisualBasic/10.3.0";
        sha256 = "1l2351srrbxjvf5kdzid50246fapb957xxiqi8n0caf5wbs8lwzq";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Win32.Primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.primitives/4.0.1/microsoft.win32.primitives.4.0.1.nupkg";
        sha256 = "1n8ap0cmljbqskxpf8fjzn7kh1vvlndsa75k01qig26mbw97k2q7";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Win32.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.Win32.Primitives/4.3.0";
        sha256 = "0j0c1wj4ndj21zsgivsc24whiya605603kxrbiw6wkfdync464wq";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Win32.Registry";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.registry/4.0.0/microsoft.win32.registry.4.0.0.nupkg";
        sha256 = "1spf4m9pikkc19544p29a47qnhcd885klncahz133hbnyqbkmz9k";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Win32.Registry";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/microsoft.win32.registry/4.3.0/microsoft.win32.registry.4.3.0.nupkg";
        sha256 = "1gxyzxam8163vk1kb6xzxjj4iwspjsz9zhgn1w9rjzciphaz0ig7";
      }
    )
    (
      fetchNuGet {
        name = "Microsoft.Win32.Registry";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/Microsoft.Win32.Registry/4.4.0";
        sha256 = "088j2anh1rnkxdcycw5kgp97ahk7cj741y6kask84880835arsb6";
      }
    )
    (
      fetchNuGet {
        name = "Mono.Cecil";
        version = "0.11.1";
        url = "https://www.nuget.org/api/v2/package/Mono.Cecil/0.11.1";
        sha256 = "0c7srz0vqm0npli2ixg9j6x934l0drrng8brwanqh96s1wwaikr7";
      }
    )
    (
      fetchNuGet {
        name = "Moq";
        version = "4.7.99";
        url = "https://www.nuget.org/api/v2/package/Moq/4.7.99";
        sha256 = "06h0vkmjjaifdzciihhx0zy32sxq8kfzf3gvziib7bp6bj2b4883";
      }
    )
    (
      fetchNuGet {
        name = "NETStandard.Library";
        version = "1.6.0";
        url = "https://api.nuget.org/v3-flatcontainer/netstandard.library/1.6.0/netstandard.library.1.6.0.nupkg";
        sha256 = "0nmmv4yw7gw04ik8ialj3ak0j6pxa9spih67hnn1h2c38ba8h58k";
      }
    )
    (
      fetchNuGet {
        name = "NETStandard.Library";
        version = "1.6.1";
        url = "https://api.nuget.org/v3-flatcontainer/netstandard.library/1.6.1/netstandard.library.1.6.1.nupkg";
        sha256 = "1z70wvsx2d847a2cjfii7b83pjfs34q05gb037fdjikv5kbagml8";
      }
    )
    (
      fetchNuGet {
        name = "NETStandard.Library";
        version = "2.0.0";
        url = "https://www.nuget.org/api/v2/package/NETStandard.Library/2.0.0";
        sha256 = "1bc4ba8ahgk15m8k4nd7x406nhi0kwqzbgjk2dmw52ss553xz7iy";
      }
    )
    (
      fetchNuGet {
        name = "NETStandard.Library";
        version = "2.0.1";
        url = "https://www.nuget.org/api/v2/package/NETStandard.Library/2.0.1";
        sha256 = "0d44wjxphs1ck838v7dapm0ag0b91zpiy33cr5vflsrwrqgj51dk";
      }
    )
    (
      fetchNuGet {
        name = "NETStandard.Library";
        version = "2.0.3";
        url = "https://www.nuget.org/api/v2/package/NETStandard.Library/2.0.3";
        sha256 = "1fn9fxppfcg4jgypp2pmrpr6awl3qz1xmnri0cygpkwvyx27df1y";
      }
    )
    (
      fetchNuGet {
        name = "NUnit";
        version = "3.12.0";
        url = "https://www.nuget.org/api/v2/package/NUnit/3.12.0";
        sha256 = "1880j2xwavi8f28vxan3hyvdnph4nlh5sbmh285s4lc9l0b7bdk2";
      }
    )
    (
      fetchNuGet {
        name = "NUnit3TestAdapter";
        version = "3.13.0";
        url = "https://www.nuget.org/api/v2/package/NUnit3TestAdapter/3.13.0";
        sha256 = "1js8kyfhsbhpybyclcqbdr5rrvrckx9vrry2b28mkiv97rm2bqyb";
      }
    )
    (
      fetchNuGet {
        name = "Newtonsoft.Json";
        version = "10.0.3";
        url = "https://www.nuget.org/api/v2/package/Newtonsoft.Json/10.0.3";
        sha256 = "06vy67bkshclpz69kps4vgzc9h2cgg41c8vlqmdbwclfky7c4haq";
      }
    )
    (
      fetchNuGet {
        name = "NuGet.Frameworks";
        version = "5.3.1";
        url = "https://www.nuget.org/api/v2/package/NuGet.Frameworks/5.3.1";
        sha256 = "01cir2lr2w8b3nz0j8lqi38jk883kl5d6p44r3ml6zff0bzv8pdi";
      }
    )
    (
      fetchNuGet {
        name = "Octokit";
        version = "0.29.0";
        url = "https://www.nuget.org/api/v2/package/Octokit/0.29.0";
        sha256 = "1q62w95cj95kff0il9lcjaidgpj3xvh9a6mjy4prrb4j4gm694jb";
      }
    )
    (
      fetchNuGet {
        name = "Paket";
        version = "1.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/paket/1.0.0/paket.1.0.0.nupkg";
        sha256 = "085bi8nihv8q89qiwib9iliz0c5j26fqj53fr28krfisi1zg7kfc";
      }
    )
    (
      fetchNuGet {
        name = "Paket.Core";
        version = "1.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/paket.core/1.0.0/paket.core.1.0.0.nupkg";
        sha256 = "12yxlzw4lk9zh1wss76adp4qcwb8xxcn649x639vgz7xbxz9g687";
      }
    )
    (
      fetchNuGet {
        name = "RoslynTools.MSBuild";
        version = "0.4.0-alpha";
        url = "https://dotnet.myget.org/F/roslyn-tools/api/v2/package/RoslynTools.MSBuild/0.4.0-alpha";
        sha256 = "1zhsr7fy8vngd10xsycml277jw0gj4clssyrk41np6xyfh7zkv26";
      }
    )
    (
      fetchNuGet {
        name = "SourceLink.Create.CommandLine";
        version = "2.1.1";
        url = "https://www.nuget.org/api/v2/package/SourceLink.Create.CommandLine/2.1.1";
        sha256 = "05863f3gdw06vvpkncf2v54giwlz6j69j6k2dv4ybkwsb17l8wns";
      }
    )
    (
      fetchNuGet {
        name = "SourceLink.Embed.PaketFiles";
        version = "2.1.1";
        url = "https://www.nuget.org/api/v2/package/SourceLink.Embed.PaketFiles/2.1.1";
        sha256 = "1fn1ql6hfr33d1np8gm5rcpj5bfxny7pdxb7v7k0clld03hcldjn";
      }
    )
    (
      fetchNuGet {
        name = "System.AppContext";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.appcontext/4.1.0/system.appcontext.4.1.0.nupkg";
        sha256 = "0fv3cma1jp4vgj7a8hqc9n7hr1f1kjp541s6z0q1r6nazb4iz9mz";
      }
    )
    (
      fetchNuGet {
        name = "System.AppContext";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.AppContext/4.3.0";
        sha256 = "1649qvy3dar900z3g817h17nl8jp4ka5vcfmsr05kh0fshn7j3ya";
      }
    )
    (
      fetchNuGet {
        name = "System.Buffers";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Buffers/4.4.0";
        sha256 = "183f8063w8zqn99pv0ni0nnwh7fgx46qzxamwnans55hhs2l0g19";
      }
    )
    (
      fetchNuGet {
        name = "System.Buffers";
        version = "4.5.0";
        url = "https://www.nuget.org/api/v2/package/System.Buffers/4.5.0";
        sha256 = "1ywfqn4md6g3iilpxjn5dsr0f5lx6z0yvhqp4pgjcamygg73cz2c";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections/4.0.11/system.collections.4.0.11.nupkg";
        sha256 = "1ga40f5lrwldiyw6vy67d0sg7jd7ww6kgwbksm19wrvq9hr0bsm6";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections/4.3.0";
        sha256 = "19r4y64dqyrq6k4706dnyhhw7fs24kpp3awak7whzss39dakpxk9";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.Concurrent";
        version = "4.0.12";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.concurrent/4.0.12/system.collections.concurrent.4.0.12.nupkg";
        sha256 = "07y08kvrzpak873pmyxs129g1ch8l27zmg51pcyj2jvq03n0r0fc";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.Concurrent";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections.Concurrent/4.3.0";
        sha256 = "0wi10md9aq33jrkh2c24wr2n9hrpyamsdhsxdcnf43b7y86kkii8";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.Immutable";
        version = "1.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections.Immutable/1.4.0";
        sha256 = "14zwxm2xkp19j0m3xp7p25sbndhlak9g2z19kgl6md2zqkqidjkh";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.Immutable";
        version = "1.5.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections.Immutable/1.5.0";
        sha256 = "1d5gjn5afnrf461jlxzawcvihz195gayqpcfbv6dd7pxa9ialn06";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.NonGeneric";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.collections.nongeneric/4.0.1/system.collections.nongeneric.4.0.1.nupkg";
        sha256 = "19994r5y5bpdhj7di6w047apvil8lh06lh2c2yv9zc4fc5g9bl4d";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.NonGeneric";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections.NonGeneric/4.3.0";
        sha256 = "07q3k0hf3mrcjzwj8fwk6gv3n51cb513w4mgkfxzm3i37sc9kz7k";
      }
    )
    (
      fetchNuGet {
        name = "System.Collections.Specialized";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Collections.Specialized/4.3.0";
        sha256 = "1sdwkma4f6j85m3dpb53v9vcgd0zyc9jb33f8g63byvijcj39n20";
      }
    )
    (
      fetchNuGet {
        name = "System.ComponentModel";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.ComponentModel/4.3.0";
        sha256 = "0986b10ww3nshy30x9sjyzm0jx339dkjxjj3401r3q0f6fx2wkcb";
      }
    )
    (
      fetchNuGet {
        name = "System.ComponentModel.Annotations";
        version = "4.5.0";
        url = "https://www.nuget.org/api/v2/package/System.ComponentModel.Annotations/4.5.0";
        sha256 = "1jj6f6g87k0iwsgmg3xmnn67a14mq88np0l1ys5zkxhkvbc8976p";
      }
    )
    (
      fetchNuGet {
        name = "System.ComponentModel.EventBasedAsync";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.ComponentModel.EventBasedAsync/4.3.0";
        sha256 = "1rv9bkb8yyhqqqrx6x95njv6mdxlbvv527b44mrd93g8fmgkifl7";
      }
    )
    (
      fetchNuGet {
        name = "System.ComponentModel.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.ComponentModel.Primitives/4.3.0";
        sha256 = "1svfmcmgs0w0z9xdw2f2ps05rdxmkxxhf0l17xk9l1l8xfahkqr0";
      }
    )
    (
      fetchNuGet {
        name = "System.ComponentModel.TypeConverter";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.ComponentModel.TypeConverter/4.3.0";
        sha256 = "17ng0p7v3nbrg3kycz10aqrrlw4lz9hzhws09pfh8gkwicyy481x";
      }
    )
    (
      fetchNuGet {
        name = "System.Configuration.ConfigurationManager";
        version = "4.4.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.configuration.configurationmanager/4.4.0/system.configuration.configurationmanager.4.4.0.nupkg";
        sha256 = "1hjgmz47v5229cbzd2pwz2h0dkq78lb2wp9grx8qr72pb5i0dk7v";
      }
    )
    (
      fetchNuGet {
        name = "System.Configuration.ConfigurationManager";
        version = "4.4.1";
        url = "https://www.nuget.org/api/v2/package/System.Configuration.ConfigurationManager/4.4.1";
        sha256 = "0dzg4ljbwi9z97z31p4cp4zlxb27xpqwb19pagfvfk2pxm80ybz2";
      }
    )
    (
      fetchNuGet {
        name = "System.Console";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.console/4.0.0/system.console.4.0.0.nupkg";
        sha256 = "0ynxqbc3z1nwbrc11hkkpw9skw116z4y9wjzn7id49p9yi7mzmlf";
      }
    )
    (
      fetchNuGet {
        name = "System.Console";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Console/4.3.0";
        sha256 = "1flr7a9x920mr5cjsqmsy9wgnv3lvd0h1g521pdr1lkb2qycy7ay";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Debug";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.debug/4.0.11/system.diagnostics.debug.4.0.11.nupkg";
        sha256 = "0gmjghrqmlgzxivd2xl50ncbglb7ljzb66rlx8ws6dv8jm0d5siz";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Debug";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.Debug/4.3.0";
        sha256 = "00yjlf19wjydyr6cfviaph3vsjzg3d5nvnya26i2fvfg53sknh3y";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.DiagnosticSource";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.diagnosticsource/4.0.0/system.diagnostics.diagnosticsource.4.0.0.nupkg";
        sha256 = "1n6c3fbz7v8d3pn77h4v5wvsfrfg7v1c57lg3nff3cjyh597v23m";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.DiagnosticSource";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.diagnosticsource/4.3.0/system.diagnostics.diagnosticsource.4.3.0.nupkg";
        sha256 = "0z6m3pbiy0qw6rn3n209rrzf9x1k4002zh90vwcrsym09ipm2liq";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.DiagnosticSource";
        version = "4.4.1";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.DiagnosticSource/4.4.1";
        sha256 = "135xgv5rwmzi9girb8abnp1xradwy2w3n96j2az7v8j694z3znmi";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.FileVersionInfo";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.FileVersionInfo/4.3.0";
        sha256 = "094hx249lb3vb336q7dg3v257hbxvz2jnalj695l7cg5kxzqwai7";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Process";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.process/4.1.0/system.diagnostics.process.4.1.0.nupkg";
        sha256 = "061lrcs7xribrmq7kab908lww6kn2xn1w3rdc41q189y0jibl19s";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Process";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.Process/4.3.0";
        sha256 = "0g4prsbkygq8m21naqmcp70f24a1ksyix3dihb1r1f71lpi3cfj7";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.StackTrace";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.StackTrace/4.3.0";
        sha256 = "0ash4h9k0m7xsm0yl79r0ixrdz369h7y922wipp5gladmlbvpyjd";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Tools";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tools/4.0.1/system.diagnostics.tools.4.0.1.nupkg";
        sha256 = "19cknvg07yhakcvpxg3cxa0bwadplin6kyxd8mpjjpwnp56nl85x";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Tools";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.Tools/4.3.0";
        sha256 = "0in3pic3s2ddyibi8cvgl102zmvp9r9mchh82ns9f0ms4basylw1";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.TraceSource";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tracesource/4.0.0/system.diagnostics.tracesource.4.0.0.nupkg";
        sha256 = "1mc7r72xznczzf6mz62dm8xhdi14if1h8qgx353xvhz89qyxsa3h";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.TraceSource";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.TraceSource/4.3.0";
        sha256 = "1kyw4d7dpjczhw6634nrmg7yyyzq72k75x38y0l0nwhigdlp1766";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Tracing";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.diagnostics.tracing/4.1.0/system.diagnostics.tracing.4.1.0.nupkg";
        sha256 = "1d2r76v1x610x61ahfpigda89gd13qydz6vbwzhpqlyvq8jj6394";
      }
    )
    (
      fetchNuGet {
        name = "System.Diagnostics.Tracing";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Diagnostics.Tracing/4.3.0";
        sha256 = "1m3bx6c2s958qligl67q7grkwfz3w53hpy7nc97mh6f7j5k168c4";
      }
    )
    (
      fetchNuGet {
        name = "System.Dynamic.Runtime";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Dynamic.Runtime/4.3.0";
        sha256 = "1d951hrvrpndk7insiag80qxjbf2y0y39y8h5hnq9612ws661glk";
      }
    )
    (
      fetchNuGet {
        name = "System.Globalization";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization/4.0.11/system.globalization.4.0.11.nupkg";
        sha256 = "070c5jbas2v7smm660zaf1gh0489xanjqymkvafcs4f8cdrs1d5d";
      }
    )
    (
      fetchNuGet {
        name = "System.Globalization";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Globalization/4.3.0";
        sha256 = "1cp68vv683n6ic2zqh2s1fn4c2sd87g5hpp6l4d4nj4536jz98ki";
      }
    )
    (
      fetchNuGet {
        name = "System.Globalization.Calendars";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.globalization.calendars/4.0.1/system.globalization.calendars.4.0.1.nupkg";
        sha256 = "0bv0alrm2ck2zk3rz25lfyk9h42f3ywq77mx1syl6vvyncnpg4qh";
      }
    )
    (
      fetchNuGet {
        name = "System.Globalization.Calendars";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Globalization.Calendars/4.3.0";
        sha256 = "1xwl230bkakzzkrggy1l1lxmm3xlhk4bq2pkv790j5lm8g887lxq";
      }
    )
    (
      fetchNuGet {
        name = "System.Globalization.Extensions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Globalization.Extensions/4.3.0";
        sha256 = "02a5zfxavhv3jd437bsncbhd2fp1zv4gxzakp1an9l6kdq1mcqls";
      }
    )
    (
      fetchNuGet {
        name = "System.IO";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io/4.1.0/system.io.4.1.0.nupkg";
        sha256 = "1g0yb8p11vfd0kbkyzlfsbsp5z44lwsvyc0h3dpw6vqnbi035ajp";
      }
    )
    (
      fetchNuGet {
        name = "System.IO";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO/4.3.0";
        sha256 = "05l9qdrzhm4s5dixmx68kxwif4l99ll5gqmh7rqgw554fx0agv5f";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.Compression";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression/4.1.0/system.io.compression.4.1.0.nupkg";
        sha256 = "0iym7s3jkl8n0vzm3jd6xqg9zjjjqni05x45dwxyjr2dy88hlgji";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.Compression";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.Compression/4.3.0";
        sha256 = "084zc82yi6yllgda0zkgl2ys48sypiswbiwrv7irb3r0ai1fp4vz";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.Compression.ZipFile";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.compression.zipfile/4.0.1/system.io.compression.zipfile.4.0.1.nupkg";
        sha256 = "0h72znbagmgvswzr46mihn7xm7chfk2fhrp5krzkjf29pz0i6z82";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.Compression.ZipFile";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.Compression.ZipFile/4.3.0";
        sha256 = "1yxy5pq4dnsm9hlkg9ysh5f6bf3fahqqb6p8668ndy5c0lk7w2ar";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.FileSystem";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem/4.0.1/system.io.filesystem.4.0.1.nupkg";
        sha256 = "0kgfpw6w4djqra3w5crrg8xivbanh1w9dh3qapb28q060wb9flp1";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.FileSystem";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.FileSystem/4.3.0";
        sha256 = "0z2dfrbra9i6y16mm9v1v6k47f0fm617vlb7s5iybjjsz6g1ilmw";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.FileSystem.Primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.io.filesystem.primitives/4.0.1/system.io.filesystem.primitives.4.0.1.nupkg";
        sha256 = "1s0mniajj3lvbyf7vfb5shp4ink5yibsx945k6lvxa96r8la1612";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.FileSystem.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.FileSystem.Primitives/4.3.0";
        sha256 = "0j6ndgglcf4brg2lz4wzsh1av1gh8xrzdsn9f0yznskhqn1xzj9c";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.FileSystem.Watcher";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.FileSystem.Watcher/4.3.0";
        sha256 = "1a0gk86r81ldfrsg0x3zm23hkm5kadp5r2zb2k2c08a7dv7qv4m1";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.MemoryMappedFiles";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.MemoryMappedFiles/4.3.0";
        sha256 = "1d2ky89h8mzkzias2cgsyfkx1j2jqi1p1aflyznvdbw8iqh1xj51";
      }
    )
    (
      fetchNuGet {
        name = "System.IO.UnmanagedMemoryStream";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.IO.UnmanagedMemoryStream/4.3.0";
        sha256 = "12vny1flaa75vlcwx58px7qm4rrykr7nb3zxm7ga8q6zhiniqr9y";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq/4.1.0/system.linq.4.1.0.nupkg";
        sha256 = "1ppg83svb39hj4hpp5k7kcryzrf3sfnm08vxd5sm2drrijsla2k5";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Linq/4.3.0";
        sha256 = "1w0gmba695rbr80l1k2h4mrwzbzsyfl2z4klmpbsvsg5pm4a56s7";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq.Expressions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.linq.expressions/4.1.0/system.linq.expressions.4.1.0.nupkg";
        sha256 = "1gpdxl6ip06cnab7n3zlcg6mqp7kknf73s8wjinzi4p0apw82fpg";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq.Expressions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Linq.Expressions/4.3.0";
        sha256 = "0ky2nrcvh70rqq88m9a5yqabsl4fyd17bpr63iy2mbivjs2nyypv";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq.Parallel";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Linq.Parallel/4.3.0";
        sha256 = "0d0ca8cfyxw9jdc493vs1liq318cgx2rdwvjjyl3q6bizbms23qj";
      }
    )
    (
      fetchNuGet {
        name = "System.Linq.Queryable";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Linq.Queryable/4.3.0";
        sha256 = "0vidv9cjwy8scabxd33mm4zl5vql695rz56ydc42m9b731xi2ahj";
      }
    )
    (
      fetchNuGet {
        name = "System.Memory";
        version = "4.5.1";
        url = "https://www.nuget.org/api/v2/package/System.Memory/4.5.1";
        sha256 = "0f07d7hny38lq9w69wx4lxkn4wszrqf9m9js6fh9is645csm167c";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Http";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http/4.1.0/system.net.http.4.1.0.nupkg";
        sha256 = "1i5rqij1icg05j8rrkw4gd4pgia1978mqhjzhsjg69lvwcdfg8yb";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Http";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.http/4.3.0/system.net.http.4.3.0.nupkg";
        sha256 = "1i4gc757xqrzflbk7kc5ksn20kwwfjhw9w7pgdkn19y3cgnl302j";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Http";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/System.Net.Http/4.3.2";
        sha256 = "14gpphr5lgzk25ynzjmi6r50803v14r6gwn6nz0cw4d6r2c5ydm5";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Http";
        version = "4.3.3";
        url = "https://www.nuget.org/api/v2/package/System.Net.Http/4.3.3";
        sha256 = "02a8r520sc6zwrmls9n80j8f22lvx7p3nidjp4w7nh6my3d4lq77";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Http.WinHttpHandler";
        version = "4.5.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.Http.WinHttpHandler/4.5.0";
        sha256 = "0v2fh6gwm44blra23yj419ad4110lzl6i1r0ylb5gjmb3q47w6lh";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.NameResolution";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.NameResolution/4.3.0";
        sha256 = "15r75pwc0rm3vvwsn8rvm2krf929mjfwliv0mpicjnii24470rkq";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Primitives";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.primitives/4.0.11/system.net.primitives.4.0.11.nupkg";
        sha256 = "10xzzaynkzkakp7jai1ik3r805zrqjxiz7vcagchyxs2v26a516r";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.Primitives/4.3.0";
        sha256 = "0c87k50rmdgmxx7df2khd9qj7q35j9rzdmm2572cc55dygmdk3ii";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Requests";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.Requests/4.3.0";
        sha256 = "0pcznmwqqk0qzp0gf4g4xw7arhb0q8v9cbzh3v8h8qp6rjcr339a";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Security";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/System.Net.Security/4.3.1";
        sha256 = "1sf8lv9k64q91cbxkkf3l5c58appcx5ciyp992c933kmbcsasi8f";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Sockets";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.net.sockets/4.1.0/system.net.sockets.4.1.0.nupkg";
        sha256 = "1385fvh8h29da5hh58jm1v78fzi9fi5vj93vhlm2kvqpfahvpqls";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.Sockets";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.Sockets/4.3.0";
        sha256 = "1ssa65k6chcgi6mfmzrznvqaxk8jp0gvl77xhf1hbzakjnpxspla";
      }
    )
    (
      fetchNuGet {
        name = "System.Net.WebHeaderCollection";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Net.WebHeaderCollection/4.3.0";
        sha256 = "0ms3ddjv1wn8sqa5qchm245f3vzzif6l6fx5k92klqpn7zf4z562";
      }
    )
    (
      fetchNuGet {
        name = "System.Numerics.Vectors";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Numerics.Vectors/4.4.0";
        sha256 = "0rdvma399070b0i46c4qq1h2yvjj3k013sqzkilz4bz5cwmx1rba";
      }
    )
    (
      fetchNuGet {
        name = "System.ObjectModel";
        version = "4.0.12";
        url = "https://api.nuget.org/v3-flatcontainer/system.objectmodel/4.0.12/system.objectmodel.4.0.12.nupkg";
        sha256 = "1sybkfi60a4588xn34nd9a58png36i0xr4y4v4kqpg8wlvy5krrj";
      }
    )
    (
      fetchNuGet {
        name = "System.ObjectModel";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.ObjectModel/4.3.0";
        sha256 = "191p63zy5rpqx7dnrb3h7prvgixmk168fhvvkkvhlazncf8r3nc2";
      }
    )
    (
      fetchNuGet {
        name = "System.Private.DataContractSerialization";
        version = "4.1.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.private.datacontractserialization/4.1.1/system.private.datacontractserialization.4.1.1.nupkg";
        sha256 = "1xk9wvgzipssp1393nsg4n16zbr5481k03nkdlj954hzq5jkx89r";
      }
    )
    (
      fetchNuGet {
        name = "System.Private.DataContractSerialization";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Private.DataContractSerialization/4.3.0";
        sha256 = "06fjipqvjp559rrm825x6pll8gimdj9x1n3larigh5hsm584gndw";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection/4.1.0/system.reflection.4.1.0.nupkg";
        sha256 = "1js89429pfw79mxvbzp8p3q93il6rdff332hddhzi5wqglc4gml9";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection/4.3.0";
        sha256 = "0xl55k0mw8cd8ra6dxzh974nxif58s3k1rjv1vbd7gjbjr39j11m";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.DispatchProxy";
        version = "4.5.1";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.DispatchProxy/4.5.1";
        sha256 = "0cdnl4i9mfk7kx2ylglayqwqw7kl5k1xr8siaxch45hfyc2cpds8";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit/4.0.1/system.reflection.emit.4.0.1.nupkg";
        sha256 = "0ydqcsvh6smi41gyaakglnv252625hf29f7kywy2c70nhii2ylqp";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Emit/4.3.0";
        sha256 = "11f8y3qfysfcrscjpjym9msk7lsfxkk4fmz9qq95kn3jd0769f74";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit.ILGeneration";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.ilgeneration/4.0.1/system.reflection.emit.ilgeneration.4.0.1.nupkg";
        sha256 = "1pcd2ig6bg144y10w7yxgc9d22r7c7ww7qn1frdfwgxr24j9wvv0";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit.ILGeneration";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Emit.ILGeneration/4.3.0";
        sha256 = "0w1n67glpv8241vnpz1kl14sy7zlnw414aqwj4hcx5nd86f6994q";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit.Lightweight";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.emit.lightweight/4.0.1/system.reflection.emit.lightweight.4.0.1.nupkg";
        sha256 = "1s4b043zdbx9k39lfhvsk68msv1nxbidhkq6nbm27q7sf8xcsnxr";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Emit.Lightweight";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Emit.Lightweight/4.3.0";
        sha256 = "0ql7lcakycrvzgi9kxz1b3lljd990az1x6c4jsiwcacrvimpib5c";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Extensions";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.extensions/4.0.1/system.reflection.extensions.4.0.1.nupkg";
        sha256 = "0m7wqwq0zqq9gbpiqvgk3sr92cbrw7cp3xn53xvw7zj6rz6fdirn";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Extensions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Extensions/4.3.0";
        sha256 = "02bly8bdc98gs22lqsfx9xicblszr2yan7v2mmw3g7hy6miq5hwq";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Metadata";
        version = "1.5.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Metadata/1.5.0";
        sha256 = "1bqqs9w424cw6an5n0rvd1d9522d50z550fn75g2lysl480gkkn0";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Metadata";
        version = "1.6.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Metadata/1.6.0";
        sha256 = "1wdbavrrkajy7qbdblpbpbalbdl48q3h34cchz24gvdgyrlf15r4";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Primitives";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.primitives/4.0.1/system.reflection.primitives.4.0.1.nupkg";
        sha256 = "1bangaabhsl4k9fg8khn83wm6yial8ik1sza7401621jc6jrym28";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.Primitives/4.3.0";
        sha256 = "04xqa33bld78yv5r93a8n76shvc8wwcdgr1qvvjh959g3rc31276";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.TypeExtensions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.reflection.typeextensions/4.1.0/system.reflection.typeextensions.4.1.0.nupkg";
        sha256 = "1bjli8a7sc7jlxqgcagl9nh8axzfl11f4ld3rjqsyxc516iijij7";
      }
    )
    (
      fetchNuGet {
        name = "System.Reflection.TypeExtensions";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Reflection.TypeExtensions/4.4.0";
        sha256 = "0n9r1w4lp2zmadyqkgp4sk9wy90sj4ygq4dh7kzamx26i9biys5h";
      }
    )
    (
      fetchNuGet {
        name = "System.Resources.Reader";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.resources.reader/4.0.0/system.resources.reader.4.0.0.nupkg";
        sha256 = "1jafi73dcf1lalrir46manq3iy6xnxk2z7gpdpwg4wqql7dv3ril";
      }
    )
    (
      fetchNuGet {
        name = "System.Resources.Reader";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Resources.Reader/4.3.0";
        sha256 = "0lh1hn96d0abwjn7z01gqv3wi58klqhzvwj0gx0sk434wvllp5az";
      }
    )
    (
      fetchNuGet {
        name = "System.Resources.ResourceManager";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.resources.resourcemanager/4.0.1/system.resources.resourcemanager.4.0.1.nupkg";
        sha256 = "0b4i7mncaf8cnai85jv3wnw6hps140cxz8vylv2bik6wyzgvz7bi";
      }
    )
    (
      fetchNuGet {
        name = "System.Resources.ResourceManager";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Resources.ResourceManager/4.3.0";
        sha256 = "0sjqlzsryb0mg4y4xzf35xi523s4is4hz9q4qgdvlvgivl7qxn49";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime/4.1.0/system.runtime.4.1.0.nupkg";
        sha256 = "02hdkgk13rvsd6r9yafbwzss8kr55wnj8d5c7xjnp8gqrwc8sn0m";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime/4.3.0";
        sha256 = "066ixvgbf2c929kgknshcxqj6539ax7b9m570cp8n179cpfkapz7";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.CompilerServices.Unsafe";
        version = "4.5.1";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.CompilerServices.Unsafe/4.5.1";
        sha256 = "1xcrjx5fwg284qdnxyi2d0lzdm5q4frlpkp0nf6vvkx1kdz2prrf";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Extensions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.extensions/4.1.0/system.runtime.extensions.4.1.0.nupkg";
        sha256 = "0rw4rm4vsm3h3szxp9iijc3ksyviwsv6f63dng3vhqyg4vjdkc2z";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Extensions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Extensions/4.3.0";
        sha256 = "1ykp3dnhwvm48nap8q23893hagf665k0kn3cbgsqpwzbijdcgc60";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Handles";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.handles/4.0.1/system.runtime.handles.4.0.1.nupkg";
        sha256 = "1g0zrdi5508v49pfm3iii2hn6nm00bgvfpjq1zxknfjrxxa20r4g";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Handles";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Handles/4.3.0";
        sha256 = "0sw2gfj2xr7sw9qjn0j3l9yw07x73lcs97p8xfc9w1x9h5g5m7i8";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.InteropServices";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices/4.1.0/system.runtime.interopservices.4.1.0.nupkg";
        sha256 = "01kxqppx3dr3b6b286xafqilv4s2n0gqvfgzfd4z943ga9i81is1";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.InteropServices";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.InteropServices/4.3.0";
        sha256 = "00hywrn4g7hva1b2qri2s6rabzwgxnbpw9zfxmz28z09cpwwgh7j";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.InteropServices.RuntimeInformation";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.interopservices.runtimeinformation/4.0.0/system.runtime.interopservices.runtimeinformation.4.0.0.nupkg";
        sha256 = "0glmvarf3jz5xh22iy3w9v3wyragcm4hfdr17v90vs7vcrm7fgp6";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.InteropServices.RuntimeInformation";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.InteropServices.RuntimeInformation/4.3.0";
        sha256 = "0q18r1sh4vn7bvqgd6dmqlw5v28flbpj349mkdish2vjyvmnb2ii";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Loader";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Loader/4.3.0";
        sha256 = "07fgipa93g1xxgf7193a6vw677mpzgr0z0cfswbvqqb364cva8dk";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Numerics";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.numerics/4.0.1/system.runtime.numerics.4.0.1.nupkg";
        sha256 = "1y308zfvy0l5nrn46mqqr4wb4z1xk758pkk8svbz8b5ij7jnv4nn";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Numerics";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Numerics/4.3.0";
        sha256 = "19rav39sr5dky7afygh309qamqqmi9kcwvz3i0c5700v0c5cg61z";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Serialization.Formatters";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Serialization.Formatters/4.3.0";
        sha256 = "114j35n8gcvn3sqv9ar36r1jjq0y1yws9r0yk8i6wm4aq7n9rs0m";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Serialization.Primitives";
        version = "4.1.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.serialization.primitives/4.1.1/system.runtime.serialization.primitives.4.1.1.nupkg";
        sha256 = "042rfjixknlr6r10vx2pgf56yming8lkjikamg3g4v29ikk78h7k";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Serialization.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Serialization.Primitives/4.3.0";
        sha256 = "01vv2p8h4hsz217xxs0rixvb7f2xzbh6wv1gzbfykcbfrza6dvnf";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Serialization.Xml";
        version = "4.1.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.runtime.serialization.xml/4.1.1/system.runtime.serialization.xml.4.1.1.nupkg";
        sha256 = "11747an5gbz821pwahaim3v82gghshnj9b5c4cw539xg5a3gq7rk";
      }
    )
    (
      fetchNuGet {
        name = "System.Runtime.Serialization.Xml";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Runtime.Serialization.Xml/4.3.0";
        sha256 = "1b2cxl2h7s8cydbhbmxhvvq071n9ck61g08npg4gyw7nvg37rfni";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.AccessControl";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.AccessControl/4.4.0";
        sha256 = "0ixqw47krkazsw0ycm22ivkv7dpg6cjz8z8g0ii44bsx4l8gcx17";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Claims";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Claims/4.3.0";
        sha256 = "0jvfn7j22l3mm28qjy3rcw287y9h65ha4m940waaxah07jnbzrhn";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Algorithms";
        version = "4.2.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.algorithms/4.2.0/system.security.cryptography.algorithms.4.2.0.nupkg";
        sha256 = "148s9g5dgm33ri7dnh19s4lgnlxbpwvrw2jnzllq2kijj4i4vs85";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Algorithms";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Algorithms/4.3.0";
        sha256 = "03sq183pfl5kp7gkvq77myv7kbpdnq3y0xj7vi4q1kaw54sny0ml";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Algorithms";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Algorithms/4.3.1";
        sha256 = "1m2wnzg3m3c0s11jg4lshcl2a47d78zri8khc21yrz34jjkbyls2";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Cng";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Cng/4.4.0";
        sha256 = "1grg9id80m358crr5y4q4rhhbrm122yw8jrlcl1ybi7nkmmck40n";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Csp";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Csp/4.3.0";
        sha256 = "1x5wcrddf2s3hb8j78cry7yalca4lb5vfnkrysagbn6r9x6xvrx1";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Encoding";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.encoding/4.0.0/system.security.cryptography.encoding.4.0.0.nupkg";
        sha256 = "0a8y1a5wkmpawc787gfmnrnbzdgxmx1a14ax43jf3rj9gxmy3vk4";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Encoding";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Encoding/4.3.0";
        sha256 = "1jr6w70igqn07k5zs1ph6xja97hxnb3mqbspdrff6cvssgrixs32";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.OpenSsl";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.OpenSsl/4.4.0";
        sha256 = "0bhaanxi34mjhypy82vbp9f791bjcwr8a6p09h6f0p71f13j7r5v";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Primitives";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.primitives/4.0.0/system.security.cryptography.primitives.4.0.0.nupkg";
        sha256 = "0i7cfnwph9a10bm26m538h5xcr8b36jscp9sy1zhgifksxz4yixh";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.Primitives";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.Primitives/4.3.0";
        sha256 = "0pyzncsv48zwly3lw4f2dayqswcfvdwq2nz0dgwmi7fj3pn64wby";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.ProtectedData";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.ProtectedData/4.4.0";
        sha256 = "1q8ljvqhasyynp94a1d7jknk946m20lkwy2c3wa8zw2pc517fbj6";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.X509Certificates";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.security.cryptography.x509certificates/4.1.0/system.security.cryptography.x509certificates.4.1.0.nupkg";
        sha256 = "0clg1bv55mfv5dq00m19cp634zx6inm31kf8ppbq1jgyjf2185dh";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.X509Certificates";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.X509Certificates/4.3.0";
        sha256 = "0valjcz5wksbvijylxijjxb1mp38mdhv03r533vnx1q3ikzdav9h";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Cryptography.X509Certificates";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/System.Security.Cryptography.X509Certificates/4.3.2";
        sha256 = "0bfazl3gsas055ixxxkcl113w24b2a3i4flzsxpv14d2ias80imj";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Principal";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Principal/4.3.0";
        sha256 = "12cm2zws06z4lfc4dn31iqv7072zyi4m910d4r6wm8yx85arsfxf";
      }
    )
    (
      fetchNuGet {
        name = "System.Security.Principal.Windows";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Security.Principal.Windows/4.4.0";
        sha256 = "11rr16fp68apc0arsymgj18w8ajs9a4366wgx9iqwny4glrl20wp";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding/4.0.11/system.text.encoding.4.0.11.nupkg";
        sha256 = "1dyqv0hijg265dwxg6l7aiv74102d6xjiwplh2ar1ly6xfaa4iiw";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Text.Encoding/4.3.0";
        sha256 = "1f04lkir4iladpp51sdgmis9dj4y8v08cka0mbmsy0frc9a4gjqr";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding.CodePages";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Text.Encoding.CodePages/4.4.0";
        sha256 = "07bzjnflxjk9vgpljfybrpqmvsr9qr2f20nq5wf11imwa5pbhgfc";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding.CodePages";
        version = "4.5.0";
        url = "https://www.nuget.org/api/v2/package/System.Text.Encoding.CodePages/4.5.0";
        sha256 = "19x38911pawq4mrxrm04l2bnxwxxlzq8v8rj4cbxnfjj8pnd3vj3";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding.Extensions";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.encoding.extensions/4.0.11/system.text.encoding.extensions.4.0.11.nupkg";
        sha256 = "08nsfrpiwsg9x5ml4xyl3zyvjfdi4mvbqf93kjdh11j4fwkznizs";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.Encoding.Extensions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Text.Encoding.Extensions/4.3.0";
        sha256 = "11q1y8hh5hrp5a3kw25cb6l00v5l5dvirkz8jr3sq00h1xgcgrxy";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.RegularExpressions";
        version = "4.1.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.text.regularexpressions/4.1.0/system.text.regularexpressions.4.1.0.nupkg";
        sha256 = "1mw7vfkkyd04yn2fbhm38msk7dz2xwvib14ygjsb8dq2lcvr18y7";
      }
    )
    (
      fetchNuGet {
        name = "System.Text.RegularExpressions";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Text.RegularExpressions/4.3.0";
        sha256 = "1bgq51k7fwld0njylfn7qc5fmwrk2137gdq7djqdsw347paa9c2l";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading/4.0.11/system.threading.4.0.11.nupkg";
        sha256 = "19x946h926bzvbsgj28csn46gak2crv2skpwsx80hbgazmkgb1ls";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading/4.3.0";
        sha256 = "0rw9wfamvhayp5zh3j7p1yfmx9b5khbf4q50d8k5rk993rskfd34";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Overlapped";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Overlapped/4.3.0";
        sha256 = "1nahikhqh9nk756dh8p011j36rlcp1bzz3vwi2b4m1l2s3vz8idm";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks/4.0.11/system.threading.tasks.4.0.11.nupkg";
        sha256 = "0nr1r41rak82qfa5m0lhk9mp0k93bvfd7bbd9sdzwx9mb36g28p5";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Tasks/4.3.0";
        sha256 = "134z3v9abw3a6jsw17xl3f6hqjpak5l682k2vz39spj4kmydg6k7";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks.Dataflow";
        version = "4.9.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Tasks.Dataflow/4.9.0";
        sha256 = "1g6s9pjg4z8iy98df60y9a01imdqy59zd767vz74rrng78jl2dk5";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks.Extensions";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks.extensions/4.0.0/system.threading.tasks.extensions.4.0.0.nupkg";
        sha256 = "1cb51z062mvc2i8blpzmpn9d9mm4y307xrwi65di8ri18cz5r1zr";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks.Extensions";
        version = "4.3.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.tasks.extensions/4.3.0/system.threading.tasks.extensions.4.3.0.nupkg";
        sha256 = "1xxcx2xh8jin360yjwm4x4cf5y3a2bwpn2ygkfkwkicz7zk50s2z";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks.Extensions";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Tasks.Extensions/4.4.0";
        sha256 = "09d74a3i1rj2fgajf5hkfpipv94gsfp284xjazl2prkvn2rnq9nc";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Tasks.Parallel";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Tasks.Parallel/4.3.0";
        sha256 = "1rr3qa4hxwyj531s4nb3bwrxnxxwz617i0n9gh6x7nr7dd3ayzgh";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Thread";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.thread/4.0.0/system.threading.thread.4.0.0.nupkg";
        sha256 = "1gxxm5fl36pjjpnx1k688dcw8m9l7nmf802nxis6swdaw8k54jzc";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Thread";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Thread/4.3.0";
        sha256 = "0y2xiwdfcph7znm2ysxanrhbqqss6a3shi1z3c779pj2s523mjx4";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.ThreadPool";
        version = "4.0.10";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.threadpool/4.0.10/system.threading.threadpool.4.0.10.nupkg";
        sha256 = "0fdr61yjcxh5imvyf93n2m3n5g9pp54bnw2l1d2rdl9z6dd31ypx";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.ThreadPool";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.ThreadPool/4.3.0";
        sha256 = "027s1f4sbx0y1xqw2irqn6x161lzj8qwvnh2gn78ciiczdv10vf1";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Timer";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.threading.timer/4.0.1/system.threading.timer.4.0.1.nupkg";
        sha256 = "15n54f1f8nn3mjcjrlzdg6q3520571y012mx7v991x2fvp73lmg6";
      }
    )
    (
      fetchNuGet {
        name = "System.Threading.Timer";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Threading.Timer/4.3.0";
        sha256 = "1nx773nsx6z5whv8kaa1wjh037id2f1cxhb69pvgv12hd2b6qs56";
      }
    )
    (
      fetchNuGet {
        name = "System.ValueTuple";
        version = "4.4.0";
        url = "https://www.nuget.org/api/v2/package/System.ValueTuple/4.4.0";
        sha256 = "1wydfgszs00yxga57sam66vzv9fshk2pw7gim57saplsnkfliaif";
      }
    )
    (
      fetchNuGet {
        name = "System.ValueTuple";
        version = "4.5.0";
        url = "https://www.nuget.org/api/v2/package/System.ValueTuple/4.5.0";
        sha256 = "00k8ja51d0f9wrq4vv5z2jhq8hy31kac2rg0rv06prylcybzl8cy";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.ReaderWriter";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.readerwriter/4.0.11/system.xml.readerwriter.4.0.11.nupkg";
        sha256 = "0c6ky1jk5ada9m94wcadih98l6k1fvf6vi7vhn1msjixaha419l5";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.ReaderWriter";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.ReaderWriter/4.3.0";
        sha256 = "0c47yllxifzmh8gq6rq6l36zzvw4kjvlszkqa9wq3fr59n0hl3s1";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XDocument";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xdocument/4.0.11/system.xml.xdocument.4.0.11.nupkg";
        sha256 = "0n4lvpqzy9kc7qy1a4acwwd7b7pnvygv895az5640idl2y9zbz18";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XDocument";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XDocument/4.3.0";
        sha256 = "08h8fm4l77n0nd4i4fk2386y809bfbwqb7ih9d7564ifcxr5ssxd";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XPath";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XPath/4.3.0";
        sha256 = "1cv2m0p70774a0sd1zxc8fm8jk3i5zk2bla3riqvi8gsm0r4kpci";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XPath.XDocument";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XPath.XDocument/4.3.0";
        sha256 = "1wxckyb7n1pi433xzz0qcwcbl1swpra64065mbwwi8dhdc4kiabn";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XPath.XmlDocument";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XPath.XmlDocument/4.3.0";
        sha256 = "1h9lh7qkp0lff33z847sdfjj8yaz98ylbnkbxlnsbflhj9xyfqrm";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XmlDocument";
        version = "4.0.1";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xmldocument/4.0.1/system.xml.xmldocument.4.0.1.nupkg";
        sha256 = "0ihsnkvyc76r4dcky7v3ansnbyqjzkbyyia0ir5zvqirzan0bnl1";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XmlDocument";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XmlDocument/4.3.0";
        sha256 = "0bmz1l06dihx52jxjr22dyv5mxv6pj4852lx68grjm7bivhrbfwi";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XmlSerializer";
        version = "4.0.11";
        url = "https://api.nuget.org/v3-flatcontainer/system.xml.xmlserializer/4.0.11/system.xml.xmlserializer.4.0.11.nupkg";
        sha256 = "01nzc3gdslw90qfykq4qzr2mdnqxjl4sj0wp3fixiwdmlmvpib5z";
      }
    )
    (
      fetchNuGet {
        name = "System.Xml.XmlSerializer";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/System.Xml.XmlSerializer/4.3.0";
        sha256 = "07pa4sx196vxkgl3csvdmw94nydlsm9ir38xxcs84qjn8cycd912";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.8-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.debian.8-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "0bljghil4z4fna1jkxwnnb7vzphsn1r6ghk1avilpbbvm2xmzgf7";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.8-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.debian.8-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "0xnhcz82djlk4pikjyrb6w29yd8kih7ps7jm5b50p4xr9q89mi1y";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.8-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.debian.8-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "0rwpqngkqiapqc5c2cpkj7idhngrgss5qpnqg0yh40mbyflcxf8i";
      }
    )
    (
      fetchNuGet {
        name = "runtime.debian.9-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.debian.9-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "0hs98w18zpli7fv7n0hpxc8qwyvl5k06rqrigcc2p45lc8phjiqr";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.23-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.23-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1ywcgqnshm11r2zbcnsf2v2vi389yxkp3gamr04qw3fsz6bsy4bc";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.23-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.23-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "07yjwgljqynd2vgkmmixikfkdknr4nrpza8sk9m4mh5hvsjrvsrr";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.23-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.23-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "1n06gxwlinhs0w7s8a94r1q3lwqzvynxwd3mp10ws9bg6gck8n4r";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.24-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.24-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1i0xb5dzwrb9l6bc3i549jha2ix8674ls4p3n3f0yzgfi0dymghx";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.24-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.24-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "175blxvcl85jj6j16dm2nsiwnx9sdj682clwmjkcm21xv27zz47z";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.24-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.24-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "0404wqrc7f2yc0wxv71y3nnybvqx8v4j9d47hlscxy759a525mc3";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.27-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.27-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1rqclhxgkqpxkp8nj9h10fk5il2h6pzw941dimn025lmjmcwjdby";
      }
    )
    (
      fetchNuGet {
        name = "runtime.fedora.28-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.fedora.28-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1mp1jmxi5k786xq8m6sb8ry6s9j4gpkssf4m0c0vn3qihwwq50am";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System";
        version = "4.0.0";
        url = "https://api.nuget.org/v3-flatcontainer/runtime.native.system/4.0.0/runtime.native.system.4.0.0.nupkg";
        sha256 = "1ppk69xk59ggacj9n7g6fyxvzmk1g5p4fkijm0d7xqfkig98qrkf";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System/4.3.0";
        sha256 = "15hgf6zaq9b8br2wi1i3x0zvmk410nlmsmva9p0bbg73v6hml5k4";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.IO.Compression";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.IO.Compression/4.3.0";
        sha256 = "1vvivbqsk6y4hzcid27pqpm5bsi6sc50hvqwbcx8aap5ifrxfs8d";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.IO.Compression";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.IO.Compression/4.3.1";
        sha256 = "1pwqa3r4ppi13jnqm31l8fs56frnv34givg6ljdp1wy52cc8xzyz";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Net.Http";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Net.Http/4.3.0";
        sha256 = "1n6rgz5132lcibbch1qlf0g9jk60r0kqv087hxc0lisy50zpm7kk";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Net.Security";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Net.Security/4.3.1";
        sha256 = "19qmdnim59mykflwmm0w1k5n4z7sz68mdiz5nswyaj2j3a8a0j62";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "0nc6wvvimng49ilmp0hfazjx0skwaxqdd5ibsji4b5f8r0i28ms7";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Security.Cryptography.Apple";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Security.Cryptography.Apple/4.3.0";
        sha256 = "1b61p6gw1m02cc1ry996fl49liiwky6181dzr873g9ds92zl326q";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Security.Cryptography.Apple";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Security.Cryptography.Apple/4.3.1";
        sha256 = "00swk14hmdw42q883wwgn3vjgq9vnr3s3wlnqakp5rj76c191p9j";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "1km1msy03pm3z960qsijb25v18lmkxr652p51nkl95n43mrldqd5";
      }
    )
    (
      fetchNuGet {
        name = "runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "0zy5r25jppz48i2bkg8b9lfig24xixg6nm3xyr1379zdnqnpm8f6";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1nfbmfad2nlkksg9brwza6liz1qpd1fpjzq5qv6hhbhxg4cxxgxj";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "0nyv381b5f9s0ap5rlcy0386gqcchhgdii1gkac82pq4xhg4qlb8";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.13.2-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "096ch4n4s8k82xga80lfmpimpzahd2ip1mgwdqgar0ywbbl6x438";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1cwgafxj6mn84qhkrcn2sxpac2l0g8x5mkpqrblw1lrwqvp8vag4";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "05z0hmzn3i6alllyhz8zzg4n0x1bn8lbqn3na3543dz3djqb8xvm";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.42.1-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "1dm8fifl7rf1gy7lnwln78ch4rw54g0pl5g1c189vawavll7p6rj";
      }
    )
    (
      fetchNuGet {
        name = "runtime.opensuse.42.3-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.opensuse.42.3-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "18qm5vi5zwk8skq9b4rpxzc04sry7q391vrb5bz5fh9dss187dsm";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "00g44d44aq2a4y71rr7q1374ynqajvz0731ghbm23ydz2w6i88n0";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.Apple";
        version = "4.3.0";
        url = "https://www.nuget.org/api/v2/package/runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.Apple/4.3.0";
        sha256 = "10yc8jdrwgcl44b4g93f1ds76b176bajd3zqi2faf5rvh1vy9smi";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.Apple";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.Apple/4.3.1";
        sha256 = "1ibps5wbk0xvcgps5ydimci1jzayk5pz666vshscslhz4b6lg517";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "0i2iw9gca2qzq4c2kf9vpbi0103cx4dzwxymk5gzrm2i5n4nj85r";
      }
    )
    (
      fetchNuGet {
        name = "runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.osx.10.10-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "1m9z1k9kzva9n9kwinqxl97x2vgl79qhqjlv17k9s2ymcyv2bwr6";
      }
    )
    (
      fetchNuGet {
        name = "runtime.rhel.7-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.rhel.7-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "15vrxqw9rbg31hl4rfcynf8mxcm603n0m0pi89rgij1jdph6825h";
      }
    )
    (
      fetchNuGet {
        name = "runtime.rhel.7-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.rhel.7-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "19f649zdz8yv16nkphpv9k8yva3gjnn43ds410k8m51caqp9jpjw";
      }
    )
    (
      fetchNuGet {
        name = "runtime.rhel.7-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.rhel.7-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "1cpx56mcfxz7cpn57wvj18sjisvzq8b5vd9rw16ihd2i6mcp3wa1";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "101cycgcr5nj4cz961g5gd283a8mi1gzz4rap9l838dcg0i84rms";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "06574n5li4mh53r8lr8q9md1sxv9aq2igfsq7b0l3jxxb0jaxab5";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.14.04-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "15gsm1a8jdmgmf8j5v1slfz8ks124nfdhk2vxs2rw3asrxalg8hi";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "03cqy0j3sh0dp29s73086ypmvz8z3vjd9qyx69yd4ilzjn7k6lzp";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "0g5g9adh2hiirpgzyhwwdmslnhan48lmjcwqxkz86smkbw4vs4sn";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.04-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "0q0n5q1r1wnqmr5i5idsrd9ywl33k0js4pngkwq9p368mbxp8x1w";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "1ljhfbwja4qvzvfl6nxnf5pwvwpi393brd4v8adm80c87rw34fnb";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.1";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.1";
        sha256 = "01j4zm30sb7r1ifqkdxzdnz8d64iplf5w39d2magpml54cylan52";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography.OpenSsl";
        version = "4.3.2";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.16.10-x64.runtime.native.System.Security.Cryptography.OpenSsl/4.3.2";
        sha256 = "1x0g58pbpjrmj2x2qw17rdwwnrcl0wvim2hdwz48lixvwvp22n9c";
      }
    )
    (
      fetchNuGet {
        name = "runtime.ubuntu.18.04-x64.runtime.native.System.Security.Cryptography";
        version = "4.3.4";
        url = "https://www.nuget.org/api/v2/package/runtime.ubuntu.18.04-x64.runtime.native.System.Security.Cryptography/4.3.4";
        sha256 = "0nfjx9bfpyiss89gyqaracs1yngzvkpvxx5a9l621b2mc7hsgjlr";
      }
    )
  ];
  github = [
    (
      fetchFromGitHubForPaket {
        group = "build";
        owner = "fsharp";
        repo = "FAKE";
        rev = "96f1594fd50ced6c1aa45d7cf74fb6c067d08ac1";
        file = "modules/Octokit/Octokit.fsx";
        sha256 = "02svsljs7zg756w6n8s5vg4bwpkn5yl2rcgc9cqrj52azjb6ywc0";
      }
    )
    (
      fetchFromGitHubForPaket {
        group = "build";
        owner = "enricosada";
        repo = "add_icon_to_exe";
        rev = "e11eda501acea369ac2950beb34b8888495bf21f";
        file = "rh/ResourceHacker.exe";
        sha256 = "063ykf4lnyxaljyrqs3hka9pibasmivw9ca3w2pm5wmmv9zx3bpg";
      }
    )
    (
      fetchFromGitHubForPaket {
        group = null;
        owner = "fsharp";
        repo = "FAKE";
        rev = "0341a2e614eb2a7f34607cec914eb0ed83ce9add";
        file = "src/app/FakeLib/Globbing/Globbing.fs";
        sha256 = "0pb4pphb3fmgxyx2g16sn664hrm26w1mlmq3advhyf8b7ay54xjl";
      }
    )
    (
      fetchFromGitHubForPaket {
        group = null;
        owner = "fsprojects";
        repo = "FSharp.TypeProviders.SDK";
        rev = "dc5ac01a1ac288eceb1fd6f12a5d388236f4f8e5";
        file = "src/AssemblyReader.fs";
        sha256 = "14h0hflgzwrp2pah6v1bmw3fg4vyl3l456bnnknqjmz9iq7k2sax";
      }
    )
    (
      fetchFromGitHubForPaket {
        group = null;
        owner = "forki";
        repo = "FsUnit";
        rev = "fa4eb37288d355eb855261be6c0b3945fba68432";
        file = "FsUnit.fs";
        sha256 = "0vaajlg3787sk0nkd8wlcxz1ai4f1v931x3giy7yq91dvb47y58z";
      }
    )
  ];
}
