{ lib, stdenv, fetchurl, pkg-config, libGL, ApplicationServices }:

stdenv.mkDerivation rec {
  pname = "glu";
  version = "9.0.1";

  src = fetchurl {
    url = "https://mesa.freedesktop.org/archive/${pname}/${pname}-${version}.tar.xz";
    sha256 = "1g2m634p73mixkzv1qz1d0flwm390ydi41bwmchiqvdssqnlqnpv";
  };

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ libGL ]
    ++ lib.optional stdenv.isDarwin ApplicationServices;

  outputs = [ "out" "dev" ];

  meta = {
    description = "OpenGL utility library";
    homepage = "https://cgit.freedesktop.org/mesa/glu/";
    license = lib.licenses.sgi-b-20;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isAndroid;
  };
}
