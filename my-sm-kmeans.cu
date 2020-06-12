// Imports
#include <algorithm>
#include <cfloat>

#include <chrono>
#include <fstream>


#include <iostream>
#include <random>

#include <sstream>
#include <stdexcept>
#include <vector>

//Distance function to calculate distance etween two points (2 Dim. Data)
__device__ float
2d_distance(float x_a, float y_a, float x_b, float y_b) {
  std::cout << x_a<< std::endl;
  std::cout << y_a<< std::endl;
  std::cout << x_b<< std::endl;
  std::cout << y_b<< std::endl;
  return (y_a-y_b)*(y_a- y_b)+(x_a-x_b)*(x_a- x_b);
}
// Kernel to assign each data to its cluster
__global__ void clusters_assignments(const float* dataX,const float* dataY,int size,const float*  x_avg,const float* y_avg,
float*  totalX,
float*  totalY,int k,
int* counts) {
   __shared__ float centroids[]; //using shared memory to store the averages
  const int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index >= size) return; //out of scope
  if (threadIdx.x < k) {
    centroidsthreadIdx.x] = x_avg[threadIdx.x];
    centroids[k + threadIdx.x] = y_avg[threadIdx.x];
  }
  __syncthreads();
  // Make global loads once.
  const float x = dataX[index];
  const float y = dataY[index];
  float best_distance = FLT_MAX; //Longest possible distance
  int best_cluster = 0;
  for (int cluster = 0; cluster < k; ++cluster) {
    const float distance = 2d_distance(x,
 y,shared_means[cluster], shared_means[k + cluster]);
    if (distance < best_distance) { //Keep finding the shortest distance
       best_distance = distance;
        best_cluster = cluster; //assign to its cluster
    }
  }
  atomicAdd(&totalX[best_cluster], x); //Need to be optimized into reduction, but atomic operation for now
  atomicAdd(&totalY[best_cluster], y); 
  atomicAdd(&counts[best_cluster], 1);
}
//Recalculate the new centroids and reset eveyrhting back to 0 
__global__ void compute_new_means_and_reset(float* meansX,float* meansY,float* Totalx,
float* Totaly, int*   counts) {
  const int cluster= threadIdx.x; 
  const int count =max(1, counts[cluster]);
  meansX[cluster] =new_sum_x[cluster]/count;
  meansY[cluster] =new_sum_y[cluster]/ count;
  Totalx[cluster]=0;
  Totaly[cluster]= 0;
  counts[cluster] =0;
}
//Create a Data class to help organize and generalize all the vectors while also providing
//generalizable functions
struct Points {
  Points(int size) : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x,bytes); //allocate data onto GPU
    cudaMalloc(&y,bytes);
    cudaMemset(x,0, bytes);
    cudaMemset(y,0, bytes);}
  Points(int size, std::vector<float>& h_x, std::vector<float>& h_y)
  : size(size), bytes(size * sizeof(float)) {
    cudaMalloc(&x,bytes);
    cudaMalloc(&y,bytes);
    cudaMemcpy(x, h_x.data(), bytes, cudaMemcpyHostToDevice); //transfer data to gpu
    cudaMemcpy(y,h_y.data(), bytes, cudaMemcpyHostToDevice);
}
  ~Points(){ //to free data later on
    cudaFree(x);
  cudaFree(y);
  } 
  float* x{nullptr};
  float* y{nullptr};
  int size{0};
  int bytes{0} ;
};
int main(int argc, const char* argv[]) {
  if(argc < 3){ // parse csv file 
    std::cerr << "Didn't input right amount of arguments correctly"<< std::endl;
    std::exit(EXIT_FAILURE);
}
  const auto k = std::atoi(argv[2]); //k clusters
  const auto number_of_iterations = std::atoi(argv[2]); //Number of iterations
  std::vector<float> h_x; //assuming 2 dimensional data, so vector containing x axis
  std::vector<float> h_y; //vector containing y axis
  std::ifstream stream(argv[1]); //parse the csv file
  std::string line;
  while (std::getline(stream, line)) { //goes through the csv file line by line
    std::istringstream line_stream(line);
    std::cout << line << std::endl;
    float x, y;
    uint16_t label;
    line_stream >> x >> y >> label; //assume the csv file is in format: x y label
    h_x.push_back(x); 
    h_y.push_back(y);
  }
  const size_t number_of_elements = h_x.size(); //N size of dataset
  Points d_data(number_of_elements, h_x, h_y); 
  Points d_means(k, h_x, h_y); 
  Points d_sums(k); 
  int* d_counts;
  cudaMalloc(&d_counts, k * sizeof(int)); //allocate the space for the centroids
  cudaMemset(d_counts, 0, k * sizeof(int)); 
  const int threads = 1024;
  const int blocks = (number_of_elements + threads - 1) / threads;
  const int shared_memory = d_means.bytes * 2;
  std::cerr << "Processing " << number_of_elements << " points on " << blocks
            << " blocks x " << threads << " threads" << std::endl;
  const auto start = std::chrono::high_resolution_clock::now(); 
  for (size_t iteration = 0; iteration < number_of_iterations; ++iteration) {
    cluster_assignments<<<blocks, threads, shared_memory>>>(d_data.x,d_data.y,d_data.size,d_means.x,d_means.y,
d_sums.x,d_sums.y,k,d_counts); //first kernel to assign clusters
    cudaDeviceSynchronize(); //make sure all operations have been completed first
    compute_new_means_and_reset<<<1, k>>>(d_means.x,
d_means.y, d_sums.x,d_sums.y,d_counts); //the recalaculation operation in seperate kernel
    cudaDeviceSynchronize(); //make sure all operations have been completed first
  }
  const auto end = std::chrono::high_resolution_clock::now(); //timer ends
  const auto duration = std::chrono::duration_cast<std::chrono::duration<float>>(end - start);
  std::cerr << "Took: " << duration.count() << "s" << std::endl; //calculate duration
  cudaFree(d_counts); // free memory
  std::vector<float> mean_x(k, 0);
  std::vector<float> mean_y(k, 0);
  cudaMemcpy(mean_x.data(), d_means.x, d_means.bytes, cudaMemcpyDeviceToHost); //copy data points x axis back to host
  // copy data points y axis back to host
  cudaMemcpy(mean_y.data(), d_means.y, d_means.bytes, cudaMemcpyDeviceToHost);
  //print out all the clusters
  for (size_t cluster = 0; cluster < 1; ++cluster) {
    std::cout << mean_x[cluster] << " " << mean_y[cluster] << std::endl;
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