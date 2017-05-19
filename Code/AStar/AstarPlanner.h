#pragma once

#include "algorithm/cpp/stlastar.h" // See header for copyright and usage information
#include "MapNode.h"
#include <vector>

class AstarPlanner {
public:
    double* map_;
	int WIDTH;
	int HEIGHT;
	vector<vector<double>> path_;
    AStarSearch<MapSearchNode> astarsearch;
    MapSearchNode start;
    MapSearchNode goal;
	bool pathfound;

    AstarPlanner(double *map, int W, int H);
    void SetGoal(int x, int y);
	void SetStart(int x, int y);
	vector<vector<double>> GetPath();
	int PathLength();
    void PrintMap();
	void PrintPath();
	bool InPath(int x, int y);

private:
    unsigned int SearchCount;
    unsigned int NumSearches;

};

