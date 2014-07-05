#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <float.h>
#include <limits.h>
#include <time.h>
#include <ctype.h>
#include <fstream>
#include <sstream>
#include <vector>
#include <opencv2/opencv.hpp>
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "opencv2/imgproc/imgproc.hpp"


using namespace std;
using namespace cv;

const char* cascade_name =
"haarcascade_frontalface_alt.xml";
/* "haarcascade_profileface.xml";*/
Size size(92,112);
int n=10;
int k=1;
char b[100];
int limit=301;
Mat croppedFaceImage;
int t=10;
CvSeq* faces1;
void detect_and_draw(IplImage* image);



int main(int argc, char** argv)
{
CvCapture* capture = capture = cvCaptureFromCAM(0); // capture from video device (Macbook iSight)
IplImage *img;
IplImage *newImg;

while(1)
{
newImg = cvQueryFrame(capture);
if (!newImg) break;
//Mat frame = cvarrToMat(newImg);
cvShowImage("source",newImg);
waitKey(10);
for(int s=0;s<t*300;s++)
	{
	for(int p=0;p<10000;p++){};
	}

img = cvCreateImage(cvGetSize(newImg), IPL_DEPTH_8U, 1);
img = newImg;
cvFlip(img, img, 1);
detect_and_draw(img);
sprintf(b,"test/%d.pgm",k);
if (faces1->total==0)continue;
cvtColor(croppedFaceImage,croppedFaceImage,CV_BGR2GRAY);
imwrite(b,croppedFaceImage);
std::cout<<k<<std::endl;
k++;
if (k==limit)break;
}

cvReleaseCapture(&capture);
cvReleaseImage(&img);
cvDestroyWindow("result");
return 0;
}
void detect_and_draw(IplImage* img)
{

CvRect box[10];
static CvMemStorage* storage = 0;
static CvHaarClassifierCascade* cascade = 0;
int scale = 1;
IplImage* temp = cvCreateImage(cvSize(img->width / scale, img->height / scale), 8, 3);
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
CvSeq* faces = cvHaarDetectObjects(img, cascade, storage,1.1, 2, CV_HAAR_DO_CANNY_PRUNING,cvSize(40, 40));
faces1=faces;
for (i = 0; i < (faces ? faces->total : 0); i++)
{
CvRect* r = (CvRect*)cvGetSeqElem(faces, i);
box[i]=*r;
}
}
cv::Mat new_img = cvarrToMat(img);
//imshow("result",new_img);
for(int j=0;j<faces1->total;j++)
{
croppedFaceImage = new_img(box[j]).clone();
imshow("show",croppedFaceImage);
cv::resize(croppedFaceImage,croppedFaceImage,size);

}
cvReleaseImage(&temp);
}
