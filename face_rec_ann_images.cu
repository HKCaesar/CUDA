#include "opencv2/opencv.hpp"    // opencv general include file
#include "opencv2/ml/ml.hpp"          // opencv machine learning include file
#include <stdio.h>
#include <fstream>

using namespace std;
using namespace cv;

char b[500];
int total_num=90;//total number of images
int people=3;//number of people
int im_person=total_num/people;
Mat Y=Mat::zeros(total_num,people,CV_32F);

Mat generate_X(int m)
{
Mat image,im_row,X,X1;
	for(int i=1;i<m+1;i++)
	{
		sprintf(b,"/home/maxerience-l1/Desktop/Assignment-3/at/%d.jpg",i);
		image=imread(b,0);
		im_row=image.reshape(0,1);
		//im_row.convertTo(X, CV_32F);
		X1.push_back(im_row);
		X1.convertTo(X, CV_32F, 1.0/255.0);
	}
	return X;
}

int main()
{
	Mat X=generate_X(total_num);

	//imshow("X",X);
	//waitKey(0);
	//Y=Mat::zeros(total_num,people,CV_32F);
	std::cout<<X.cols<<endl;
	int k=0;
	for(int i=0;i<people;i++)
	{
		for(int j=0;j<im_person;j++)
		{
			Y.at<float>(k,i) = 1.0;
			k++;
		}

	}
	std::cout<<Y<<endl;


	cv::Mat layers(5,1,CV_32S);
	layers.at<int>(0,0) = 10304;//number of pixls in an image
	layers.at<int>(1,0)=200;//hidden layer1
	layers.at<int>(2,0)=150;//hidden layer2
	layers.at<int>(3,0)=100;//hidden layer2
	layers.at<int>(4,0) =3;//output layer
	//create the neural network using the function

	CvANN_MLP nnetwork(layers, CvANN_MLP::SIGMOID_SYM,0.6,1);

	CvANN_MLP_TrainParams params(

	                               // terminate the training after either 1000
	                               // iterations or a very small change in the
	                               // network wieghts below the specified value
	                               cvTermCriteria(CV_TERMCRIT_ITER+CV_TERMCRIT_EPS, 1000, 0.000001),
	                               // use backpropogation for training
	                               CvANN_MLP_TrainParams::BACKPROP,
	                               // co-efficents for backpropogation training
	                               // recommended values taken from http://docs.opencv.org/modules/ml/doc/neural_networks.html#cvann-mlp-trainparams
	                               0.1,0.1);

	printf( "\nUsing training dataset\n");
	//int iterations = nnetwork.train(training_set, training_set_classifications,cv::Mat(),cv::Mat(),params);
	int iterations = nnetwork.train(X, Y,cv::Mat(),cv::Mat(),params);
	printf( "Training iterations: %i\n\n", iterations);

	CvFileStorage* storage = cvOpenFileStorage( "/home/maxerience-l1/cuda-workspace/bat/neural_test.xml", 0, CV_STORAGE_WRITE );
	nnetwork.write(storage,"DigitOCR");
	cvReleaseFileStorage(&storage);



	cv::Mat classificationResult=Mat::zeros(1, 3, CV_32F);
		cv::Mat test_sample=imread("joyal1.jpg",0);
		test_sample.convertTo(test_sample, CV_32F, 1.0/255.0);
		imshow("test_sample",test_sample);
		//waitKey(0);
		cv::Mat row_try=test_sample.reshape(0,1);
		//imshow("row",row_try);
		//waitKey(0);      //test_sample = test_set.row(tsample);

		            //try to predict its class
		//std::cout<<row_try<<endl;
		nnetwork.predict(row_try, classificationResult);
        std::cout<<classificationResult<<endl;
		 int maxIndex=0;
		 float maxValue=classificationResult.at<float>(0,0),value;
		for(int index=0;index<3;index++)
		 {
			value = classificationResult.at<float>(0,index);
			if(value>maxValue)
				  {
					maxValue = value;

			          maxIndex=index;

                   }
	      }
		if (maxValue<0.6)
		{
			cout<<"no match found"<<endl;
			return 0;
		}
		std::cout<<maxIndex<<endl;
		switch(maxIndex)
	     {
	     case 0:
	         {
	        	 cout<<"Devanjan"<<endl;
	        	 break;
	         }
	     case 1:
	     	  {
	        	 cout<<"gourav"<<endl;
	     	     break;
	     	  }

	     case 2:
	     	  {
	     	     cout<<"joyal"<<endl;
	     	     break;
	     	  }

	     default:
	          {
	         	cout<<"Unknown"<<endl;
	         	break;
	          }
	     }
        return 0;

}
