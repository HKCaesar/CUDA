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
RNG rng(12345);
Mat crop;

void thresh_callback(int thresh, int max_thresh )
{
  Mat threshold_output;
  vector<vector<Point> > contours;
  vector<Vec4i> hierarchy;
  adaptiveThreshold(src_gray,threshold_output,max_thresh, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY_INV, 75,10);
  //Canny(src_gray,threshold_output,thresh, max_thresh, 3,false );
  //threshold( src_gray, threshold_output, thresh, max_thresh, THRESH_BINARY );
  imshow("canny",threshold_output);
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
  //std::cout<<k<<std::endl;
  for( i = 0; i< contours.size(); i++ )
       {//std::cout<<areas[i]<<std::endl;
	  	  if(k==temp[i])
	  	  	  {
	  		  	  index=i;
	  	  	  }
       }
Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//drawContours( src, contours_poly, index, color, 1, 8, vector<Vec4i>(), 0, Point() );
//rectangle( src, boundRect[index], color, 2, 8, 0 );
crop = src(boundRect[index]).clone();

 imshow( "Contours", crop);

}


int main()
{
	Size size(92,112);
	Mat dst;

	char b2[200];
	int k=1;
	CvCapture* capture  = cvCaptureFromCAM(0);
	IplImage *img;
	while(1)
	{


		img = cvQueryFrame(capture);
		src = cvarrToMat(img);
		imshow("source",src);
		//src = imread(b1,1);
		char c = cvWaitKey(20);
		if (c == 32)
		{   	k++;
			cvtColor( src, src_gray, CV_BGR2GRAY );
			blur( src_gray, src_gray, Size(3,3) );
			thresh_callback(100,255);
			cv::resize(crop,dst,size);
			sprintf(b2,"n%d.jpg",k);
			imwrite(b2,dst);
			std::cout<<"negative/"<<b2<<std::endl;
		}

	}
cvReleaseCapture(&capture);
cvReleaseImage(&img);
cvDestroyWindow("result");
return 0;
}
