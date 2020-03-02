with import <nixpkgs> {};
let 
my-R-packages = with rPackages; [ tidyverse lifecycle svglite ];
R-with-my-packages = rWrapper.override{ packages = my-R-packages; };
in
stdenv.mkDerivation {
  name = "R-for-Chloro";
  buildInputs = [ R-with-my-packages ];
}
