#include <cstdlib>
#include <iostream>
#include <iterator>
#include <map>
#include <queue>
#include <string>
using namespace std;

class Piece{
public:
  Piece();
  Piece(string, int);

  string getPiece() const;
  int getSide() const;
private:
  string type;
  int side;
};
