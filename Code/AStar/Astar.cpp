#include "mex.h"
#include <iostream>
#include "AstarPlanner.h"

using namespace std;

mxArray* getMexArray(const vector<int>& v){
	mxArray* mx = mxCreateDoubleMatrix(1, v.size(), mxREAL);
	copy(v.begin(), v.end(), mxGetPr(mx));
	return mx;
}

double* FixMatrix(double* A, int mrows, int ncols) {
	vector<double> B;
	double* C;
	C = new double [mrows*ncols];
	for (int x = 0; x < mrows; x++){
		for (int y = 0; y < ncols; y++) {
			//B.push_back(A[y*mrows + x]);
			C[y + x*ncols] = A[y*mrows + x];
			//cout << y + x*ncols << " " << y*mrows + x << endl;
		}
	}
	//for (int i = 0; i < mrows*ncols; i++)
		//A[i] = B[i];
	return C;
}

void mexFunction(int nlhs, mxArray *plhs[],
                          int nrhs, const mxArray *prhs[])
{
    // Check input and output argument lengths
    if (nrhs!=3) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs","Three inputs required.");
    }
    if (nlhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs","Two outputs required.");
    }
    
    // Get Input (start,end,map)
    double* start;
    double* goal;
    double* MAP_in;
	double* MAP;
    int ncols;
    int mrows;
    
    start  = mxGetPr(prhs[0]);
    goal   = mxGetPr(prhs[1]);
    MAP_in = mxGetPr(prhs[2]);
    ncols  = mxGetN(prhs[2]);
    mrows  = mxGetM(prhs[2]);

	MAP = FixMatrix(MAP_in,mrows,ncols);
    
    // Get Path
    AstarPlanner astar(MAP,ncols,mrows);
	astar.SetStart(start[0], start[1]);
	astar.SetGoal(goal[0], goal[1]);
	astar.GetPath();
	
	// Create Output [path, success]
	bool success;
	success = astar.pathfound;
    plhs[1] = mxCreateDoubleScalar(success);

    plhs[0] = mxCreateDoubleMatrix(astar.PathLength(),2,mxREAL);
    double* pathout = mxGetPr(plhs[0]);
    for (int j = 0; j < 2; j++) {
		for (int i = 0; i < astar.PathLength(); i++){
			pathout[j*astar.PathLength() + i] = astar.path_[j][i];
		}
    }

	//astar.PrintPath();
	cout << mrows << 'x' << ncols << endl;
	astar.PrintMap();
	delete[] MAP;
    
}