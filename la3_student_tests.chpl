use Time;
use Image;
use FileSystem;

config const inDir = "InputDir";
config const outPDir = "POutputDir";
config const outSDir = "SOutputDir";


proc testFilesIdentical(path1: string, path2: string) {
  var format = (rgbColor.blue, rgbColor.green, rgbColor.red);

  var image1 = readImage(path1, imageType.png);
  var arr1 = pixelToColor(image1, format=format);

  var image2 = readImage(path2, imageType.png);
  var arr2 = pixelToColor(image2, format=format);

  var same = 1;
  for i in 0..image1.domain.dim(0).size-1 do
    for j in 0..image1.domain.dim(1).size-1 {
      if arr1[i, j] != arr2[i, j] {
        same = 0;
      }
    } 

  if same == 0 {
    writeln("FAIL: ", path1, " and ", path2, " are different");
  } else {
    writeln("PASS: ", path1, " and ", path2, " are the same");
  }
}

proc main() {
    use la3_serial, la3_parallel;
    
    // Run Serial
    var sw = new stopwatch();
    sw.start();

    runSerial(inDir, outSDir);

    var t1 = sw.elapsed();
    writeln("runSerial execution time: ", t1, " seconds");

    // Run Parallel
    sw.clear();
    runParallel(inDir, outPDir);

    var t2 = sw.elapsed(); 

    writeln("runParallel execution time: ", t2, " seconds");
    writeln("Improvement = ", 100.0 * (t1 - t2)/t2, "%");

    // Compare files
    var files = listDir(outSDir);
    for fname in files {
      const parts = fname.split(".");
      if parts[1] == "png" {
        testFilesIdentical(outSDir + "/" + fname, outPDir + "/" + fname);
      }
    }

    writeln("All tests completed.");
}



