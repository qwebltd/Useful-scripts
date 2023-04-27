<script type="text/javascript">
  // Conversion functions by QWeb Ltd to swap between RGB and HSL colour codes

  // RGBtoHSL() returns an array where elements 0, 1, an 2 refer to the H, S, and L components respectively.
  // HSLtoRGB() returns an array where elements 0, 1, an 2 refer to the R, G, and B components respectively.

  function RGBtoHSL(r, g, b) {
    // This assumes r, g, and b are in integer notation. I.e. 0 to 255 rather than 0 to 1.

    // Convert to decimal notation
    var rd = r / 255;
    var gd = g / 255;
    var bd = b / 255;

    // Find the min and max values, and the difference between them
    var max = Math.max(rd, Math.max(gd, bd));
    var min = Math.min(rd, Math.min(gd, bd));
    var difference = max - min;

    // Hue
    if(difference == 0) {
      var h = 0;
    } else if(max == rd) {
      var h = 60 * (((gd - bd) / difference) % 6);
    } else if(max == gd) {
      var h = 60 * (((bd - rd) / difference) + 2);
    } else if(max == bd) {
      var h = 60 * (((rd - gd) / difference) + 4);
    }

    // Hue is a rad, so...
    if(h < 0) {
      h += 360;
    }

    // Saturation
    if(difference == 0) {
      var s = 0;
    } else {
      var s = 100 * (difference / (1 - Math.abs(2 * ((max + min) / 2) - 1)));
    }

    // Luminosity
    var l = 100 * ((max + min) / 2);

    return [h, s, l];
  }

  function HSLtoRGB(h, s, l) {
    // This assumes h, s, and l are in integer notation. I.e. 0 to 100 and 0 to 360, rather than 0 to 1 and 0 to 6.

    // Convert to decimal notation
    var hd = h / 60;
    var sd = s / 100;
    var ld = l / 100;

    var chroma = (1 - Math.abs(2 * ld - 1)) * sd;
    var x = chroma * (1 - Math.abs(hd % 2 - 1));
    var m = ld - chroma / 2;

    if(hd >= 0 && hd < 1) {
      var r = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
      var g = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
      var b = Math.min(255, Math.max(0, parseInt(m * 255)));
    } else if(hd >= 1 && hd < 2) {
      var r = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
      var g = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
      var b = Math.min(255, Math.max(0, parseInt(m * 255)));
    } else if(hd >= 2 && hd < 3) {
      var r = Math.min(255, Math.max(0, parseInt(m * 255)));
      var g = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
      var b = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
    } else if(hd >= 3 && hd < 4) {
      var r = Math.min(255, Math.max(0, parseInt(m * 255)));
      var g = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
      var b = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
    } else if(hd >= 4 && hd < 5) {
      var r = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
      var g = Math.min(255, Math.max(0, parseInt(m * 255)));
      var b = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
    } else if(hd >= 5 && hd < 6) {
      var r = Math.min(255, Math.max(0, parseInt((chroma + m) * 255)));
      var g = Math.min(255, Math.max(0, parseInt(m * 255)));
      var b = Math.min(255, Math.max(0, parseInt((x + m) * 255)));
    }

    return [r, g, b];
  }
</script>
