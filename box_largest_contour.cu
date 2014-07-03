#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <algorithm>
#include <vector>

using namespace cv;
using namespace std;

Mat src; Mat src_gray;
int thresh = 100;
int max_thresh = 255;
RNG rng(12345);

void thresh_callback(int thres, int max_thresh )
{
  Mat threshold_output;
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;

  /// Detect edges using Threshold
  threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
  /// Find contours
  findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );

  /// Approximate contours to polygons + get bounding rects and circles
  vector<vector<Point> > contours_poly( contours.size() );
  vector<Rect> boundRect( contours.size() );
  vector<Point2f>center( contours.size() );
  vector<float>radius( contours.size() );

  for( int i = 0; i < contours.size(); i++ )
     { approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
       boundRect[i] = boundingRect( Mat(contours_poly[i]) );
       minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
     }
  Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
  int areas[50],temp[50];
  int i;
  for( i = 0; i< contours.size(); i++ )
       {
	     areas[i]= contourArea(contours[i]);
	     temp[i]=areas[i];
	   }
  std::sort(areas,areas+i);
  int index;
  int k=areas[i-2];
  std::cout<<k<<std::endl;
  for( i = 0; i< contours.size(); i++ )
       {
	  	  if(k==temp[i])
	  	  	  {
	  		  	  index=i;
	  	  	  }

       }
Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
rectangle( src, boundRect[index].tl(), boundRect[index].br(), color, 2, 8, 0 );

  imshow( "Contours", src );
}


int main()
{
  src = imread("bat.jpg", 1 );
  cvtColor( src, src_gray, CV_BGR2GRAY );
  blur( src_gray, src_gray, Size(3,3) );

  imshow( "source", src );
  thresh_callback(100, 255 );

  waitKey(0);
  return(0);
}
