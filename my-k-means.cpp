#include<stdio.h>
#include <string.h>
#include <ctime>
#include <fstream>
#include <iostream>


#include <bits/stdc++.h> 

using namespace std;
// Class to store the points
struct Data_Point{
double x;     // two dimensional coordinates
double y;
int clusterID;    //integer ID for the cluster
    double shortestDist;  // default infinite distance to nearest cluster
        double 2d_distance(Data_Point p) { //Computes Distances between points
        return (p.x -x)*(p.x - x) +(p.y -y)*(p. - y);
    }
    Data_Point(double x, double y) : x(x), y(y), cluster(-1), minDist(__DBL_MAX__) {}

};

#include <sstream>
#include <vector>
//Reads in csv file that uses space between values instead of commas 
//Returns a vector of point objects
vector<Data_Point> readcsv() {
    vector<Data_Point> points;
    std::ifstream stream("../data/1M.csv");
    std::string line;
    int firstloop = 1;
    while (std::getline(stream, line)) {
        if(firstloop ==1){
        firstloop=0;
         continue;
        }
        double x;
        double y;
        std::istringstream line_stream(line);
        size_t label;
        line_stream >> x >> y >> label;
        // cout << x <<endl;
        // cout << y <<endl;
        points.push_back(Data_Point(x,y));
    }
    return points;
}
// Does the actual work of K means clustering
// writes a new output.csv file containing the points and the clusters they're assigned to
void kMeans(vector<Data_Point>* data, int k, int iter) {
    int n = data->size(); // uses -> to dereference pointers
    vector<Data_Point> centroids;
        for (int i= 0; i < k; ++i) {
            centroids.push_back(data->at(rand() % n));
        }
    for (int i= 0;i< iter; ++i) { //iteration loop
        for (vector<Data_Point>::iterator c = begin(centroids);c!= end(centroids);++c) { //loop through each centroid
            int clusterId = c - begin(centroids);
            for (vector<Data_Point>::iterator it = data->begin();
                 it != data->end(); ++it) { // loops through each point 
                Data_Point p = *it;
                double dist = c->2d_distance(p);
                if (dist < p.shortestDist) { //Find the smallest distance
                 p.shortestDist = dist;
                 p.clusterID = clusterId;
                }
            *it = p;
            }
        }
        // Vectors to store points and means
        vector<int> nPoints;
        vector<double> x_sum, y_sum;
        for (int j = 0; j < k; j++) {
            nPoints.push_back(0);
            sumX.push_back(0.0);
            sumY.push_back(0.0);
        }
        // Iterate over points to append data to centroids
        for (vector<Data_Point>::iterator it = points->begin(); it != points->end();
             ++it) {
            int clusterId = it->cluster;
            nPoints[clusterId] += 1;
            sumY[clusterId] += it->y;
            sumX[clusterId] += it->x;
            it->shortestDist = __DBL_MAX__;  // reset distance
        }
        // Compute the new centroids
        for (vector<Data_Point>::iterator c = begin(centroids); c != end(centroids);
             ++c) {
            int clusterId = c - begin(centroids);
            c->x = sumX[clusterId] / nPoints[clusterId];
            c->y = sumY[clusterId] / nPoints[clusterId];
        }
    }

    // Write into csv file, so can be plotted later to check if it's correct
    ofstream myfile;
    myfile.open("output.csv");
    myfile << "x,y,c" << endl;

    for (vector<Point>::iterator it = data->begin(); it != data->end();
         ++it) {
        myfile << it->x << "," << it->y << "," << it->cluster << endl;
    }
    myfile.close();
}

int main() {
    cout << "Hello, World" <<endl;
    vector<Data_Point> points = readcsv();
    cout << "cook" <<endl;
    int number_of_runs = 5;
    vector<double> means;
    double total_elapsed = 0;
     for (int run = 0; run < number_of_runs; run++) {
        const auto start = std::chrono::high_resolution_clock::now(); //higher resolution timer because regular timer isn't precise enough
        means = kMeans(points, 5, 5); //5 iterations, 5 clusters, will be tuned manually to test
        const auto end = std::chrono::high_resolution_clock::now();
        const auto duration =
        std::chrono::duration_cast<std::chrono::duration<double>>(end - start);
        total_elapsed += duration.count(); //total time
  }
  std::cerr << "Took: " << total_elapsed / number_of_runs << "s ("
            << number_of_runs << " runs)" << std::endl;

  for (auto& mean : means) {
    std::cout << mean.x << " " << mean.y << std::endl;
  }
}









// References: 
// https://github.com/src-d/kmcuda
// https://stanford.edu/~cpiech/cs221/handouts/kmeans.html
// http://www.goldsborough.me/
// https://www.geeksforgeeks.org/k-means-clustering-introduction/
// https://reasonabledeviations.com/
// https://rosettacode.org/
// https://github.com/robertmartin8/udemyML/blob/master/06_clustering/Mall_Customers.csv
