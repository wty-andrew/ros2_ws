{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/23466e5443bce77e274a4d5d7470b8ddc7cf9650";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    ros2nix.url = "github:wentasah/ros2nix";
  };

  outputs = { self, nixpkgs, nix-ros-overlay, ros2nix }:
    let
      allSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f (
        import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [
              "freeimage-unstable-2021-11-01"
            ];
          };
          overlays = [
            nix-ros-overlay.overlays.default
            (final: prev: {
              ros2nixPackage = ros2nix.outputs.packages.${system}.ros2nix;
            })
          ];
        }
      ));
    in
    {
      devShells = forAllSystems (pkgs: with pkgs;
        let
          rosEnv = (with rosPackages.jazzy; buildEnv {
            paths = [
              colcon
              ros-base
              ament-cmake-core
              python-cmake-module
              vcstool

              rqt
              rqt-graph
              rqt-console
              rviz2

              robot-state-publisher
              joint-state-publisher-gui
              xacro

              ros-gz # includes ros-gz-bridge, ros-gz-image, ros-gz-sim, etc
              ros-gz-sim
              ros-gz-bridge

              # gazebo, https://gazebosim.org/docs/latest/ros2_gz_vendor_pkgs/
              gz-cmake-vendor
              gz-common-vendor
              gz-fuel-tools-vendor
              gz-gui-vendor
              gz-launch-vendor
              gz-math-vendor
              gz-msgs-vendor
              gz-physics-vendor
              gz-plugin-vendor
              gz-rendering-vendor
              gz-sensors-vendor
              gz-sim-vendor
              gz-tools-vendor
              gz-transport-vendor
              gz-utils-vendor
              sdformat-vendor

              gz-dartsim-vendor
              gz-ogre-next-vendor
            ];
          });
        in
        {
          default = mkShell {
            nativeBuildInputs = [
              rosEnv
            ];

            packages = [
              ros2nixPackage
            ];

            # https://github.com/lopsided98/nix-ros-overlay/issues/240
            shellHook = ''
              export LD_LIBRARY_PATH="${lib.makeLibraryPath [ libsodium ]}:$LD_LIBRARY_PATH"
              export QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins";
              export PATH="${python3}/bin:$PATH"
            '';
          };
        });
    };
}
