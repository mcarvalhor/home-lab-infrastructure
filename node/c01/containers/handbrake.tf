resource "docker_image" "handbrake_image" {
  name         = "jlesage/handbrake:latest"
  keep_locally = true
  pull_triggers = [ local.last_deployment.handbrake ]
}

resource "docker_volume" "vol_handbrake_data" {
  name = "handbrake_data"
}

resource "docker_container" "handbrake" {
  name    = "handbrake"
  image   = docker_image.handbrake_image.image_id
  restart = "unless-stopped"
  devices {
    host_path      = "/dev/dri"
    container_path = "/dev/dri"
  }
  ports {
    internal = 5800
    external = local.ports.handbrake
  }
  env = [
    "APP_NAME=HandBrake",
    "APP_NICENESS=0",
    "APP_USER=app",
    "AUTOMATED_CONVERSION=1",
    "AUTOMATED_CONVERSION_CHECK_INTERVAL=5",
    "AUTOMATED_CONVERSION_FORMAT=mp4",
    "AUTOMATED_CONVERSION_HANDBRAKE_CUSTOM_ARGS=",
    "AUTOMATED_CONVERSION_INSTALL_PKGS=",
    "AUTOMATED_CONVERSION_KEEP_SOURCE=1",
    "AUTOMATED_CONVERSION_MAX_WATCH_FOLDERS=5",
    "AUTOMATED_CONVERSION_NO_GUI_PROGRESS=0",
    "AUTOMATED_CONVERSION_NON_VIDEO_FILE_ACTION=ignore",
    "AUTOMATED_CONVERSION_NON_VIDEO_FILE_EXTENSIONS=jpg jpeg bmp png gif txt nfo",
    "AUTOMATED_CONVERSION_OUTPUT_DIR=/output",
    "AUTOMATED_CONVERSION_OUTPUT_SUBDIR=",
    "AUTOMATED_CONVERSION_OVERWRITE_OUTPUT=0",
    "AUTOMATED_CONVERSION_PRESET=Hardware/H.265 QSV 1080p",
    "AUTOMATED_CONVERSION_SOURCE_MAIN_TITLE_DETECTION=0",
    "AUTOMATED_CONVERSION_SOURCE_MIN_DURATION=10",
    "AUTOMATED_CONVERSION_SOURCE_STABLE_TIME=5",
    "AUTOMATED_CONVERSION_USE_TRASH=0",
    "AUTOMATED_CONVERSION_VIDEO_FILE_EXTENSIONS=",
    "CLEAN_TMP_DIR=1",
    "CONTAINER_DEBUG=0",
    "DARK_MODE=0",
    "DISPLAY=:0",
    "DISPLAY_HEIGHT=768",
    "DISPLAY_WIDTH=1280",
    "ENABLE_CJK_FONT=0",
    "ENV=/root/.docker_rc",
    "GROUP_ID=1002",
    "HANDBRAKE_DEBUG=0",
    "HANDBRAKE_GUI=1",
    "INSTALL_PACKAGES=",
    "KEEP_APP_RUNNING=1",
    "LANG=en_US.UTF-8",
    "S6_BEHAVIOUR_IF_STAGE2_FAILS=3",
    "S6_SERVICE_DEPS=1",
    "SECURE_CONNECTION=0",
    "SECURE_CONNECTION_CERTS_CHECK_INTERVAL=60",
    "SECURE_CONNECTION_VNC_METHOD=SSL",
    "SUP_GROUP_IDS=",
    "TZ=America/Sao_Paulo",
    "UMASK=022",
    "USER_ID=1002",
    "VNC_LISTENING_PORT=5900",
    "VNC_PASSWORD=",
    "WEB_LISTENING_PORT=5800",
    "XDG_CACHE_HOME=/config/xdg/cache",
    "XDG_CONFIG_HOME=/config/xdg/config",
    "XDG_DATA_HOME=/config/xdg/data",
    "XDG_RUNTIME_DIR=/tmp/run/user/app",
    "PACKAGES_MIRROR=",
    "WEB_AUDIO=0",
    "WEB_AUTHENTICATION=0",
    "WEB_AUTHENTICATION_DEFAULT_USERNAME=",
    "WEB_AUTHENTICATION_DEFAULT_PASSWORD=",
    "HANDBRAKE_GUI_QUEUE_STARTUP_ACTION=NONE",
    "WEB_AUTHENTICATION_TOKEN_VALIDITY_TIME=24",
    "WEB_AUTHENTICATION_USERNAME=",
    "WEB_AUTHENTICATION_PASSWORD=",
    "WEB_FILE_MANAGER=0",
    "WEB_FILE_MANAGER_ALLOWED_PATHS=AUTO",
    "WEB_FILE_MANAGER_DENIED_PATHS=",
    "AUTOMATED_CONVERSION_WATCH_DIR=AUTO",
    "AUTOMATED_CONVERSION_TRASH_DIR=/trash",
    "WEB_LOCALHOST_ONLY=0",
    "VNC_LOCALHOST_ONLY=0",
    "WEB_NOTIFICATION=0",
    "WEB_TERMINAL=0",
  ]
  volumes {
    host_path      = "/nas/smb/HandBrake"
    container_path = "/storage"
    read_only      = true
  }
  volumes {
    volume_name    = docker_volume.vol_handbrake_data.name
    container_path = "/config"
  }
  volumes {
    host_path      = "/nas/smb/HandBrake/Converted"
    container_path = "/output"
  }
}
