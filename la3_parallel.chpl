/**************************************************
 * la3_parallel.chpl
 * Name: [Your Name]
 * Time spent: [Hours]
 * Collaborators: [Names or "None"], including AI: ChatGPT

 How you optimized the code:

 **************************************************/

use FileSystem;
use Image;
use IO;


proc runParallel(inDir, outDir) {
    use Image;

    var files = listDir(inDir);

    for fname in files {
      const parts = fname.split(".");
      var origfName = inDir + "/" + fname;
      var grayfName = outDir + "/" + parts[0] + "_gray.png";

      var imageArray = readImage(origfName, imageType.png);

      var grayscaleImage = rgbToGrayscale(imageArray);
      writeImage(grayfName, imageType.png, grayscaleImage);
      }

    for fname in files {
      const parts = fname.split(".");
      var grayfName = outDir + "/" + parts[0] + "_gray.png";
      var edgefName = outDir + "/" + parts[0] + "_edge.png";

      var grayArray = readImage(grayfName, imageType.png);
      var sobelImage = sobelEdgeDetection(grayArray);
      writeImage(edgefName, imageType.png, sobelImage);
      }
}


proc rgbToGrayscale(rgbImage : [?d] pixelType) : [d] int
    where d.isRectangular() && d.rank == 2 {
    var grayScale: [rgbImage.domain] uint(8);

    var format = (rgbColor.blue, rgbColor.green, rgbColor.red);
    var arr = pixelToColor(rgbImage, format=format);

    for i in 0..rgbImage.domain.dim(0).size-1 do
      for j in 0..rgbImage.domain.dim(1).size-1 {
        const (r, g, b) = arr[i, j];
        const gray = round(0.299*r + 0.587*g + 0.114*b):uint(8);
        grayScale[i,j] = gray;
        arr[i,j] = (gray,gray,gray);
      } 

    var pic = colorToPixel(arr, format=format);

    return pic;
}


proc sobelEdgeDetection(grayScale : [?d] int) : [d] int
  where d.isRectangular() && d.rank == 2 {
    var edgeImage: [d] (3*int);

  const Gx = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
  const Gy = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]];

  var numRows = grayScale.domain.dim(0).size;
  var numCols = grayScale.domain.dim(1).size;

  const fmt = (rgbColor.red, rgbColor.green, rgbColor.blue);
  var colors = pixelToColor(grayScale, format=fmt);

  forall i in 1..#(numRows-2) do
    forall j in 1..#(numCols-2) {
      var sumX = 0, sumY = 0;
      for di in -1..1 do
        for dj in -1..1 {
          const pixel = colors[i+di, j+dj](0);
          sumX += pixel * Gx[di+1][dj+1];
          sumY += pixel * Gy[di+1][dj+1];
        }
      var value = sqrt(sumX**2 + sumY**2):int;
      edgeImage[i, j] = (value,value,value);
    }
    var edge = colorToPixel(edgeImage, format=fmt);

    return edge;
}


