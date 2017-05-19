#include "MapNode.h"


using namespace std;

// Definitions

bool MapSearchNode::IsSameState( MapSearchNode &rhs )
{

    // same state in a maze search is simply when (x,y) are the same
    if( (x == rhs.x) &&
        (y == rhs.y) )
    {
        return true;
    }
    else
    {
        return false;
    }

}

void MapSearchNode::PrintNodeInfo()
{
    char str[100];
    sprintf_s( str, "Node position : (%d,%d)\n", x,y );

    cout << str;
}

// Here's the heuristic function that estimates the distance from a Node
// to the Goal. 

float MapSearchNode::GoalDistanceEstimate( MapSearchNode &nodeGoal )
{
    return fabsf(x - nodeGoal.x) + fabsf(y - nodeGoal.y);   
}

bool MapSearchNode::IsGoal( MapSearchNode &nodeGoal )
{

    if( (x == nodeGoal.x) &&
        (y == nodeGoal.y) )
    {
        return true;
    }

    return false;
}

// This generates the successors to the given Node. It uses a helper function called
// AddSuccessor to give the successors to the AStar class. The A* specific initialisation
// is done for each node internally, so here you just set the state information that
// is specific to the application
bool MapSearchNode::GetSuccessors( AStarSearch<MapSearchNode> *astarsearch, MapSearchNode *parent_node )
{

    int parent_x = -1; 
    int parent_y = -1; 
    
    if( parent_node )
    {
        parent_x = parent_node->x;
        parent_y = parent_node->y;
    }
    
    MapSearchNode NewNode;

    if( (GetMap( x-1, y ) < wall) 
        && !((parent_x == x-1) && (parent_y == y))
      ) 
    {
        NewNode = MapSearchNode( x-1, y, map_, WIDTH, HEIGHT );
        astarsearch->AddSuccessor( NewNode );
    }   

	if ((GetMap(x, y - 1) < wall)
        && !((parent_x == x) && (parent_y == y-1))
      ) 
    {
		NewNode = MapSearchNode(x, y - 1, map_, WIDTH, HEIGHT);
        astarsearch->AddSuccessor( NewNode );
    }   

	if ((GetMap(x + 1, y) < wall)
        && !((parent_x == x+1) && (parent_y == y))
      ) 
    {
		NewNode = MapSearchNode(x + 1, y, map_, WIDTH, HEIGHT);
        astarsearch->AddSuccessor( NewNode );
    }   
  
	if ((GetMap(x, y + 1) < wall)
        && !((parent_x == x) && (parent_y == y+1))
        )
    {
		NewNode = MapSearchNode(x, y + 1, map_, WIDTH, HEIGHT);
        astarsearch->AddSuccessor( NewNode );
    }   
    
    return true;
}

// given this node, what does it cost to move to successor. In the case
// of our map the answer is the map terrain value at this node since that is 
// conceptually where we're moving

float MapSearchNode::GetCost( MapSearchNode &successor )
{
    return (float) GetMap(x,y);

}

//int MapSearchNode::GetMap(int xind, int yind){
//    if ((xind >= 0 && xind < map_->rows() ) && 
//       (yind >= 0 && yind < map_->cols() )) {
//        return (*map_)( xind, yind );
//    }
//    else {
//        return 9;
//    }
//}

float MapSearchNode::GetMap(int xind, int yind){
	if (xind < 0 ||
		xind >= WIDTH ||
		yind < 0 ||
		yind >= HEIGHT
		)
	{
		return wall;
	}

	return map_[(yind*WIDTH) + xind];
}
