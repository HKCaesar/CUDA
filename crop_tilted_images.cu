#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace cv;
using namespace std;

Mat src; Mat src_gray;
int thresh = 100;
int max_thresh = 255;
RNG rng(12345);

/// Function header
void thresh_callback(int, void* );

/** @function main */
int main()
{
  /// Load source image and convert it to gray
  src = imread("3.jpg", 1 );

  /// Convert image to gray and blur it
  cvtColor( src, src_gray, CV_BGR2GRAY );
  blur( src_gray, src_gray, Size(3,3) );

  /// Create Window
  char* source_window = "Source";
  namedWindow( source_window, CV_WINDOW_AUTOSIZE );
  imshow( source_window, src );

  createTrackbar( " Threshold:", "Source", &thresh, max_thresh, thresh_callback );
  thresh_callback( 0, 0 );

  waitKey(0);
  return(0);
}

/** @function thresh_callback */
void thresh_callback(int, void* )
{
  Mat threshold_output;
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  RotatedRect rect;
  Mat M, rotated, cropped;
  /// Detect edges using Threshold
  threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
  /// Find contours
  findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );

  /// Find the rotated rectangles and ellipses for each contour
  vector<RotatedRect> minRect( contours.size() );
  vector<RotatedRect> minEllipse( contours.size() );

  for( int i = 0; i < contours.size(); i++ )
     { minRect[i] = minAreaRect( Mat(contours[i]) );
       if( contours[i].size() > 5 )
         { minEllipse[i] = fitEllipse( Mat(contours[i]) ); }
     }


char b[100];
  /// Draw contours + rotated rects + ellipses
  Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
  for( int i = 0; i< contours.size(); i++ )
     {

	  Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
       // contour
       drawContours( drawing, contours, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
       // ellipse
       ellipse( drawing, minEllipse[i], color, 2, 8 );

        // rotated rectangle
       Point2f rect_points[4];
       minRect[i].points( rect_points );
       for( int j = 0; j < 4; j++ )
    	   line( drawing, rect_points[j], rect_points[(j+1)%4], color, 1, 8 );
     }

  /// Show in a window
  namedWindow( "Contours", CV_WINDOW_AUTOSIZE );
  imshow( "Contours", drawing );
  cout<<contours.size()<<endl;
  for( int i = 0; i< contours.size(); i++ )
  {
  rect=minRect[i];
  	          // matrices we'll use

  	          // get angle and size from the bounding box
  	          float angle = rect.angle;
  	          Size rect_size = rect.size;
  	          // thanks to http://felix.abecassis.me/2011/10/opencv-rotation-deskewing/
  	          if (rect.angle < -45.) {
  	              angle += 90.0;
  	              swap(rect_size.width, rect_size.height);
  	          }
  	          sprintf(b,"crop%d",i);
  	          // get the rotation matrix
  	          M = getRotationMatrix2D(rect.center, angle, 1.0);
  	          // perform the affine transformation
  	          warpAffine(src, rotated, M, src.size(), INTER_CUBIC);
  	          // crop the resulting image
  	          imshow(b,rotated);
  	         // Mat crop=
  	          getRectSubPix(rotated, rect_size, rect.center, cropped);
  	          imshow("cropped",cropped);
  	          waitKey(0);
}
}
