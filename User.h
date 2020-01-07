#include <cstdlib>
#include <iostream>
#include <iterator>
#include <map>
#include <queue>
#include <string>
using namespace std;

class User {
public:
  User();
  User(string, int);
  string getColor() const;
  int getSide() const;

private:
  string color;
  int side;
};
