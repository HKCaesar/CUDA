#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <opencv2/imgproc/imgproc.hpp>
#include <math.h>
#include <vector>

using namespace std;
using namespace cv;

cv::Mat seg;
cv::Mat src;
cv::Mat grey;
cv::Mat dest[12];


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

     	seg= seg-abs(grey);
     	seg/=4;

     	cv::imshow("seg",seg);
     	seg*=0;

         return 0;
     }


int main()
{

CvCapture *camera=cvCaptureFromFile("sample6.avi");
cvNamedWindow("img");
while (cvWaitKey(10)!=atoi("q"))
{
    double t1=(double)cvGetTickCount();
    IplImage *img=cvQueryFrame(camera);
    cv::Mat B1 = cvarrToMat(img);
    //IplImage * image = &((IplImage)B1);
    cvShowImage("img",img);
    //cv::imshow("img1",B1);
    cv::cvtColor(B1, src, CV_BGR2GRAY);
    //cv::imshow("img1",src);
    src.convertTo(grey, CV_32F, 1.0/255, 0);
    cv::imshow("img1",grey);
    Process(21, 5, 50,90);
}
cvReleaseCapture(&camera);
}
