#include "opencv2/core/core.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/video/background_segm.hpp"
#include "opencv2/highgui/highgui.hpp"
#include <stdio.h>
#include <iostream>
#include <vector>
#include <math.h>
#include <opencv2/core/core.hpp>

using namespace std;
using namespace cv;

cv::Mat seg[3];
cv::Mat src;
cv::Mat grey;
cv::Mat dest[3];


const char* keys =
{
    "{c |camera |true | use camera or not}"
    "{fn|file_name|tree.avi | movie file }"
};

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

 int Process(int ks,int sigma, int lamda, int psi)
     {
seg[0]=abs(grey);
seg[1]=abs(grey);
seg[2]=abs(grey);

for (int i=0;i<3;i++)
      {
      cv::Mat kernel = mkKernel(ks, sigma, i*120, lamda, psi);
      cv::filter2D(grey, dest[i], CV_32F, kernel);
      seg[i]+=abs(dest[i]);
      }
      return 0;
     }

//this is a sample for foreground detection functions
int main(int argc, const char** argv)
{
    CvCapture *camera=cvCaptureFromFile("sample.avi");
    bool update_bg_model = true;
    namedWindow("real", WINDOW_NORMAL);

    BackgroundSubtractorMOG2 bg_model,bg_model1;//(100, 3, 0.3, 5);

    Mat img1,img, fgmask, fgimg, B1,fgmask1,fgimg1;

    for(;;)
    {
     IplImage *img_c=cvQueryFrame(camera);
     cv::Mat img1 = cvarrToMat(img_c);

        if( img1.empty() )
            break;
        imshow("real",img1);
        cvtColor(img1, src, CV_BGR2GRAY);
        src.convertTo(grey, CV_32F, 1.0/255, 0);
        //imshow("grey",grey);
        Process(21, 5, 50,90);

        seg[0]= seg[0]-abs(grey);
        seg[1]= seg[1]-abs(grey);
        seg[2]= seg[2]-abs(grey);
        Mat segmn=seg[0]+seg[1]+seg[2];
        imshow("only gabor(3 angles)",segmn);

        int m=256;
        seg[0]*= m;
        seg[1]*= m;
        seg[2]*= m;

        //imshow("seg0",seg[0]);

        std::vector<cv::Mat> images(3);
        images.at(0) = seg[0]; //for blue channel
        images.at(1) = seg[1]; //for green channel
        images.at(2) = seg[2]; //for red channel

        //cv::Mat colorImage;
        cv::merge(images, img);
        //imshow("colorimage",colorImage);
        if( fgimg.empty() )
          fgimg.create(img.size(), img.type());
        //update the model
        bg_model(img, fgmask, update_bg_model ? -1 : 0);

        fgimg = Scalar::all(0);
        img.copyTo(fgimg, fgmask);

        Mat bgimg;
        bg_model.getBackgroundImage(bgimg);
        imshow("GMM and Gabor fgmask", fgmask);
        imshow("GMM and gabor fgimg", fgimg);

        //cv::merge(images, img);
               //imshow("colorimage",colorImage);
               if( fgimg1.empty() )
                 fgimg1.create(img1.size(), img1.type());
               //update the model
               bg_model1(img1, fgmask1, update_bg_model ? -1 : 0);

               fgimg1 = Scalar::all(0);
               img1.copyTo(fgimg1, fgmask1);

               Mat bgimg1;
               bg_model1.getBackgroundImage(bgimg1);
               imshow("only GMM foreground mask", fgmask1);
               imshow("only GMM foreground image", fgimg1);
        char k = (char)waitKey(30);
        if( k == 27 ) break;
        if( k == ' ' )
        {
            update_bg_model = !update_bg_model;
            if(update_bg_model)
                printf("Background update is on\n");
            else
                printf("Background update is off\n");
        }
    }

    return 0;
}
