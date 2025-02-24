[private]
default:
  @just --list --unsorted

build:
  @colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

clean:
  @rm -rf build install log
