{ lib
, buildGoPackage
, fetchFromGitHub
, makeWrapper
, version
, sha256
, nvidiaGpuSupport
, patchelf
, nvidia_x11
, cni-plugins
}:

buildGoPackage rec {
  pname = "nomad";
  inherit version;
  rev = "v${version}";

  goPackagePath = "github.com/hashicorp/nomad";
  subPackages = [ "." ];

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
    inherit rev sha256;
  };

  nativeBuildInputs =
    [ makeWrapper ]
    ++ lib.optionals nvidiaGpuSupport [ patchelf ];

  # ui:
  #  Nomad release commits include the compiled version of the UI, but the file
  #  is only included if we build with the ui tag.
  preBuild =
    let
      tags = [ "ui" ] ++ lib.optional (!nvidiaGpuSupport) "nonvidia";
      tagsString = lib.concatStringsSep " " tags;
    in
    ''
      export buildFlagsArray=(
        -tags="${tagsString}"
      )
    '';

  # The dependency on NVML isn't explicit. We have to make it so otherwise the
  # binary will not know where to look for the relevant symbols.
  postFixup = lib.optionalString nvidiaGpuSupport ''
    for bin in $out/bin/*; do
      patchelf --add-needed "${nvidia_x11}/lib/libnvidia-ml.so" "$bin"
    done
  '';

  postInstall = ''
    wrapProgram $out/bin/nomad \
      --prefix CNI_PATH : "${cni-plugins}/bin"
  '';

  meta = with lib; {
    homepage = "https://www.nomadproject.io/";
    description = "A Distributed, Highly Available, Datacenter-Aware Scheduler";
    platforms = platforms.unix;
    license = licenses.mpl20;
    maintainers = with maintainers; [ rushmorem pradeepchhetri endocrimes ];
  };
}
