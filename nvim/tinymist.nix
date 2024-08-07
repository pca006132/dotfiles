{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libgit2
, openssl
, zlib
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "tinymist";
  # Please update the corresponding vscode extension when updating
  # this derivation.
  version = "0.11.18";

  src = fetchFromGitHub {
    owner = "Myriad-Dreamin";
    repo = "tinymist";
    rev = "refs/tags/v${version}";
    hash = "sha256-2tf2Dg6HfJrHQgjNKtJNT7kLoUKMoLe6U2O7VsMg7Vs=";
  };

  cargoLock = {
    lockFile = ./tinymist-cargo.lock;
    outputHashes = {
      "typst-0.11.1" = "sha256-dQf4qYaOni/jwIjRVXXCZLTn6ox3v6EyhCbaONqNtcw=";
      "typst-syntax-0.7.0" = "sha256-yrtOmlFAKOqAmhCP7n0HQCOQpU3DWyms5foCdUb9QTg=";
      "typstfmt_lib-0.2.7" = "sha256-LBYsTCjZ+U+lgd7Z3H1sBcWwseoHsuepPd66bWgfvhI=";
    };
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk_11_0.frameworks.CoreFoundation
    darwin.apple_sdk_11_0.frameworks.CoreServices
    darwin.apple_sdk_11_0.frameworks.Security
    darwin.apple_sdk_11_0.frameworks.SystemConfiguration
  ];

  checkFlags = [
    "--skip=e2e"
  ];

  meta = with lib; {
    changelog = "https://github.com/Myriad-Dreamin/tinymist/blob/${src.rev}/CHANGELOG.md";
    description = "Tinymist is an integrated language service for Typst";
    homepage = "https://github.com/Myriad-Dreamin/tinymist";
    license = licenses.asl20;
    mainProgram = "tinymist";
    maintainers = with maintainers; [ lampros ];
  };
}
