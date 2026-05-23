{ lib, stdenv, fetchFromGitHub, autoreconfHook, libpcap }:

stdenv.mkDerivation rec {
  pname = "knock";
  version = "0.8";

  src = fetchFromGitHub {
    owner = "jvinet";
    repo = "knock";
    rev = "v${version}";
    hash = "sha256-GOg6wovyr6J5qHm5EsOxrposFtwwx/FyJs7g0dagFmk=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libpcap ];

  meta = with lib; {
    description = "Port knocking server and client";
    homepage = "https://github.com/jvinet/knock";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
