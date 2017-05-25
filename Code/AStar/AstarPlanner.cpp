#include "AstarPlanner.h"

using namespace std;

#define DEBUG_LISTS 0
#define DEBUG_LIST_LENGTHS_ONLY 0
#define PRINT_INFO 0

AstarPlanner::AstarPlanner(double *map, int W, int H) {
    this->map_ = map;
    MapSearchNode node;

    start = MapSearchNode(0,0,map,W,H);
    goal = MapSearchNode(0,0,map,W,H);

	WIDTH = W;
	HEIGHT = H;

    SearchCount = 0;
    NumSearches = 1;
    pathfound = false;

	Cost_max = 1;
	Cost_min = 0;

	ScaleMap();
}

AstarPlanner::AstarPlanner(double *map, int W, int H, double Cmax, double Cmin){
	AstarPlanner(map, W, H);
	Cost_max = Cmax;
	Cost_min = Cmin;
}

void AstarPlanner::ScaleMap() {
	for (int i = 0; i < WIDTH*HEIGHT; i++) {
		map_[i] = start.wall*(map_[i]-Cost_min)/(Cost_max-Cost_min);
	}
}

void AstarPlanner::SetGoal(int x, int y) {
    goal.x = x;
    goal.y = y;
    pathfound = false;
}

void AstarPlanner::SetStart(int x, int y) {
	start.x = x;
	start.y = y;
	pathfound = false;
}

void AstarPlanner::PrintMap() {
	cout << "Print Map" << endl;
	cout << "Start: (" << start.x << "," << start.y << ")" << endl;
	cout << "Goal: (" << goal.x << "," << goal.y << ")" << endl;
	for (int i = 0; i < HEIGHT; i++) {
		for (int j = 0; j < WIDTH; j++) {
			if (i == start.y && j == start.x)
				cout << 'S' << " ";
			else if (i == goal.y && j == goal.x)
				cout << 'G' << " ";
			else if (InPath(j, i))
				cout << '*' << " ";
			else
				cout << start.GetMap(j, i) << " ";
		}
		cout << endl;
	}
}

bool AstarPlanner::InPath(int x, int y) {
	for (int i = 0; i < PathLength(); i++) {
		if (path_[0][i] == x && path_[1][i] == y)
			return true;
	}
	return false;
}

int AstarPlanner::PathLength(){
	if (pathfound)
		return path_[0].size();
	else
		return 0;
}

void AstarPlanner::PrintPath(){
	if (pathfound){
		for (int i = 0; i < PathLength(); i++) {
			cout << path_[0][i] << " " << path_[1][i] << endl;
		}
	}
}

vector<vector<double>> AstarPlanner::GetPath() {
	vector<vector<double>> path;
	vector<double> x;
	vector<double> y;

    // Set Start and goal states

    astarsearch.SetStartAndGoalStates( start, goal );

    unsigned int SearchState;
    unsigned int SearchSteps = 0;
    int steps = 0;

    //start.GetSuccessors(&astarsearch, &goal);

    do
    {
        SearchState = astarsearch.SearchStep();

        SearchSteps++;

        #if DEBUG_LISTS

            cout << "Steps:" << SearchSteps << "\n";

            int len = 0;

            cout << "Open:\n";
            MapSearchNode *p = astarsearch.GetOpenListStart();
            while( p )
            {
                len++;
                #if !DEBUG_LIST_LENGTHS_ONLY
                    ((MapSearchNode *)p)->PrintNodeInfo();
                #endif
                p = astarsearch.GetOpenListNext();

            }

            cout << "Open list has " << len << " nodes\n";

            len = 0;

            cout << "Closed:\n";
            p = astarsearch.GetClosedListStart();
            while( p )
            {
                len++;
                #if !DEBUG_LIST_LENGTHS_ONLY
                    p->PrintNodeInfo();
                #endif
                p = astarsearch.GetClosedListNext();
            }

            cout << "Closed list has " << len << " nodes\n";
        #endif

    } while( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SEARCHING );

    if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_SUCCEEDED )
    {
		#if PRINT_INFO
			cout << "Search found goal state\n";
		#endif

        MapSearchNode *node = astarsearch.GetSolutionStart();

        #if DISPLAY_SOLUTION
            cout << "Displaying solution\n";
        #endif

		#if PRINT_INFO
			node->PrintNodeInfo();
		#endif
        for( ;; )
        {
            node = astarsearch.GetSolutionNext();

            if( !node )
            {
                break;
            }

			#if PRINT_INFO
				node->PrintNodeInfo();
			#endif
            x.push_back(node->x);
            y.push_back(node->y);
            steps ++;

        };

		#if PRINT_INFO
			cout << "Solution steps " << steps << endl;
		#endif

        // Once you're done with the solution you can free the nodes up
        astarsearch.FreeSolutionNodes();
        pathfound = true;

    }
    else if( SearchState == AStarSearch<MapSearchNode>::SEARCH_STATE_FAILED )
    {
		#if PRINT_INFO
			cout << "Search terminated. Did not find goal state\n";
		#endif
    }

    // Display the number of loops the search went through
	#if PRINT_INFO
		cout << "SearchSteps : " << SearchSteps << "\n";
	#endif
    SearchCount ++;

    astarsearch.EnsureMemoryFreed();

	path.push_back(x);
	path.push_back(y);
    path_ = path;
    return path;
}
