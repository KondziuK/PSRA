#include "opencv2\opencv.hpp"
#include "opencv2\core\core.hpp"
#include "opencv2\highgui\highgui.hpp"
#include "opencv2\imgproc\imgproc.hpp"
#include <iostream>
# include <algorithm>

//To quit program hold 'q'
//To pause program hold 'p'

///////////////Control panel/////////////////
const int Begin = 1;					//Start frame
const int End = 1200;					//Ending frame
const int Step = 2;						//Step frame
const int treshold_fg = 60;				//threshold for foreground segmentation
const int treshold_mov = 100;			//threshold for movement segmentation
const int medianBlur = 5;				//median blur coefficient
const float check_mov_thresh = 0.02;	//movement coefficient
const int min_size = 250;				//Minimum size to consider object an object to further investigation
const float UoI_creating_coeff = 0.6;		//Coefficent to consider between updating object and creating new one
const int frames_threshld = 120;		//threshold for amount of frames to consider object lost (like our baggage)
#pragma warning(disable:4996)
//////////////////////////////////////////////
typedef cv::Vec<uchar, 3> vec_uchar_3;
struct objectParameters
{
	int id;						//ID
	cv::Rect bbox;				//bounding box
	int area;					//area
	bool visible;				//is the object visible
	unsigned int staticCounter; //for how long the object was static?
};
std::vector<objectParameters> objVector;			//Detected objects in current frame
std::vector<objectParameters> tracked_objVector;	//Detected and tracted objects
int ID = 0;											//global variable for indexing new objects

int L1_norm(cv::Vec<uchar, 3> input_1, cv::Vec<uchar, 3>input_2) //Counting L1 norm from two inputs
{
	int norm = abs(input_1[0] - input_2[0]) + abs(input_1[1] - input_2[1]) + abs(input_1[2] - input_2[2]);
	return norm;
}

cv::Mat Segmentation(cv::Mat image_1, cv::Mat image_2, int threshold) //Segmentation 
{
	cv::Mat mask = cv::Mat::zeros(image_1.rows, image_1.cols, CV_8U);
	for (int jj = 0; jj < image_1.rows; jj++)
	{
		for (int ii = 0; ii < image_1.cols; ii++)
		{
			int L1_dist = L1_norm(image_1.at<vec_uchar_3>(jj, ii), image_2.at<vec_uchar_3>(jj, ii));
			if (L1_dist >= threshold)
				mask.at<uchar>(jj, ii) = 255;
			else
				mask.at<uchar>(jj, ii) = 0;
		}
	}
	return mask;
}

cv::Mat Bg_actualization(cv::Mat Bg, cv::Mat image, cv::Mat fgMask, cv::Mat movMask) //Background actualization
{
	cv::Mat Bg_new;
	Bg.copyTo(Bg_new);
	for (int jj = 0; jj < image.rows; jj++)
	{
		for (int ii = 0; ii < image.cols; ii++)
		{
			if (int(fgMask.at<uchar>(jj, ii)) == 0 && int(movMask.at<uchar>(jj, ii)) == 0)
			{
				vec_uchar_3 in_pixel = image.at<vec_uchar_3>(jj, ii);
				vec_uchar_3 m_pixel = Bg.at<vec_uchar_3>(jj, ii);
				for (int aa = 0; aa < 3; aa++)
				{
					if (in_pixel[aa] > m_pixel[aa])
						Bg_new.at<vec_uchar_3>(jj, ii)[aa] += 1;
					else
						if (in_pixel[aa] < m_pixel[aa])
							Bg_new.at<vec_uchar_3>(jj, ii)[aa] -= 1;
				}
			}

		}


	}
	return Bg_new;
}


float movementCheck(cv::Rect bbox, cv::Mat movMask) //Calculating amount of moving pixels relative to area of object
{
	int movPixels = 0;
	for (int ii = 0; ii < bbox.width; ii++)
	{
		for (int jj = 0; jj < bbox.height; jj++)
		{
			if (movMask.at<uchar>(jj + bbox.y, ii + bbox.x) == 255)
				movPixels++;
		}
	}
	return (float)(movPixels) / (bbox.width * bbox.height);
}

float intersection_over_union(cv::Rect r1, cv::Rect r2) {
	// Extract the required values
	unsigned int xmin_a = r1.x;
	unsigned int xmax_a = r1.x + r1.width;
	unsigned int ymin_a = r1.y;
	unsigned int ymax_a = r1.y + r1.height;
	unsigned int xmin_b = r2.x;
	unsigned int xmax_b = r2.x + r2.width;
	unsigned int ymin_b = r2.y;
	unsigned int ymax_b = r2.y + r2.height;
	// Compute the max/min
	unsigned int xA = std::max(xmin_a, xmin_b);
	unsigned int yA = std::max(ymin_a, ymin_b);
	unsigned int xB = std::min(xmax_a, xmax_b);
	unsigned int yB = std::min(ymax_a, ymax_b);
	// Compute intersection area
	unsigned int interArea = (xB - xA) * (yB - yA);
	// Compute both bounding box areas
	unsigned int boxAArea = (r1.width) * (r1.height);
	unsigned int boxBArea = (r2.width) * (r2.height);
	// Compute Intersection over Union
	float iou = float(interArea) / float(boxAArea + boxBArea -
		interArea);
	// Return value
	return iou;
}

int main(int args, char* argv)
{

	char buffer[100];
	cv::Mat inputImage;
	cv::Mat bgModel;
	cv::Mat image_prev;
	cv::Mat fgMask;
	cv::Mat prevImage;
	cv::Mat testImage; //For testing purposes
	cv::Mat movMask;
	std::string s_sequencepath = "pets_2006\\";
	int iImage = 2;

	cv::Mat labelledMask;
	cv::Mat labelStats;
	cv::Mat labelCentroids;
	bool CanIRun = true;


	for (iImage = Begin; iImage < End; iImage = iImage + Step) //Iterating over frames
	{
		sprintf(buffer, "in%06d.jpg", iImage);
		//std::cout << s_sequencepath + buffer << std::endl;
		inputImage = cv::imread(s_sequencepath + buffer);
		testImage = inputImage.clone();
		if (iImage == Begin) // Initial frame
		{
			bgModel = inputImage.clone();
			fgMask = cv::Mat::zeros(inputImage.rows, inputImage.cols, CV_8U);
			movMask = cv::Mat::zeros(inputImage.rows, inputImage.cols, CV_8U);
			image_prev = inputImage.clone();
			prevImage = inputImage.clone();
		}


		fgMask = Segmentation(inputImage, bgModel, treshold_fg);  //Foreground segmentation
		cv::medianBlur(fgMask, fgMask, medianBlur);							// median filtering
		movMask = Segmentation(inputImage, prevImage, treshold_mov);//Moving objects segmentation
		bgModel = Bg_actualization(bgModel, inputImage, fgMask, movMask);	//Background actualization
		inputImage.copyTo(prevImage);							//Saving previous frame

		//Indexation
		int noLabels = cv::connectedComponentsWithStats(fgMask, labelledMask, labelStats, labelCentroids, 8, CV_16U);

		for (int iLabel = 1; iLabel < noLabels; iLabel++) //Starting from 1 because 0 is background
		{
			int area = labelStats.at<int>(iLabel, cv::CC_STAT_AREA);
			if (area > min_size)
			{
				cv::Rect bbox;
				bbox.x = labelStats.at<int>(iLabel, cv::CC_STAT_LEFT);
				bbox.y = labelStats.at<int>(iLabel, cv::CC_STAT_TOP);
				bbox.width = labelStats.at<int>(iLabel, cv::CC_STAT_WIDTH);
				bbox.height = labelStats.at<int>(iLabel, cv::CC_STAT_HEIGHT);

				float movement = movementCheck(bbox, movMask);
				if (movement <= check_mov_thresh)
				{
					objectParameters object = { 0,bbox,area,true,0 }; //Create object and add to vector
					objVector.push_back(object);
				}
			}
		}
		//Analize detected objects
		for (int i = 0; i < tracked_objVector.size(); i++)
		{
			tracked_objVector[i].visible = false;
		}

		for (int i = 0; i < objVector.size(); i++)
		{
			float max = 0;
			int prev_pos = 0;
			for (int j = 0; j < tracked_objVector.size(); j++)
			{
				float IoU = intersection_over_union(objVector[i].bbox, tracked_objVector[j].bbox);

				if (IoU > max && IoU <= 1) //Must be less than 1.0
				{
					max = IoU;
					prev_pos = j; //Index of object with biggest IoU of current objVector[i] and all tracked_objVector(s)
				}
			}
			
			if (max >= UoI_creating_coeff) //If bigger than coefficient
			{ //Found object, updating
				tracked_objVector[prev_pos].bbox = objVector[i].bbox;
				tracked_objVector[prev_pos].area = tracked_objVector[prev_pos].bbox.width * tracked_objVector[prev_pos].bbox.height;
				tracked_objVector[prev_pos].id = tracked_objVector[prev_pos].id;
				tracked_objVector[prev_pos].staticCounter = tracked_objVector[prev_pos].staticCounter + Step;
				tracked_objVector[prev_pos].visible = true;

			}
			else
			{ //Not found object, creating
				objectParameters object = { ++ID,objVector[i].bbox,objVector[i].bbox.width * objVector[i].bbox.height,true,0 }; //Create object and add to vector
				tracked_objVector.push_back(object);

			}

		}
		//Cleaning
		objVector.clear();

		for (int i = 0; i < tracked_objVector.size(); i++)
			if (!tracked_objVector[i].visible)
				tracked_objVector.erase(tracked_objVector.begin() + i);

		//Visualisation
		for (int i = 0; i < tracked_objVector.size(); i++)
		{
			char buf[100];
			if (tracked_objVector[i].staticCounter > frames_threshld)
			{
				cv::rectangle(testImage, tracked_objVector[i].bbox, cv::Scalar(0, 0, 255), 2);
				sprintf(buf, "%f %d ALERT: LOST BAGGAGE", movementCheck(tracked_objVector[i].bbox, movMask), tracked_objVector[i].id);
			}
			else
			{
				sprintf(buf, "%f %d STATIC OBJECT", movementCheck(tracked_objVector[i].bbox, movMask), tracked_objVector[i].id);
				cv::rectangle(testImage, tracked_objVector[i].bbox, cv::Scalar(255, 0, 0), 2);
			}

			cv::putText(testImage, buf, cv::Point(tracked_objVector[i].bbox.x + 3, tracked_objVector[i].bbox.y + 5), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.8, cv::Scalar(0, 0, 255), 1);
		}
		//Displaying frames
		//cv::imshow("InputImage", inputImage);
		cv::imshow("fgMask", fgMask);
		cv::imshow("movMask", movMask);
		//cv::imshow("bgModel", bgModel);
		cv::imshow("TestImage", testImage);

		//Displaying control
		int q = cv::waitKey(1);
		if ((q & 0xFF) == int('q'))
			break;

		if ((q & 0xFF) == int('p'))
			cv::waitKey();
	}
	cv::destroyAllWindows();
	return 0;
}