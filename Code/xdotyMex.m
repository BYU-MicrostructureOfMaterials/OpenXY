#include "mex.h"



      void xdotyMex(double *x,double *y,double *z,int ColLen)

      {

      int j;

      z[0] = 0;

      for(j=0;j<ColLen;j++)
      {
          z[0] = z[0] + x[j]*y[j];
      }

      }

      

      void mexFunction( int nlhs, mxArray *plhs[],

      int nrhs, const mxArray *prhs[] )

      {

      double *x,*y, *z;

      int ColLen;

      

      if(nrhs!=2) {

      mexErrMsgTxt("Two inputs required.");

      } else if(nlhs>1) {

      mexErrMsgTxt("Too many output arguments");

      }

      plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);

      

      x = mxGetPr(prhs[0]);

      y = mxGetPr(prhs[1]);

      z = mxGetPr(plhs[0]);

      

      ColLen = mxGetN(prhs[0]); /*M-Rows N-Columns*/

      

      xdotyMex(x,y,z,ColLen);

      }