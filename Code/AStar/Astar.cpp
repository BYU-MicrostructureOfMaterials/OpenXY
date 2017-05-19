#include "mex.h"
#include <iostream>
#include "AstarPlanner.h"

using namespace std;

mxArray* getMexArray(const vector<int>& v){
	mxArray* mx = mxCreateDoubleMatrix(1, v.size(), mxREAL);
	copy(v.begin(), v.end(), mxGetPr(mx));
	return mx;
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
    double* MAP;
    int ncols;
    int mrows;
    
    start = mxGetPr(prhs[0]);
    goal  = mxGetPr(prhs[1]);
    MAP   = mxGetPr(prhs[2]);
    ncols = mxGetN(prhs[2]);
    mrows = mxGetM(prhs[2]);
    
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
	//astar.PrintMap();
    
}