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
//int thresh = 100;
//int max_thresh = 255;
RNG rng(12345);
Mat crop;

void thresh_callback(int thresh, int max_thresh )
{
  Mat threshold_output;
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  //Canny(src,threshold_output,thresh, max_thresh, 3,false );//uncomment to use canny
  //imshow("canny",threshold_output);
  threshold( src_gray, threshold_output, thresh, max_thresh, THRESH_BINARY );
  findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
  vector<vector<Point> > contours_poly( contours.size() );
  vector<Rect> boundRect( contours.size() );
  //vector<Point2f>center( contours.size() );
  //vector<float>radius( contours.size() );

  for( int i = 0; i < contours.size(); i++ )
     { approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
       boundRect[i] = boundingRect( Mat(contours_poly[i]) );
       //minEnclosingCircle( (Mat)contours_poly[i], center[i], radius[i] );
     }
  Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
  float areas[50],temp[50];
  int i;
  for( i = 0; i< contours.size(); i++ )
       {
         areas[i]= contourArea(contours[i]);
         temp[i]=areas[i];
       }
  std::sort(areas,areas+i);
  int index;
  float k=areas[i-1];
  std::cout<<k<<std::endl;
  for( i = 0; i< contours.size(); i++ )
       {std::cout<<areas[i]<<std::endl;
            if(k==temp[i])
                  {
                      index=i;
                  }
       }
Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
drawContours( src, contours_poly, index, color, 1, 8, vector<Vec4i>(), 0, Point() );
rectangle( src, boundRect[index], color, 2, 8, 0 );
crop = src(boundRect[index]).clone();

 imshow( "Contours", src);

}


int main()
{
  src = imread("i.jpg", 1 );
  cvtColor( src, src_gray, CV_BGR2GRAY );
  blur( src_gray, src_gray, Size(3,3) );
  thresh_callback(100,255);
  imshow( "Cropped", crop );

  waitKey(0);
  return(0);
}
