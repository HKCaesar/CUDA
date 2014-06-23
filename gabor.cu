#include <opencv2/core/core.hpp>
    #include <opencv2/imgproc/imgproc.hpp>
    #include <opencv2/highgui/highgui.hpp>
    #include <math.h>
#include<iostream>


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

    //int kernel_size=21;
    //int pos_sigma= 5;
    //int pos_lm = 50;
    //int pos_th = 0;
    //int pos_psi = 90;
    cv::Mat src_f;
    cv::Mat dest[12];

    int Process(int ks,int sigma, int lamda,  int psi)
    {
        //double sig = pos_sigma;
        //double lm = 0.5+pos_lm/100.0;
        //double th = pos_th;
        //double ps = pos_psi;
    	cv::Mat seg=abs(src_f);

    	for (int i=0;i<12;i++)
    	{
    		cv::Mat kernel = mkKernel(ks, sigma, i*30, lamda, psi);
    		cv::filter2D(src_f, dest[i], CV_32F, kernel);
    		//cv::imshow("Pr", dest[i]);
    		seg+=abs(dest[i]);



    	}
    	//cv::imshow("Pr0", dest[0]);
    	//cv::imshow("Pr30", dest[1]);
    	//cv::imshow("Pr60", dest[2]);
    	//cv::imshow("Pr90", dest[4]);
    	//cv::imshow("Pr120", dest[5]);
    	//cv::imshow("Pr150", dest[6]);
    	//cv::imshow("Pr180", dest[7]);
    	//cv::imshow("Pr210", dest[8]);
    	//cv::imshow("Pr240", dest[9]);
    	//cv::imshow("Pr270", dest[10]);
    	//cv::imshow("Pr300", dest[11]);
    	//cv::imshow("Pr330", dest[12]);
    	seg= seg-src_f;
    	seg/=12;
    	cv::imshow("segm",seg);
    	cv::waitKey(0);

        //cv::Mat Lkernel(ks*20, ks*20, CV_32F);
        //cv::resize(kernel, Lkernel, Lkernel.size());
        //Lkernel /= 2.;
        //Lkernel += 0.5;
        //cv::imshow("Kernel", Lkernel);
        //cv::Mat mag;
        //cv::pow(dest, 2.0, mag);
        //cv::imshow("Mag", mag);
        return 0;
    }

    int main(int argc, char** argv)
    {
    	int ks=21;
    	cv::Mat image;
    	VideoCapture cap(0);  //= cv::imread("zebra.jpg",1);


        while(true)
        {
        	cap>>image;
        	        cv::imshow("Src", image);
        	        cv::Mat src;
        	        cv::cvtColor(image, src, CV_BGR2GRAY);
        	        src.convertTo(src_f, CV_32F, 1.0/255, 0);
        	        if (!ks%2)
        	        {
        	            ks+=1;
        	        }
        	        //cv::namedWindow("Process window", 1);
        	        //cv::createTrackbar("Sigma", "Process window", &pos_sigma, kernel_size, Process);
        	        //cv::createTrackbar("Lambda", "Process window", &pos_lm, 100, Process);
        	        //cv::createTrackbar("Theta", "Process window", &pos_th, 180, Process);
        	        //cv::createTrackbar("Psi", "Process window", &pos_psi, 360, Process);
        	        Process(21, 5, 50,90);

        	        cv::waitKey(0);

        }

        return 0;
    }
