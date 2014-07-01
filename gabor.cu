#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <math.h>
#include<iostream>
#include<stdio.h>

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

    cv::Mat src_f;
    cv::Mat dest[12];

    int Process(int ks,int sigma, int lamda,  int psi)
    {
    	char buffer [50],name[30];
    	cv::Mat seg=abs(src_f);

    	for (int i=0;i<12;i++)
    	{
    		cv::Mat kernel = mkKernel(ks, sigma, i*30, lamda, psi);
    		cv::filter2D(src_f, dest[i], CV_32F, kernel);
    		sprintf (buffer, "angle of %d", i*30);
    		cv::imshow(buffer, dest[i]);
    		seg+=abs(dest[i]);



    	}

    	seg= seg-src_f;
    	seg/=4;
    	cv::imshow("segm",seg);


        return 0;
    }

    int main(int argc, char** argv)
    {
    	int ks=21;
    	cv::Mat image;
    	image=cv::imread("lena.jpg",1);


        while(true)
        {

        	        cv::imshow("Src", image);
        	        cv::Mat src;
        	        cv::cvtColor(image, src, CV_BGR2GRAY);
        	        src.convertTo(src_f, CV_32F, 1.0/255, 0);
        	        if (!ks%2)
        	        {
        	            ks+=1;
        	        }

        	        Process(21, 5, 50,90);

        	        cv::waitKey(0);

        }

        return 0;
    }
