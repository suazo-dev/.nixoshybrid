{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    yazi
    ffmpegthumbnailer
    poppler-utils
    imagemagick
    ueberzugpp
    exiftool
    mediainfo
  ];
}
