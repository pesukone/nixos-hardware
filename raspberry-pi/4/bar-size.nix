{
  hardware.deviceTree.overlays = [
    {
      name = "cm4-bar-size";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "brcm,bcm2711";

          fragment@0 {
            target = <&pcie0>;
            __overlay__ {
              ranges = <0x02000000 0x0 0xe0000000 0x6 0x00000000 0x0 0x10000000>;
            };
          };
        };
      '';
    }
  ];
}
