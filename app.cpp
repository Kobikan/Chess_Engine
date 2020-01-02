#include <iostream>
#include <iterator>
#include <map>
#include <queue>
#include <string>

using namespace std;

queue<string> setup() {
  queue<string> pieces;
  string high[] = {"rook  ", "knight", "bishop", "queen ",
                   "king  ", "bishop", "knight", "rook  "};

  for (string &i : high) {
    pieces.push(i);
  }
  return pieces;
}

map<pair<int, int>, string> move(map<pair<int, int>, string> board) {
  int startX, startY;
  int endX, endY;
  cin >> startX;
  cin >> startY;
  cin >> endX;
  cin >> endY;
  board[make_pair(endX, endY)] = board[make_pair(startX, startY)];
  board[make_pair(startX, startY)] = "[]    ";
  return board;
}

int main() {
  queue<string> pieces = setup();
  map<pair<int, int>, string> board;
  for (int i = 1; i <= 64; i++) {
    pair<int, int> pos(i / 8, i % 8);
    if (i <= 8 || i >= 57) {
      pieces.push(pieces.front());
      board[pos] = pieces.front();
      pieces.pop();
    } else if (i <= 16 || (i >= 49 && i <= 56)) {
      board[pos] = "pawn  ";
    } else {
      board[pos] = "[]    ";
    }
  }

  map<pair<int, int>, string>::iterator itr;
  for (itr = board.begin(); itr != board.end(); ++itr) {
    cout << itr->second << " ";
    if (itr->first.second % 8 == 0) {
      cout << '\n';
    }
  }
  while (1) {
    board = move(board);
    for (itr = board.begin(); itr != board.end(); ++itr) {
      cout << itr->second << ' ';
      if (itr->first.second % 8 == 0) {
        cout << '\n';
      }
    }
  }
  return 0;
}
