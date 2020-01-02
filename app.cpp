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

int check(string piece, map<pair<int, int>, string> board) {
  int state = 1;
  return state;
}

map<pair<int, int>, string> move(map<pair<int, int>, string> board) {
  int start = 1;
  while (start) {
    int startX, startY;
    int endX, endY;
    cin >> startX;
    cin >> startY;
    cin >> endX;
    cin >> endY;
    start = check(board[make_pair(startX, startY)], board);
    board[make_pair(endX, endY)] = board[make_pair(startX, startY)];
    board[make_pair(startX, startY)] = "[]    ";
  }
  return board;
}

int main() {
  queue<string> pieces = setup();
  map<pair<int, int>, string> board;
  for (int i = 0; i <= 63; i++) {
    pair<int, int> pos(i / 8, i % 8);
    if (i < 8 || i >= 56) {
      pieces.push(pieces.front());
      board[pos] = pieces.front();
      pieces.pop();
    } else if (i < 16 || (i >= 48 && i < 56)) {
      board[pos] = "pawn  ";
    } else {
      board[pos] = "[]    ";
    }
  }

  map<pair<int, int>, string>::iterator itr;
  for (itr = board.begin(); itr != board.end(); ++itr) {
    cout << itr->second << " ";
    if (itr->first.second % 8 == 7) {
      cout << '\n';
    }
  }
  while (1) {
    board = move(board);
    for (itr = board.begin(); itr != board.end(); ++itr) {
      cout << itr->second << " ";
      if (itr->first.second % 8 == 7) {
        cout << '\n';
      }
    }
  }
  return 0;
}
