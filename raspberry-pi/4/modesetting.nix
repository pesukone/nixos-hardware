{ config, lib, ... }:

let
  fkms-cfg = config.hardware.raspberry-pi."4".fkms-3d;
  kms-cfg = config.hardware.raspberry-pi."4".kms-3d;
  # Equivalent to:
  # https://github.com/raspberrypi/linux/blob/rpi-6.1.y/arch/arm/boot/dts/overlays/cma-overlay.dts
  cma-overlay = {
    name = "rpi4-cma-overlay";
    dtsText = ''
      // SPDX-License-Identifier: GPL-2.0
      /dts-v1/;
      /plugin/;

      / {
        compatible = "brcm,bcm2711";

        fragment@0 {
          target = <&cma>;
          __overlay__ {
            size = <(${toString (fkms-cfg.cma or kms-cfg.cma)} * 1024 * 1024)>;
          };
        };
      };
    '';
  };
in
{
  options.hardware = {
    raspberry-pi."4".fkms-3d = {
      enable = lib.mkEnableOption ''
        Enable modesetting through fkms-3d
      '';
      cma = lib.mkOption {
        type = lib.types.int;
        default = 512;
        description = ''
          Amount of CMA (contiguous memory allocator) to reserve, in MiB.

          The foundation overlay defaults to 256MiB, for backward compatibility.
          As the Raspberry Pi 4 family of hardware has ample amount of memory, we
          can reserve more without issue.

          Additionally, reserving too much is not an issue. The kernel will use
          CMA last if the memory is needed.
        '';
      };
    };

    raspberry-pi."4".kms-3d = {
      enable = lib.mkEnableOption ''
        Enable modesetting through kms-3d
      '';
      cma = lib.mkOption {
        type = lib.types.int;
        default = 512;
        description = ''
          Amount of CMA (contiguous memory allocator) to reserve, in MiB.

          The foundation overlay defaults to 256MiB, for backward compatibility.
          As the Raspberry Pi 4 family of hardware has ample amount of memory, we
          can reserve more without issue.

          Additionally, reserving too much is not an issue. The kernel will use
          CMA last if the memory is needed.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (mkIf fkms-cfg.enable {
    # doesn't work for the CM module, so we exclude e.g. bcm2711-rpi-cm4.dts
    hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

    # Configure for modesetting in the device tree
    hardware.deviceTree = {
      overlays = [
        cma-overlay
        # Equivalent to:
        # https://github.com/raspberrypi/linux/blob/rpi-6.1.y/arch/arm/boot/dts/overlays/vc4-fkms-v3d-overlay.dts
        {
          name = "rpi4-vc4-fkms-v3d-overlay";
          dtsText = ''
            // SPDX-License-Identifier: GPL-2.0
            /dts-v1/;
            /plugin/;

            / {
              compatible = "brcm,bcm2711";

              fragment@1 {
                target = <&fb>;
                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@2 {
                target = <&firmwarekms>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@3 {
                target = <&v3d>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@4 {
                target = <&vc4>;
                __overlay__ {
                  status = "okay";
                };
              };
            };
          '';
        }
      ];
    };

    # Also configure the system for modesetting.

    services.xserver.videoDrivers = lib.mkBefore [
      "modesetting" # Prefer the modesetting driver in X11
      "fbdev" # Fallback to fbdev
    ];
    })
    (mkIf kms-cfg.enable {
    # doesn't work for the CM module, so we exclude e.g. bcm2711-rpi-cm4.dts
    hardware.deviceTree.filter = "bcm2711-rpi-4*.dtb";

    # Configure for modesetting in the device tree
    hardware.deviceTree = {
      overlays = [
        cma-overlay
        {
          name = "vc4-kms-v3d-pi4";
          dtsText = ''
            /dts-v1/;
            /plugin/;

            #include <dt-bindings/clock/bcm2835.h>

            / {
              compatible = "brcm,bcm2711";

              fragment@1 {
                target = <&ddc0>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@2 {
                target = <&ddc1>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@3 {
                target = <&hdmi0>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@4 {
                target = <&hdmi1>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@5 {
                target = <&hvs>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@6 {
                target = <&pixelvalve0>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@7 {
                target = <&pixelvalve1>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@8 {
                target = <&pixelvalve2>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@9 {
                target = <&pixelvalve3>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@10 {
                target = <&pixelvalve4>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@11 {
                target = <&v3d>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@12 {
                target = <&vc4>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@13 {
                target = <&txp>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@14 {
                target = <&fb>;
                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@15 {
                target = <&firmwarekms>;
                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@16 {
                target = <&vec>;
                __overlay__ {
                  status = "disabled";
                };
              };

              fragment@17 {
                target = <&hdmi0>;
                __dormant__ {
                  dmas;
                };
              };

              fragment@18 {
                target = <&hdmi1>;
                __overlay__ {
                  dmas;
                };
              };

              fragment@19 {
                target-path = "/chosen";
                __overlay__ {
                  bootargs = "snd_bcm2835.enable_hdmi=0";
                };
              };

              fragment@20 {
                target = <&dvp>;
                __overlay__ {
                  status = "okay";
                };
              };

              fragment@21 {
                target = <&pixelvalve3>;
                __dormant__ {
                  status = "okay";
                };
              };

              fragment@22 {
                target = <&vec>;
                __dormant__ {
                  status = "okay";
                };
              };

              fragment@23 {
                target = <&aon_intr>;
                __overlay__ {
                  status = "okay";
                };
              };

              __overrides__ {
                audio = <0>,"!17";
                audio1 = <0>,"!18";
                noaudio = <0>,"=17", <0>,"=18";
                composite = <0>, "!1",
                  <0>, "!2",
                  <0>, "!3",
                  <0>, "!4",
                  <0>, "!5",
                  <0>, "!6",
                  <0>, "!7",
                  <0>, "!8",
                  <0>, "!9",
                  <0>, "!10",
                  <0>, "!16",
                  <0>, "=21",
                  <0>, "=22";
                nohdmi0 = <0>, "-1-3-8";
                nohdmi1 = <0>, "-2-4-10";
                nohdmi = <0>, "-1-2-3-4-8-10";
              };
            };
          '';
        }
      ];
    };

    # Also configure the system for modesetting.

    services.xserver.videoDrivers = lib.mkBefore [
      "modesetting" # Prefer the modesetting driver in X11
      "fbdev" # Fallback to fbdev
    ];
    })
  ];
}
