ARG ROS_DISTRO=jazzy
FROM osrf/ros:${ROS_DISTRO}-desktop-full

ARG ROS_DISTRO

RUN apt-get update && apt-get upgrade -y \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install --no-install-recommends -y \
  just \
  sudo \
  vim \
  zsh \
  && rm -rf /var/lib/apt/lists/*

# Add non-root user with sudo privileges while sharing UID/GID with host user
# https://code.visualstudio.com/remote/advancedcontainers/add-nonroot-user
ARG USERNAME
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if id -u $USER_UID ; then userdel `id -un $USER_UID`; fi
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/zsh $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Grant access to serial devices
RUN usermod -a -G dialout $USERNAME

USER $USERNAME

WORKDIR /ros2_ws

RUN rosdep update

# zsh setup
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY zshrc /home/$USERNAME/.zshrc
