# Experimental flake interface to Nixpkgs.
# See https://github.com/NixOS/rfcs/pull/49 for details.
{
  description = "A collection of packages for the Nix package manager";

  outputs = { self }:
    let
      libVersionInfoOverlay = import ./lib/flake-version-info.nix self;
      lib = (import ./lib).extend libVersionInfoOverlay;

      forAllSystems = lib.genAttrs lib.systems.flakeExposed;

    in
    {
      # The "legacy" in `legacyPackages` doesn't imply that the packages exposed
      # through this attribute are "legacy" packages. Instead, `legacyPackages`
      # is used here as a substitute attribute name for `packages`. The problem
      # with `packages` is that it makes operations like `nix flake show
      # nixpkgs` unusably slow due to the sheer number of packages the Nix CLI
      # needs to evaluate. But when the Nix CLI sees a `legacyPackages`
      # attribute it displays `omitted` instead of evaluating all packages,
      # which keeps `nix flake show` on Nixpkgs reasonably fast, though less
      # information rich.
      legacyPackages = forAllSystems (system:
        (import ./. { inherit system; }).extend (final: prev: {
          lib = prev.lib.extend libVersionInfoOverlay;
        })
      );

    };
}
