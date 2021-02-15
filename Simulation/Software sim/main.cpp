#include "opencv2\opencv.hpp"
#include "opencv2\core\core.hpp"
#include "opencv2\highgui\highgui.hpp"
#include "opencv2\imgproc\imgproc.hpp"
#include <iostream>
# include <algorithm>

//To quit program hold 'q'
//To pause program hold 'p'

///////////////Control panel/////////////////
const int Begin = 0;					//Start frame
const int End = 1200;					//Ending frame
const int Step = 1;						//Step frame
const float check_mov_thresh = 0.01;	//movement coefficient
const int min_size = 60;				//Minimum size to consider object an object to further investigation
const float UoI_creating_coeff = 0.8;	//Coefficent to consider between updating object and creating new one
const int frames_threshld = 60;		//threshold for amount of frames to consider object lost (like our baggage)
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


int mov;
int m01;
int m10;
int m00;
int xmax;
int xmin;
int ymax;
int ymin;

float movementCheck(cv::Rect bbox,int movPixels) //Calculating amount of moving pixels relative to area of object
{
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
	char buffer2[100];
	cv::Mat inputImage;
	cv::Mat testImage; //For testing purposes
	std::string s_sequencepath = "pets_2006_ppm\\";
	std::string s_sequencepath2 = "Data\\";
	int iImage = 0;
	std::string line;

	for (iImage = Begin; iImage < End; iImage = iImage + Step) //Iterating over frames
	{
		sprintf(buffer, "in_%04d.ppm", iImage);
		sprintf(buffer2, "out_data_%04d.txt",iImage);
		inputImage = cv::imread(s_sequencepath + buffer);
		testImage = inputImage.clone();
		std::ifstream file(s_sequencepath2 + buffer2);
		if (file.is_open())
		{
			int i = 0;
			while (std::getline(file,line))
			{
	
				std::istringstream iss(line);
				iss >> mov >> m01 >> m10 >> m00 >> xmax >> xmin >> ymax >> ymin;
				int area = (xmax - xmin) * (ymax - ymin);
				if (area > min_size)
				{
					cv::Rect bbox;
					bbox.x = xmin;
					bbox.y = ymin;
					bbox.width = xmax - xmin;
					bbox.height = ymax - ymin;

					float movement = movementCheck(bbox,mov);
					if (movement <= check_mov_thresh)
					{
						objectParameters object = { 0,bbox,area,true,0}; //Create object and add to vector
						objVector.push_back(object);
					}
				}
				i++;
				std::cout << "Executing  line " << i << " for frame " << buffer2 << std::endl;
			}
			file.close();
		}
		else
			std::cout << "File " << s_sequencepath2 + buffer2 << " was not open" << std::endl;
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

				if (IoU > max&& IoU <= 1) //Must be less than 1.0
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
				//sprintf(buf, "%d ALERT: LOST BAGGAGE",tracked_objVector[i].id);
			}
			else
			{
				//sprintf(buf,"%d",tracked_objVector[i].id);
				cv::rectangle(testImage, tracked_objVector[i].bbox, cv::Scalar(255, 0, 0), 2);
			}

			//cv::putText(testImage, buf, cv::Point(tracked_objVector[i].bbox.x + 3, tracked_objVector[i].bbox.y + 5), cv::FONT_HERSHEY_COMPLEX_SMALL, 0.8, cv::Scalar(0, 0, 255), 1);
		}
		//Displaying frames
		cv::imshow("TestImage", testImage);

		//Displaying control
		int q = cv::waitKey(10);
		if ((q & 0xFF) == int('q'))
			break;

		if ((q & 0xFF) == int('p'))
			cv::waitKey();
	}
	cv::destroyAllWindows();
	return 0;
}