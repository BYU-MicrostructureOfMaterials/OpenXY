#pragma once

#include "algorithm/cpp/stlastar.h" // See header for copyright and usage information
#include <iostream>
#include <stdio.h>
#include <math.h>

using namespace std;

#define DEBUG_LISTS 0
#define DEBUG_LIST_LENGTHS_ONLY 0



class MapSearchNode
{
public:
    int x;   // the (x,y) positions of the node
    int y;
	int WIDTH;
	int HEIGHT;

    double* map_; // Pointer to the map
    
    MapSearchNode() { x = y = WIDTH = HEIGHT = 0; }
	MapSearchNode(int px, int py, double* map, int W, int H) { x = px; y = py; map_ = map; WIDTH = W; HEIGHT = H; }



    float GoalDistanceEstimate( MapSearchNode &nodeGoal );
    bool IsGoal( MapSearchNode &nodeGoal );
    bool GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node );
    float GetCost( MapSearchNode &successor );
    bool IsSameState( MapSearchNode &rhs );

    void PrintNodeInfo(); 
    int GetMap(int xind, int yind);

};




