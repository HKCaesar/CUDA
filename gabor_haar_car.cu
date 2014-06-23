#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <opencv2/imgproc/imgproc.hpp>
#include <math.h>
#include <vector>
#include <iostream>
#include <opencv2/opencv.hpp>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>

using namespace std;
using namespace cv;

const char* cascade_name ="cars3.xml";
cv::Mat seg;
cv::Mat src;
cv::Mat grey;
cv::Mat dest[12];
IplImage *mark;
IplImage *img1;
 cv::Mat mkKernel(int ks, double sig, double th, double lm, double ps)
      {
          int hks = (ks-1)/2;
          double theta = th*CV_PI/180;
          double psi = ps*CV_PI/180;
          double del = 2.0/(ks-1);
          double lmbd = lm;
          double sigma = sig/ks;
          double x_theta;
          double y_theta;
          cv::Mat kernel(ks,ks, CV_32F);
          for (int y=-hks; y<=hks; y++)
          {
              for (int x=-hks; x<=hks; x++)
              {
                  x_theta = x*del*cos(theta)+y*del*sin(theta);
                  y_theta = -x*del*sin(theta)+y*del*cos(theta);
                  kernel.at<float>(hks+y,hks+x) = (float)exp(-0.5*(pow(x_theta,2)+pow(y_theta,2))/pow(sigma,2))* cos(2*CV_PI*x_theta/lmbd + psi);
              }
          }
          return kernel;
      }

 int Process(int ks,int sigma, int lamda,  int psi)
     {
	 seg=abs(grey);
	 for (int i=0;i<12;i++)
     	{
     		cv::Mat kernel = mkKernel(ks, sigma, i*30, lamda, psi);
     		cv::filter2D(grey, dest[i], CV_32F, kernel);
     		seg+=abs(dest[i]);
     	}
     	return 0;
     }
 void detect_and_draw(IplImage* img)
 {
	 static CvMemStorage* storage = 0;
	 static CvHaarClassifierCascade* cascade = 0;
	 int scale = 1;
	 IplImage* temp = cvCreateImage(cvSize(img->width / scale, img->height / scale), 8, 3);
	 CvPoint pt1, pt2;
 	int i;
 	cascade = (CvHaarClassifierCascade*)cvLoad(cascade_name, 0, 0, 0);
if (!cascade)
 	{
 		fprintf(stderr, "ERROR: Could not load classifier cascade\n");
 		return;
 	}
 	storage = cvCreateMemStorage(0);
 	cvClearMemStorage(storage);
if (cascade)
 	{
 		CvSeq* faces = cvHaarDetectObjects(img, cascade, storage,
 			1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
 			cvSize(40, 40));
 		for (i = 0; i < (faces ? faces->total : 0); i++)
 		{
 			CvRect* r = (CvRect*)cvGetSeqElem(faces, i);
 			pt1.x = r->x*scale;
 			pt2.x = (r->x + r->width)*scale;
 			pt1.y = r->y*scale;
 			pt2.y = (r->y + r->height)*scale;
 			cvRectangle(img, pt1, pt2, CV_RGB(255, 0, 0), 3, 8, 0);
 		}
 	}
 	cvShowImage("result", img);
 	cvReleaseImage(&temp);
 }

int main()
{

CvCapture *camera=cvCaptureFromFile("sample6.avi");
cvNamedWindow("img");
while (cvWaitKey(10)!=atoi("q"))
{
    double t1=(double)cvGetTickCount();
    IplImage *imge=cvQueryFrame(camera);
    cv::Mat B1 = cvarrToMat(imge);
    //IplImage * image = &((IplImage)B1);
    cvShowImage("img",imge);
    //cv::imshow("img1",B1);
    cv::cvtColor(B1, src, CV_BGR2GRAY);
    //cv::imshow("img1",src);
    src.convertTo(grey, CV_32F, 1.0/255, 0);
    //cv::imshow("img1",grey);
    Process(21, 5, 50,90);
    seg= seg-abs(grey);
    //seg/=4;
    cv::imshow("seg",seg);



    		 IplImage copy = seg;
    		 IplImage* new_image = &copy;

    		IplImage* haar = cvCreateImage(cvGetSize(new_image), IPL_DEPTH_8U, 1);


    		detect_and_draw(haar);

    seg*=0;

}
cvReleaseCapture(&camera);
cvDestroyWindow("result");
}
